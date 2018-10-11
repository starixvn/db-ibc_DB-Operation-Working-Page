/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber10] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 10: Missing O/U trader
 DB: bodb_OWP

 Revisions:
    20180725@Raymond.Le: Missing main assignment of {bet type} - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 10
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@TraderOU NVARCHAR(100)
		,@Bettype INT
		,@OverUnder INT = 3
		,@AssignmentType TINYINT
		,@Assignee TINYINT
		,@idoc INT

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,InvalidBettype NVARCHAR(100)
		)

	CREATE TABLE #tblCombineInvalidBettype (
		RowNumber INT
		,Bettype NVARCHAR(MAX)
		)

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	SELECT @Assignee = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'AssignmentType'
		AND Value = 'Assignee'

	-- upload
	IF LEN(@SessionId) > 0
	BEGIN
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,InvalidBettype
			)
		SELECT unpvt.RowNumber
			,CASE 
				WHEN unpvt.ColumnName = 'TraderHDP'
					AND ot.OtherTradersHDP IS NOT NULL
					AND CAST(ot.OtherTradersHDP AS NVARCHAR(MAX)) != '' THEN 'HDP'
				WHEN unpvt.ColumnName = 'Trader1HHDP'
					AND ot.OtherTraders1HHDP IS NOT NULL
					AND CAST(ot.OtherTraders1HHDP AS NVARCHAR(MAX)) != '' THEN '1H HDP'
				WHEN unpvt.ColumnName = 'TraderOU'
					AND ot.OtherTradersOU IS NOT NULL
					AND CAST(ot.OtherTradersOU AS NVARCHAR(MAX)) != '' THEN 'O/U'
				WHEN unpvt.ColumnName = 'Trader1HOU'
					AND ot.OtherTraders1HOU IS NOT NULL
					AND CAST(ot.OtherTraders1HOU AS NVARCHAR(MAX)) != '' THEN '1H O/U'
				WHEN unpvt.ColumnName = 'Trader1X2'
					AND ot.OtherTraders1X2 IS NOT NULL
					AND CAST(ot.OtherTraders1X2 AS NVARCHAR(MAX)) != '' THEN '1X2'
				WHEN unpvt.ColumnName = 'Trader1H1X2'
					AND ot.OtherTraders1H1X2 IS NOT NULL
					AND CAST(ot.OtherTraders1H1X2 AS NVARCHAR(MAX)) != '' THEN '1H 1X2'
				WHEN unpvt.ColumnName = 'LA'
					AND ot.OtherLA IS NOT NULL
					AND CAST(ot.OtherLA AS NVARCHAR(MAX)) != '' THEN 'LA'
				WHEN unpvt.ColumnName = 'Trader15Mins'
					AND ot.OtherTraders15Mins IS NOT NULL
					AND CAST(ot.OtherTraders15Mins AS NVARCHAR(MAX)) != '' THEN '15Mins'
				WHEN unpvt.ColumnName = 'Trader10Mins'
					AND ot.OtherTraders10Mins IS NOT NULL
					AND CAST(ot.OtherTraders10Mins AS NVARCHAR(MAX)) != '' THEN '10Mins'
				WHEN unpvt.ColumnName = 'TraderFM'
					AND ot.OtherTradersFM IS NOT NULL
					AND CAST(ot.OtherTradersFM AS NVARCHAR(MAX)) != '' THEN 'FM'
				WHEN unpvt.ColumnName = 'TraderAIO'
					AND ot.OtherTradersAIO IS NOT NULL
					AND CAST(ot.OtherTradersAIO AS NVARCHAR(MAX)) != '' THEN 'AIO'
				END
		FROM (
			SELECT RowNumber
				,TraderHDP
				,Trader1HHDP
				,TraderOU
				,Trader1HOU
				,Trader1X2
				,Trader1H1X2
				,LA
				,Trader15Mins
				,Trader10Mins
				,TraderFM
				,TraderAIO
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (TraderHDP, Trader1HHDP, TraderOU, Trader1HOU, Trader1X2, Trader1H1X2, LA, Trader15Mins, Trader10Mins, TraderFM, TraderAIO)) unpvt
			LEFT JOIN dbo.AssignmentUploading AS ot WITH (NOLOCK) ON unpvt.RowNumber = ot.RowNumber
			AND ot.SessionId = @SessionId
		WHERE (unpvt.RowNumber % 10) = 0
			AND ISNULL(unpvt.Trader, '') = ''

		-- combine
		INSERT INTO #tblCombineInvalidBettype (
			RowNumber
			,Bettype
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT DISTINCT '; ' + InvalidBettype
					FROM #tblAssignmentUploading WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tblAssignmentUploading WITH (NOLOCK)
			WHERE InvalidBettype IS NOT NULL
			) AS data

		-- result
		SELECT @SessionId
			,upload.RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN c.RowNumber IS NOT NULL THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN c.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', c.Bettype)
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			LEFT JOIN #tblCombineInvalidBettype AS c WITH (NOLOCK) ON upload.RowNumber = c.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @TraderOU = data.Trader
			,@Bettype = data.Bettype
			,@AssignmentType = data.AssignmentType
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Trader NVARCHAR(100), Bettype INT, AssignmentType TINYINT) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNULL(@TraderOU, '') = ''
			AND @Bettype = @OverUnder
			AND @AssignmentType = @Assignee
		BEGIN
			SELECT @RuleResultType AS ResultType
				,@Message AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCombineInvalidBettype
END