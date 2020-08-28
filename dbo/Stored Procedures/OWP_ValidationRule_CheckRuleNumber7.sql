/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber7] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 7: Duplicate provider's phone
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: remove check data in bodb02
	20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180718@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868]
	20181031@Raymond.Le: Replace column MatchId by InfoSiteMatchId - [Redmine: #104052]
	20190510@Kane.Le: Change phone length 200 - [Redmine: #112918]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 7
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@MatchLength SMALLINT
		,@Message NVARCHAR(MAX)
		,@Phone NVARCHAR(200)
		,@owpEventDate DATETIME
		,@idoc INT
		,@IsViolated BIT = 0
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,owpEventDate DATETIME NULL
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,Phone NVARCHAR(200)
		,HasPhoneNumber BIT
		,MinorBettypeId INT NULL
		,ParentRowNumber INT NULL
		)

	CREATE TABLE #tblMatchDuplicatePhone (
		RowNumber INT
		,Match NVARCHAR(2000)
		)

	CREATE TABLE #tblCombineMatchDuplicatePhone (
		RowNumber INT
		,Match NVARCHAR(MAX)
		)

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	SELECT @MatchLength = Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MatchLength'

	-- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Phone = data.Phone
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Phone NVARCHAR(50)) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @owpEventDate = DATEADD(dd, DATEDIFF(dd, 0, EventDate), CAST(KickOffTime AS DATETIME))
		FROM dbo.OWPMatch WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId

		IF ISNULL(@Phone, '') <> ''
		BEGIN
			INSERT INTO #tblMatchDuplicatePhone (
				RowNumber
				,Match
				)
			SELECT 1
				,home.OWPTeamName + ' -vs- ' + away.OWPTeamName
			FROM dbo.MatchInfo AS info WITH (NOLOCK)
				INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON info.OWPMatchId = m.OWPMatchId
				INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON m.OWPHomeId = home.OWPTeamId
				INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON m.OWPAwayId = away.OWPTeamId
			WHERE m.OWPMatchId <> @OWPMatchId
				AND info.Phone = @Phone
				AND DATEADD(dd, DATEDIFF(dd, 0, m.EventDate), CAST(m.KickOffTime AS DATETIME)) BETWEEN DATEADD(MINUTE, - 1 * @MatchLength, @owpEventDate)
					AND DATEADD(MINUTE, @MatchLength, @owpEventDate)
				AND NOT EXISTS (
					SELECT 1
					FROM dbo.MinorMatch AS minor WITH (NOLOCK)
					WHERE minor.MinorMatchId = m.OWPMatchId
					)

			IF EXISTS (
					SELECT 1
					FROM #tblMatchDuplicatePhone WITH (NOLOCK)
					)
			BEGIN
				SET @IsViolated = 1
			END
		END

		IF @IsViolated = 1
		BEGIN
			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', STUFF((
							SELECT DISTINCT '; ' + Match
							FROM #tblMatchDuplicatePhone WITH (NOLOCK)
							WHERE RowNumber = 1
							FOR XML PATH('')
							), 1, 2, '')) AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblMatchDuplicatePhone

	DROP TABLE #tblCombineMatchDuplicatePhone
END