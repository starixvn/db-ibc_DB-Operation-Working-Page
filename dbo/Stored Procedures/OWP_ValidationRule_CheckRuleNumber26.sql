CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber26] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170724@Tim.Trinh
 Task : Rule number 26: Invalid Cancel status
 DB: bodb_OWP

 Revisions:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 26
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@idoc INT

		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Inplay NVARCHAR(15) = 'In-play'
		,@str_Completed NVARCHAR(15) = 'Completed'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'

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
		SELECT @SessionId
			,RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN ISNULL(MatchStatus, '') = ''
					OR MatchStatus = @str_Live
					OR MatchStatus = @str_Inplay
					OR MatchStatus = @str_Completed
					OR MatchStatus = @str_Cancel
					OR MatchStatus = @str_Postponed
					OR MatchStatus = @str_Suspended
				THEN @Passed
				ELSE @RuleResultType END
				) AS ResultType
			,(CASE 
				WHEN ISNULL(MatchStatus, '') = ''
					OR MatchStatus = @str_Live
					OR MatchStatus = @str_Inplay
					OR MatchStatus = @str_Completed
					OR MatchStatus = @str_Cancel
					OR MatchStatus = @str_Postponed
					OR MatchStatus = @str_Suspended
				THEN ''
				ELSE @Message END
				) AS [Message]
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		SELECT @Passed AS ResultType
			,'' AS [Message]
	END
END