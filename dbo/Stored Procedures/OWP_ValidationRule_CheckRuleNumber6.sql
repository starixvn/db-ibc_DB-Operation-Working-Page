/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber6] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 6: Runner or Phone must be available
 DB: bodb_OWP
 
 Revisions:
	20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 6
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Phone NVARCHAR(50)
		,@Provider NVARCHAR(100)
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
					WHEN ISNULL([Provider], '') = ''
						AND ISNULL(Phone, '') = ''
						AND ISNULL(MinorBettypeId, '') = ''
						THEN @RuleResultType
					ELSE @Passed
					END
				) AS ResultType
			,(
				CASE 
					WHEN ISNULL([Provider], '') = ''
						AND ISNULL(Phone, '') = ''
						AND ISNULL(MinorBettypeId, '') = ''
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

		SELECT TOP 1 @Phone = data.Phone
			,@Provider = data.[Provider]
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
				Phone NVARCHAR(50)
				,[Provider] NVARCHAR(100)
				) AS data

		EXEC sp_xml_removedocument @idoc

		IF ISNULL(@Provider, '') = ''
			AND ISNULL(@Phone, '') = ''
			AND NOT EXISTS (
				SELECT 1
				FROM dbo.MinorMatch AS minor WITH (NOLOCK)
				INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON minor.MinorMatchId = m.OWPMatchId
				WHERE m.OWPMatchId = @OWPMatchId
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
END