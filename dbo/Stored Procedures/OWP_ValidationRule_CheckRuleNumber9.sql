CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber9] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 9: Missing HDP trader
 DB: bodb_OWP

 Revisions:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 9
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@TraderHDP NVARCHAR(100)
		,@Bettype INT
		,@Handicap INT = 1
		,@AssignmentType TINYINT
		,@Assignee TINYINT
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

	-- upload
	IF LEN(@SessionId) > 0
	BEGIN
		SELECT @SessionId
			,RowNumber
			,@RuleId AS RuleId
			,(CASE 
				WHEN ISNULL(TraderHDP, '') = '' THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN ISNULL(TraderHDP, '') = '' THEN @Message
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @TraderHDP = data.Trader
			,@Bettype = data.Bettype
			,@AssignmentType = data.AssignmentType
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Trader NVARCHAR(100), Bettype INT, AssignmentType TINYINT) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNULL(@TraderHDP, '') = ''
			AND @Bettype = @Handicap
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