
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber12] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 12: Exceed trader working shift
 DB: bodb_OWP

 Revisions:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 12
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'
END
/*
GO
 GRANT EXECUTE ON [dbo].[OWP_ValidationRule_CheckRuleNumber12] TO [bodbOWPNet]      
GO
 GRANT VIEW DEFINITION ON [dbo].[OWP_ValidationRule_CheckRuleNumber12] TO [bodbOWPNet]      
GO
*/