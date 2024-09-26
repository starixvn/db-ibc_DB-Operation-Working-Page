/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber9] @SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(4000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 9: Missing HDP, O/U, LA trader
 DB: bodb_OWP

 Revisions:
    20180621@Leo.Vo: new structure of Upload Assignment - [Redmine: #92868]
	20180719@Raymond.Le: Modify rule follow new uploading structure, combine rule 9 + 10 + 15 - [Redmine: #92868]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId INT = 9
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(200)
		,@Username NVARCHAR(30)
		,@UserId INT
		,@AssignmentPosition NVARCHAR(100)
		,@Bettype INT
		,@BettypeHDP INT = 1
		,@BettypeOU INT = 3
		,@BettypeLA INT = - 1002
		,@idoc INT

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Passed'

	CREATE TABLE #tblAssignmentMissing (
		RowNumber INT
		,ColumnName NVARCHAR(100)
		,Trader NVARCHAR(100)
		)

	CREATE TABLE #tblCombineInvalidColumn (
		RowNumber INT
		,ColumnName NVARCHAR(MAX)
		)

	-- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @UserId = data.UserId
					,@Bettype = data.Bettype
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
				UserId INT
				,Bettype INT
				) AS data

		EXEC sp_xml_removedocument @idoc

		-- Get Assignee type
		SELECT @AssignmentPosition = CASE WHEN @Bettype = @BettypeHDP THEN 'Trader (HDP)'
								WHEN @Bettype = @BettypeOU THEN 'Trader (O/U)'
								WHEN @Bettype = @BettypeLA THEN 'LA'
								ELSE ''
								END

		IF ISNULL(@UserId, '') = ''
			--AND @Bettype = @Handicap --  Must check other condition If this rule run for all assignment
			--AND @AssignmentType = @Assignee
		BEGIN
			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', @AssignmentPosition) AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblAssignmentMissing

	DROP TABLE #tblCombineInvalidColumn
END