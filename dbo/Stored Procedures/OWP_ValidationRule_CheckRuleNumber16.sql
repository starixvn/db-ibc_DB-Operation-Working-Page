/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber16] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 16: Missing 2H LA
 DB: bodb_OWP

 Revisions:
    20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 16
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@LA NVARCHAR(100)
		,@Bettype INT
		,@AssignmentType TINYINT
		,@Assignee TINYINT
		,@BettypeLA INT = - 1002
		,@idoc INT

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
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @LA = data.Trader
			,@Bettype = data.Bettype
			,@AssignmentType = data.AssignmentType
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Trader NVARCHAR(100), Bettype INT, AssignmentType TINYINT) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNULL(@LA, '') = ''
			AND @Bettype = @BettypeLA
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
END