CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber24] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170310@Tim.Trinh
 Task : Rule number 24: Duplicate matches on the file
 DB: bodb_OWP

 Revisions:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 24
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Spread VARCHAR(200)
		,@idoc INT

	CREATE TABLE #tblCombineDuplicateMatch (
		RowNumber INT
		,RowNumbers VARCHAR(MAX)
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
		INSERT INTO #tblCombineDuplicateMatch (
			RowNumber
			,RowNumbers
			)
		SELECT data.RowNumber
			,STUFF((
					SELECT DISTINCT '; ' + CAST(RowNumber / 10 AS VARCHAR(50))
					FROM dbo.AssignmentUploading WITH (NOLOCK)
					WHERE SessionId = @SessionId
						AND RowNumber <> data.RowNumber
						AND EventDate = data.EventDate
						AND League = data.League
						AND Home = data.Home
						AND Away = data.Away
					FOR XML PATH('')
					), 1, 2, '')
		FROM (
			SELECT RowNumber
				,EventDate
				,League
				,Home
				,Away
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
			) AS data

		-- result
		SELECT @SessionId
			,RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN ISNULL(RowNumbers, '') <> '' THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN ISNULL(RowNumbers, '') <> '' THEN REPLACE(@Message, '<content>', RowNumbers)
				ELSE '' END
				) AS [Message]
		FROM #tblCombineDuplicateMatch WITH (NOLOCK)
	END
	ELSE -- edit
	BEGIN
		SELECT @Passed AS ResultType
			,'' AS [Message]
	END

	DROP TABLE #tblCombineDuplicateMatch
END