CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckWhenEdit] @FunctionId INT
	,@OWPMatchId INT
	,@Value NVARCHAR(500)
AS
/*  
 Created: 20170214@Tim.Trinh
 Task : validation rule when edit
 DB: bodb_OWP
  
 Revisions:     
 */
BEGIN
	SET NOCOUNT ON

	DECLARE @TotalRule SMALLINT
		,@RowIndex SMALLINT = 1
		,@sqlstring NVARCHAR(500)

	CREATE TABLE #tblValidationRule (
		RowIndex SMALLINT IDENTITY(1, 1)
		,RuleId SMALLINT
		,SPName VARCHAR(200)
		)

	CREATE TABLE #tblValidationResult (
		ResultType TINYINT
		,[Message] NVARCHAR(MAX)
		)

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

	SELECT @TotalRule = COUNT(1)
	FROM #tblValidationRule WITH (NOLOCK)

	WHILE @RowIndex <= @TotalRule
	BEGIN
		SELECT @sqlstring = SPName + ' @OWPMatchId=' + CAST(@OWPMatchId AS VARCHAR(50)) + ',@Value=''' + @Value + ''''
		FROM #tblValidationRule WITH (NOLOCK)
		WHERE RowIndex = @RowIndex

		INSERT INTO #tblValidationResult (
			ResultType
			,[Message]
			)
		EXEC sp_executesql @sqlstring

		SET @RowIndex = @RowIndex + 1
	END

	SELECT ResultType
		,[Message]
	FROM #tblValidationResult WITH (NOLOCK)

	DROP TABLE #tblValidationRule
END