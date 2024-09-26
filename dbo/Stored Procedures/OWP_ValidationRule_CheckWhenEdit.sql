
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckWhenEdit] @OWPMatchId INT
	,@Bettype INT = NULL
	,@AssignmentType INT = NULL
	,@Username NVARCHAR(30) = ''
	,@UserId INT = NULL
	,@IsValidateAssignment BIT = NULL
	,@Phone NVARCHAR(200) = ''
AS
/*  
 Created: 20170214@Tim.Trinh
 Task : validation rule when edit
 DB: bodb_OWP
	@UserId: Assignee user id,
	@Username: Assignee name,
	@IsValidateAssignment: check is validate assignee or match info

 Revisions:
	20180927@Raymond.Le: New structure of event assignment - [Redmine: #92868]   
	20181128@Kane.Le: Fix bug single quote XML at Line 151 - [Redmine: #105043]   
	20190510@Kane.Le: Change phone length 200 - [Redmine: #112918]
 */
BEGIN
	SET NOCOUNT ON

	DECLARE @TotalRule SMALLINT
		,@RowIndex SMALLINT = 1
		,@sqlstring NVARCHAR(500)
		,@XmlDoc XML
		,@Value NVARCHAR(MAX)
		,@FunctionId INT
		,@IsParentMatch BIT
		,@BettypeHDP INT = 1
		,@BettypeOU INT = 3
		,@Bettype1X2 INT = 5
		,@Bettype1HHDP INT = 7
		,@Bettype1HOU INT = 8
		,@Bettype1H1X2 INT = 15
		,@BettypeLA INT = - 1002
		,@MainAssignment INT = 1
		,@OtherAssignment INT = 2

	CREATE TABLE #tblValidationRule (
		RowIndex SMALLINT IDENTITY(1, 1)
		,RuleId SMALLINT
		,SPName VARCHAR(200)
		)

	CREATE TABLE #tblValidationResult (
		ResultType TINYINT
		,[Message] NVARCHAR(MAX)
		)

	SET @IsParentMatch = CASE 
			WHEN EXISTS (
					SELECT 1
					FROM dbo.MinorMatch WITH (NOLOCK)
					WHERE MinorMatchId = @OWPMatchId
					)
				THEN 0
			ELSE 1
			END

	-- Get rules for specific bettype, assignment type or validate match info
	IF (@IsValidateAssignment = 1)
	BEGIN
		SET @FunctionId = CASE 
				WHEN @AssignmentType = @MainAssignment
					AND @Bettype IN (
						@BettypeHDP
						,@BettypeOU
						)
					AND @IsParentMatch = 1
					THEN 5
				WHEN @AssignmentType = @MainAssignment
					AND @Bettype IN (
						@Bettype1HHDP
						,@Bettype1HOU
						)
					AND @IsParentMatch = 1
					THEN 6
				WHEN @AssignmentType = @MainAssignment
					AND @Bettype IN (
						@Bettype1X2
						,@Bettype1H1X2
						)
					AND @IsParentMatch = 1
					THEN 7
				WHEN @AssignmentType = @MainAssignment
					AND @Bettype <> @BettypeLA
					AND @IsParentMatch = 0
					THEN 8
				WHEN @Bettype <> @BettypeLA
					THEN 4
				WHEN @AssignmentType = @MainAssignment
					AND @Bettype = @BettypeLA
					AND @IsParentMatch = 1
					THEN 10
				WHEN @AssignmentType = @MainAssignment
					AND @Bettype = @BettypeLA
					AND @IsParentMatch = 0
					THEN 11
				WHEN @Bettype = @BettypeLA
					THEN 9
				END
	END
	ELSE
	BEGIN
		SET @FunctionId = 12
	END

	INSERT INTO #tblValidationRule (
		RuleId
		,SPName
		)
	SELECT r.RuleId
		,r.SPName
	FROM dbo.[Function] AS f WITH (NOLOCK)
	INNER JOIN dbo.FunctionRule AS fr WITH (NOLOCK) ON f.FunctionId = fr.FunctionId
	INNER JOIN dbo.ValidationRule AS r WITH (NOLOCK) ON fr.RuleId = r.RuleId
		AND r.IsActive = 1
	WHERE f.FunctionId = @FunctionId

	-- Convert assignment data to Xml
	SET @XmlDoc = (
			SELECT @Bettype AS '@Bettype'
				,@AssignmentType AS '@AssignmentType'
				,@Username AS '@Username'
				,@UserId AS '@UserId'
				,@Phone AS '@Phone'
			FOR XML PATH('Row')
				,ROOT('Root')
			)
	SET @Value = REPLACE(CONVERT(NVARCHAR(MAX), @XmlDoc), '" />', '"/"')

	-- Loop run all rules
	SELECT @TotalRule = COUNT(1)
	FROM #tblValidationRule WITH (NOLOCK)

	WHILE @RowIndex <= @TotalRule
	BEGIN
		SELECT @sqlstring = SPName + N' @OWPMatchId = @OWPMatchId, @Value = @Value'
		FROM #tblValidationRule WITH (NOLOCK)
		WHERE RowIndex = @RowIndex;

		INSERT INTO #tblValidationResult (
			ResultType
			,Message
			)
		EXECUTE sys.sp_executesql @sqlstring
			,N'@OWPMatchId INT, @Value NVARCHAR(MAX)'
			,@OWPMatchId
			,@Value;

		SELECT @RowIndex = @RowIndex + 1
	END

	SELECT ResultType
		,[Message]
	FROM #tblValidationResult WITH (NOLOCK)

	DROP TABLE #tblValidationRule

	DROP TABLE #tblValidationResult
END