
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber25] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(4000) = NULL
AS
/*
 Created: 20170316@Tim.Trinh
 Task : Rule number 25: Duplicate employee name
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: check match 15mins, 10mins
    20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180725@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868]
	20190405@Lita.Tang: Apply for the second account only (row 162,218) - [Redmine: #111068]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 25
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@UserId INT
		,@Username NVARCHAR(30)
		,@idoc INT

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,Trader NVARCHAR(100)
		,IsValid BIT
		)

	CREATE TABLE #tblCombineInvalidTrader (
		RowNumber INT
		,Trader NVARCHAR(MAX)
		)

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

		SELECT TOP 1 @Username = data.Username
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Username NVARCHAR(30)) AS data

		EXEC sp_xml_removedocument @idoc

		IF (
				SELECT COUNT(1)
				FROM dbo.[User] AS u WITH (NOLOCK)
				WHERE u.IsSecondAccount = 0
					AND (
						u.Username = @Username
						OR u.Nickname = @Username
						)
				) > 1
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
END