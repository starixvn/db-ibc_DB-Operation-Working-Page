/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber29] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170810@Tim.Trinh
 Task : Rule number 29: Wrong value of Match Offer
 DB: bodb_OWP

 Revisions:
	20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180725@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 29
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@MatchOffer NVARCHAR(50)
		,@idoc INT

	CREATE TABLE #tblMatchOffer (Value NVARCHAR(50))

	INSERT INTO #tblMatchOffer (Value)
	VALUES ('KO+15')
		,('Fast Market')
		,('KO+15 Fast Market')

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
					WHEN ISNULL(MatchOffer, '') <> ''
						AND NOT EXISTS (
							SELECT 1
							FROM #tblMatchOffer WITH (NOLOCK)
							WHERE MatchOffer = Value
							)
						THEN @RuleResultType
					ELSE @Passed
					END
				) AS ResultType
			,(
				CASE 
					WHEN ISNULL(MatchOffer, '') <> ''
						AND NOT EXISTS (
							SELECT 1
							FROM #tblMatchOffer WITH (NOLOCK)
							WHERE MatchOffer = Value
							)
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

		SELECT TOP 1 @MatchOffer = MatchOffer
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (MatchOffer NVARCHAR(50)) AS data

		EXEC sp_xml_removedocument @idoc

		IF NOT EXISTS (
				SELECT 1
				FROM #tblMatchOffer WITH (NOLOCK)
				WHERE UPPER(@MatchOffer) = Value
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

	DROP TABLE #tblMatchOffer
END