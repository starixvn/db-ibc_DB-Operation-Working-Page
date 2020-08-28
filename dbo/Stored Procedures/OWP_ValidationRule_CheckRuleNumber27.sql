/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber27] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170724@Tim.Trinh
 Task : Rule number 27: Wrong match status of special events
 DB: bodb_OWP

 Revisions:
    20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180725@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 27
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Trader NVARCHAR(100)
		,@MatchStatus NVARCHAR(20)
		,@idoc INT
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89

	CREATE TABLE #tblParentMatch (
		RowNumber INT
		,MatchStatus NVARCHAR(15)
		)

	CREATE TABLE #tblMinorMatchDifferent (RowNumber INT)

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	-- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Trader = Trader
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Trader NVARCHAR(100)) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @MatchStatus = info.MatchStatus
		FROM dbo.OWPMatch AS m WITH (NOLOCK)
			INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON m.OWPMatchId = info.OWPMatchId
			INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON m.OWPMatchId = minor.ParentMatchId
		WHERE minor.MinorMatchId = @OWPMatchId

		IF @MatchStatus = 'Cancel'
			AND @Trader <> ''
		BEGIN
			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', '') AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblParentMatch

	DROP TABLE #tblMinorMatchDifferent
END