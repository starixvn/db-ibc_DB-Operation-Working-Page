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
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 7
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@MatchLength SMALLINT
		,@Message NVARCHAR(MAX)
		,@Phone NVARCHAR(50)
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
		,Phone NVARCHAR(50)
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

	-- upload
	IF LEN(@SessionId) > 0
	BEGIN
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,owpEventDate
			,League
			,Home
			,Away
			,Phone
			,HasPhoneNumber
			,MinorBettypeId
			,ParentRowNumber
			)
		SELECT RowNumber
			,(CASE 
				WHEN ISDATE(KickOffTime) = 1 THEN DATEADD(dd, DATEDIFF(dd, 0, EventDate), CAST(KickOffTime AS DATETIME))
				ELSE NULL END
				) AS owpEventDate
			,League
			,Home
			,Away
			,Phone
			,(CASE 
				WHEN ISNULL(Phone, '') = '' THEN 0
				ELSE 1 END
				) HasPhoneNumber
			,MinorBettypeId
			,ParentRowNumber
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId

		-- check match duplicate phone
		INSERT INTO #tblMatchDuplicatePhone (
			RowNumber
			,Match
			)
		SELECT upload.RowNumber
			,upload1.Home + ' vs ' + upload1.Away
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
			INNER JOIN #tblAssignmentUploading AS upload1 WITH (NOLOCK) ON upload.Phone = upload1.Phone
		WHERE upload.RowNumber <> upload1.RowNumber
			AND upload.HasPhoneNumber = 1
			AND upload1.HasPhoneNumber = 1
			AND upload.owpEventDate IS NOT NULL
			AND upload1.owpEventDate IS NOT NULL
			AND upload1.owpEventDate BETWEEN DATEADD(MINUTE, - 1 * @MatchLength, upload.owpEventDate)
				AND DATEADD(MINUTE, @MatchLength, upload.owpEventDate)
			AND ISNULL(upload.MinorBettypeId, 0) NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
			AND ISNULL(upload1.MinorBettypeId, 0) NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
			AND (
				(
					ISNULL(upload.ParentRowNumber, 0) = 0
					AND upload.RowNumber <> ISNULL(upload1.ParentRowNumber, 0)
					)
				OR (
					ISNULL(upload1.ParentRowNumber, 0) = 0
					AND upload1.RowNumber <> ISNULL(upload.ParentRowNumber, 0)
					)
				)

		-- combine
		INSERT INTO #tblCombineMatchDuplicatePhone (
			RowNumber
			,Match
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT DISTINCT '; ' + Match
					FROM #tblMatchDuplicatePhone WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tblMatchDuplicatePhone WITH (NOLOCK)
			) AS data

		-- result
		SELECT @SessionId
			,upload.RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN m.RowNumber IS NOT NULL THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN m.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', m.Match)
				ELSE '' END
				) AS [Message]
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
			LEFT JOIN #tblCombineMatchDuplicatePhone AS m WITH (NOLOCK) ON upload.RowNumber = m.RowNumber
	END
	ELSE -- edit
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
				,home.OWPTeamName + ' vs ' + away.OWPTeamName
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