CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber4] @SessionId NVARCHAR(100) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(MAX) = NULL
AS
/*  
 Created: 20170213@Tim.Trinh
 Task : Rule number 4: Missing home info
 DB: bodb_OWP
  
 Revisions:     
 */
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 4
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Home NVARCHAR(200)
		,@idoc INT

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
				WHEN ISNULL(Home, '') = '' THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN ISNULL(Home, '') = '' THEN @Message
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Home = data.Home
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Home NVARCHAR(200)) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNULL(@Home, '') = ''
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