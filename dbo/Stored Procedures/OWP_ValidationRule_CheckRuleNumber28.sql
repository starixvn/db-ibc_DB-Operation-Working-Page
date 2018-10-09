/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber28] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170809@Tim.Trinh
 Task : Rule number 28: Wrong value of NO.HDP
 DB: bodb_OWP

 Revisions:
	20180621@Leo.Vo: new structure of Upload Assignment
	20180725@Raymond.Le: Modify rule follow new uploading structure
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 28
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@NoOfHDP NVARCHAR(20)
		,@idoc INT

	CREATE TABLE #tblNoOfHandicap (Value NVARCHAR(20))

	INSERT INTO #tblNoOfHandicap (Value)
	VALUES ('3HDP')
		,('2HDP')
		,('2+1H')
		,('1HDP')

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
				WHEN ISNULL(NoHDP, '') <> ''
					AND NOT EXISTS (
						SELECT 1
						FROM #tblNoOfHandicap WITH (NOLOCK)
						WHERE UPPER(REPLACE(NoHDP, ' ', '')) = Value
						) THEN @RuleResultType
				ELSE @Passed END
				) AS ResultType
			,(CASE 
				WHEN ISNULL(NoHDP, '') <> ''
					AND NOT EXISTS (
						SELECT 1
						FROM #tblNoOfHandicap WITH (NOLOCK)
						WHERE UPPER(REPLACE(NoHDP, ' ', '')) = Value
						) THEN @Message
				ELSE '' END
				) AS [Message]
		FROM dbo.AssignmentUploading WITH (NOLOCK)
		WHERE SessionId = @SessionId
	END
	ELSE -- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @NoOfHDP = NoOfHDP
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (NoOfHDP NVARCHAR(20)) AS data

		EXEC sp_xml_removedocument @idoc

		IF NOT EXISTS (
				SELECT 1
				FROM #tblNoOfHandicap WITH (NOLOCK)
				WHERE UPPER(REPLACE(LTRIM(RTRIM(@NoOfHDP)), ' ', '')) = Value
				)
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

	DROP TABLE #tblNoOfHandicap
END