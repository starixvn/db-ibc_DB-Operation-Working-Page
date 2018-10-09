/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber5] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*  
 Created: 20170213@Tim.Trinh
 Task : Rule number 5: Missing away info
 DB: bodb_OWP
  
 Revisions:
	20180621@Leo.Vo: new structure of Upload Assignment
 */
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 5
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Away NVARCHAR(200)
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
			,(
				CASE 
					WHEN ISNULL(Away, '') = ''
						THEN @RuleResultType
					ELSE @Passed
					END
				) AS ResultType
			,(
				CASE 
					WHEN ISNULL(Away, '') = ''
						THEN @Message
					ELSE ''
					END
				) AS [Message]
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Away = data.Away
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Away NVARCHAR(200)) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNULL(@Away, '') = ''
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