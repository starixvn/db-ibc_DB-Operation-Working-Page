/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
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

	-- upload
	IF LEN(@SessionId) > 0
	BEGIN
		-- Get match missing trader
		INSERT INTO #tblAssignmentMissing (
			RowNumber
			,ColumnName
			,Trader
			)
		SELECT unpvt.RowNumber
			,(
				CASE unpvt.ColumnName
					WHEN 'TraderHDP'
						THEN 'Trader (HDP)'
					WHEN 'TraderOU'
						THEN 'Trader (O/U)'
					WHEN 'LA'
						THEN 'LA'
					END
				) AS ColumnName
			,unpvt.Trader
		FROM (
			SELECT a.RowNumber
				,a.TraderHDP
				,a.TraderOU
				,a.LA
			FROM dbo.AssignmentUploading AS a WITH (NOLOCK)
			WHERE a.SessionId = @SessionId
			) AS upload
		UNPIVOT(Trader FOR ColumnName IN (
					TraderHDP
					,TraderOU
					,LA
					)) AS unpvt
		WHERE (unpvt.RowNumber % 10) = 0
			AND ISNULL(unpvt.Trader, '') = ''

		-- combine result column
		INSERT INTO #tblCombineInvalidColumn (
			RowNumber
			,ColumnName
			)
		SELECT DISTINCT am.RowNumber
			,STUFF((
					SELECT '; ' + data.ColumnName
					FROM #tblAssignmentMissing AS data WITH (NOLOCK)
					WHERE data.RowNumber = am.RowNumber
					FOR XML PATH('')
					), 1, 2, '')
		FROM #tblAssignmentMissing AS am WITH (NOLOCK)

		-- result
		SELECT @SessionId
			,upload.RowNumber
			,@RuleId AS RuleId
			,(
				CASE 
					WHEN ci.RowNumber IS NOT NULL
						THEN @RuleResultType
					ELSE @Passed
					END
				) AS ResultType
			,(
				CASE 
					WHEN ci.RowNumber IS NOT NULL
						THEN REPLACE(@Message, '<content>', ci.ColumnName)
					ELSE ''
					END
				) AS [Message]
		FROM dbo.AssignmentUploading AS upload WITH (NOLOCK)
		LEFT JOIN #tblCombineInvalidColumn AS ci WITH (NOLOCK) ON upload.RowNumber = ci.RowNumber
		WHERE upload.SessionId = @SessionId
	END
	ELSE -- edit
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