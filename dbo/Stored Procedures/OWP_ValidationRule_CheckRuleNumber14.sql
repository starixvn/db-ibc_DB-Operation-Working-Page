
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber14] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(2000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 14: Invalid LA name
 DB: bodb_OWP

 Revisions:
    20170427@Tim.Trinh: change Trader -> Suspender, trim value
	20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20190405@Lita.Tang: Apply for the second account only (row 111, 150) - [Redmine: #111068]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 14
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@UserId INT
		,@Trader NVARCHAR(100) = ''
		,@idoc INT

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,Trader NVARCHAR(100)
		,IsValid BIT
		)

	CREATE TABLE #tblCombineInvalidTrader (
		RowNumber INT
		,ColumnName NVARCHAR(MAX)
		)

	CREATE TABLE #tblOtherLA (
		RowNumber INT
		,LA NVARCHAR(200)
		,IsValid INT
		)

	CREATE TABLE #tblGroupOtherLA (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,IsValid INT
		)

	CREATE TABLE #tblInvalidOtherLA (
		RowNumber INT
		,ColumnName NVARCHAR(2000)
		)

	-- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Trader = LTRIM(RTRIM(Trader))
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Trader NVARCHAR(100)) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Trader)

		IF LEN(@Trader) > 0
			AND ISNULL(@UserId, 0) = 0
		BEGIN
			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', @Trader) AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCombineInvalidTrader
END