
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
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
	20200830@Jacob: Delete unused code - [Redmine: #137757]
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

	-- edit
	BEGIN
		SELECT @Passed AS ResultType
			,'' AS [Message]
	END

	DROP TABLE #tblCombineDuplicateInfoSiteId
END