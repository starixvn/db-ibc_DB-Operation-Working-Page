
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber32] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20190923@Tyler.Dang
 Task : Rule number 32: Duplicate MatchNo. of matches
 DB: bodb_OWP

 Revisions:
    20190923@Tyler.Dang: Init SP - [Redmine: #120501]	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 32
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Spread VARCHAR(200)
		,@idoc INT
		,@EventDate DATE

	CREATE TABLE #tblCombineDuplicateMatchNo (
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
		INSERT INTO #tblCombineDuplicateMatchNo (
			RowNumber
			,RowNumbers
			)
		SELECT data.RowNumber
			,(
				SELECT TOP 1 CAST(RowNumber / 10 AS VARCHAR(50))
				FROM dbo.AssignmentUploading WITH (NOLOCK)
				WHERE SessionId = @SessionId
					AND RowNumber <> data.RowNumber
					AND MatchNo = data.MatchNo
					AND ISNULL(MatchNo, '') <> ''
				) AS RowNumbers
		FROM (
			SELECT RowNumber
				,EventDate
				,MatchNo
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
				AND ISNULL(MatchNo, '') <> ''
			) AS data

		-- result
		SELECT @SessionId
			,RowNumber
			,@RuleId AS RuleId
			,(
				CASE 
					WHEN ISNULL(RowNumbers, '') <> ''
						THEN @RuleResultType
					ELSE @Passed
					END
				) AS ResultType
			,(
				CASE 
					WHEN ISNULL(RowNumbers, '') <> ''
						THEN REPLACE(@Message, '<content>', RowNumbers)
					ELSE ''
					END
				) AS [Message]
		FROM #tblCombineDuplicateMatchNo WITH (NOLOCK)
	END
	ELSE -- edit
	BEGIN
		SELECT @Passed AS ResultType
			,'' AS [Message]
	END

	DROP TABLE #tblCombineDuplicateMatchNo
END