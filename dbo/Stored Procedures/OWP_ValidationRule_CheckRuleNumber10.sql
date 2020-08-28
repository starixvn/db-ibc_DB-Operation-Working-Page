/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber10] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 10: Missing O/U trader
 DB: bodb_OWP

 Revisions:
    20180725@Raymond.Le: Missing main assignment of {bet type} - [Redmine: #92868]
    20191113@Leo.Vo: handle setting to upload PH assignment - [Redmine: #123167]
	20200819@Mira: Archive plan for OWP tables - [Redmine: #137757]	
	20200830@Jacob: Delete unused code - [Redmine: #137757]
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

	-- edit	
	BEGIN
		SELECT @Passed AS ResultType
			,'' AS [Message]
	END
	

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCombineInvalidBettype
END