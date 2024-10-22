/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber8] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(4000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 8: Invalid trader name, LA name
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: check match 15mins, 10mins
	20180416@leo.vo: check FM, AIO
	20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180719@Raymond.Le: Modify rule follow new uploading structure, combine rule 8 + 14 - [Redmine: #92868]
	20190405@Lita.Tang: Apply for the second account only (row 165,189) - [Redmine: #111068]
	20190513@Leo.Vo: do not assign closed account - [Redmine: #113333]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
	20240925@Los: No UM [Redmine: #209152]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 8
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@UserId INT
		,@Username NVARCHAR(30) = ''
		,@idoc INT
		,@SiteId INT

	SELECT @SiteId = 99

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

	CREATE TABLE #tblOtherTrader (
		RowNumber INT
		,Bettype INT
		,Trader NVARCHAR(200)
		,IsValid INT
		)

	CREATE TABLE #tblGroupOtherTrader (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,Bettype INT
		,IsValid INT
		)

	CREATE TABLE #tblInvalidOtherTrader (
		RowNumber INT
		,ColumnName NVARCHAR(2000)
		)

	-- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @Username = data.Username
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Username NVARCHAR(30)) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Username)

		IF LEN(@Username) > 0
			AND ISNULL(@UserId, 0) = 0
		BEGIN
			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', @Username) AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCombineInvalidTrader

	DROP TABLE #tblOtherTrader

	DROP TABLE #tblGroupOtherTrader

	DROP TABLE #tblInvalidOtherTrader
END