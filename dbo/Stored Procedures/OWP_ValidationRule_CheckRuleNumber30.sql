/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber30] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*  
 Created: 20171012@Tim.Trinh
 Task : Rule number 30: Invalid other time
 DB: bodb_OWP
 
 Revisions:
    20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 30
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@OtherTime VARCHAR(20)
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
					WHEN ISNULL(OtherTime, '') <> ''
						AND ISDATE(OtherTime) = 0
						THEN @RuleResultType
					ELSE @Passed
					END
				) AS ResultType
			,(
				CASE 
					WHEN ISNULL(OtherTime, '') <> ''
						AND ISDATE(OtherTime) = 0
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

		SELECT TOP 1 @OtherTime = data.OtherTime
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (OtherTime VARCHAR(20)) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNULL(@OtherTime, '') <> ''
			AND ISDATE(@OtherTime) = 0
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