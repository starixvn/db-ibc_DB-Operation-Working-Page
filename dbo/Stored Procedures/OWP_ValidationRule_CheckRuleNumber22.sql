CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber22] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 22: Missing Maxbet
 DB: bodb_OWP

 Revisions:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 22
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@MaxBet VARCHAR(200)
		,@idoc INT

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,MaxBet NVARCHAR(200)
		,IsValid BIT
		)

	CREATE TABLE #tblCombineInvalidMaxBet (
		RowNumber INT
		,ColumnName NVARCHAR(MAX)
		)

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	-- upload
	IF LEN(@SessionId) > 0
	BEGIN
		INSERT INTO #tblAssignmentUploading (
			RowNumber
			,ColumnName
			,MaxBet
			,IsValid
			)
		SELECT RowNumber
			,(CASE ColumnName
				WHEN 'MaxBetHDP' THEN 'Max Bet (HDP)'
				WHEN 'MaxBet1HHDP' THEN 'Max Bet (1H HDP)'
				WHEN 'MaxBetOU' THEN 'Max Bet (O/U)'
				WHEN 'MaxBet1HOU' THEN 'Max Bet (1H O/U)'
				WHEN 'MaxBet1X2' THEN 'Max Bet (1X2)'
				WHEN 'MaxBet1H1X2' THEN 'Max Bet (1H 1X2)' END
				) AS ColumnName
			,unpvt.MaxBet
			,0
		FROM (
			SELECT RowNumber
				,MaxBetHDP
				,MaxBet1HHDP
				,MaxBetOU
				,MaxBet1HOU
				,MaxBet1X2
				,MaxBet1H1X2
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS upload
		UNPIVOT(MaxBet FOR ColumnName IN (MaxBetHDP, MaxBet1HHDP, MaxBetOU, MaxBet1HOU, MaxBet1X2, MaxBet1H1X2)) unpvt

		-- check maxbet
		UPDATE upload
		SET upload.IsValid = 1
		FROM #tblAssignmentUploading AS upload WITH (NOLOCK)
		WHERE ISNULL(upload.MaxBet, '') <> ''

		-- combine
		INSERT INTO #tblCombineInvalidMaxBet (
			RowNumber
			,ColumnName
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT '; ' + ColumnName
					FROM #tblAssignmentUploading WITH (NOLOCK)
					WHERE RowNumber = data.RowNumber
						AND IsValid = 0
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT DISTINCT RowNumber
			FROM #tblAssignmentUploading WITH (NOLOCK)
			WHERE IsValid = 0
			) AS data

		-- result
		SELECT @SessionId
			,upload.RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN maxbet.RowNumber IS NOT NULL THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN maxbet.RowNumber IS NOT NULL THEN REPLACE(@Message, '<content>', maxbet.ColumnName)
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
			LEFT JOIN #tblCombineInvalidMaxBet AS maxbet WITH (NOLOCK) ON upload.RowNumber = maxbet.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @MaxBet = data.MaxBet
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (MaxBet VARCHAR(200)) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNULL(@MaxBet, '') = ''
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

	DROP TABLE #tblCombineInvalidMaxBet
END