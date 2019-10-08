
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber31] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20190923@Kane.Le
 Task : Rule number 31: Duplicate InfoSiteId on the file
 DB: bodb_OWP

 Revisions:
    20190923@Kane.Le: Init SP - [Redmine: #120415]	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 31
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Spread VARCHAR(200)
		,@idoc INT
		,@EventDate DATE

	CREATE TABLE #tblCombineDuplicateInfoSiteId (
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
		INSERT INTO #tblCombineDuplicateInfoSiteId (
			RowNumber
			,RowNumbers
			)
		SELECT data.RowNumber
			,(
				SELECT TOP 1 CAST(RowNumber / 10 AS VARCHAR(50))
				FROM dbo.AssignmentUploading WITH (NOLOCK)
				WHERE SessionId = @SessionId
					AND RowNumber <> data.RowNumber
					AND InfoSiteMatchId = data.InfoSiteMatchId
					AND ISNULL(InfoSiteMatchId, '') <> ''
				) AS RowNumbers
		FROM (
			SELECT RowNumber
				,EventDate
				,InfoSiteMatchId
			FROM dbo.AssignmentUploading WITH (NOLOCK)
			WHERE SessionId = @SessionId
				AND ISNULL(InfoSiteMatchId, '') <> ''
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
		FROM #tblCombineDuplicateInfoSiteId
	END
	ELSE -- edit
	BEGIN
		SELECT @Passed AS ResultType
			,'' AS [Message]
	END

	DROP TABLE #tblCombineDuplicateInfoSiteId
END