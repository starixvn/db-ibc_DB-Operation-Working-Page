
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
	20190110@Leo.Vo: New structure of Match offer - [Redmine: #107257]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 29
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@MatchOffer NVARCHAR(2000)
		,@idoc INT

	CREATE TABLE #tblMatchOffer (Value NVARCHAR(50))

	CREATE TABLE #tblRowMatchOffer (
		RowNumber INT
		,Value NVARCHAR(50)
		)

	CREATE TABLE #tblInvalidRowMatchOffer (
		RowNumber INT
		,Value NVARCHAR(50)
		)

	CREATE TABLE #tblInvalidRow (
		RowNumber INT
		,MatchOffer NVARCHAR(2000)
		)

	INSERT INTO #tblMatchOffer (Value)
	SELECT [Value]
	FROM dbo.RefResource
	WHERE RefName = 'MatchOffer'

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	-- edit
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

	DROP TABLE #tblRowMatchOffer

	DROP TABLE #tblInvalidRowMatchOffer

	DROP TABLE #tblInvalidRow
END