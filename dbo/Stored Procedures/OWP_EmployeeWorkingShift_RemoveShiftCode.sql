
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_RemoveShiftCode] @EmployeeId INT
	,@ShiftDate DATE
AS
/*    
 Created: 20181106@Kane.Le
 Task : Remove working shift code - [Redmine: #104291]
 DB: bodb_OWP
 
Revisions:
	 20181106@Kane.Le: Initial SP - [Redmine: #104291]
	 20190215@Leo.Vo: Init default shift - [Redmine: #108723]
	 20190312@Leo.Vo: Add overtime - [Redmine: #109560]
	 20190513@Kane.Le: Change rule get default shift - [Redmine: #112737]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartDate DATE
		,@EndDate DATE
		,@IsInit BIT
		,@SectionId INT

	-- check condition to init default shift weekly
	SELECT @StartDate = StartDate
		,@EndDate = EndDate
		,@IsInit = IsInit
	FROM dbo.fnc_CheckToInitDefaultShiftWeekly(@EmployeeId, @ShiftDate)

	IF @IsInit = 1
	BEGIN
		EXECUTE dbo.[OWP_EmployeeWorkingShift_InitDefaultShiftForWeek] @EmployeeId = @EmployeeId
			,@StartDate = @StartDate
			,@EndDate = @EndDate
	END

	UPDATE EmployeeWorkingShift WITH (ROWLOCK)
	SET ShiftId = RefShiftId
		,ShiftStartTime = NULL
		,ShiftEndTime = NULL
		,RefShiftId = NULL
	WHERE EmployeeId = @EmployeeId
		AND ShiftDate = @ShiftDate
		AND RefShiftId IS NOT NULL

	IF @@ROWCOUNT = 0
	BEGIN
		DELETE
		FROM EmployeeWorkingShift WITH (ROWLOCK)
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate = @ShiftDate
	END

	DECLARE @IsJoinDefaultShift BIT
	DECLARE @GetCurrentWeek INT,
			@GetNextWeek INT
	
	SELECT @GetCurrentWeek = DATEPART(wk, GETUTCDATE())	
	SELECT @GetNextWeek= DATEPART(wk,  DATEADD(dd, 0 - (@@DATEFIRST + 5 + DATEPART(dw, @StartDate)) % 7, @StartDate))

	IF @GetNextWeek > @GetCurrentWeek
	BEGIN
	SET @IsJoinDefaultShift = 1
	END
	ELSE
	BEGIN
	SET @IsJoinDefaultShift = 0
	END

	IF @IsJoinDefaultShift = 1
	BEGIN
	CREATE TABLE #tmpEmployeeWorkingShiftDefault (
		UserId INT
		,DateOfWeek INT
		,ShiftId INT
		,ShiftDate DATE
		)

	INSERT INTO #tmpEmployeeWorkingShiftDefault
	SELECT ep.UserId
		,ep.DayOfTheWeek
		,ep.ShiftId
		,DATEADD(d, (ep.DayOfTheWeek - 1), @StartDate) FromDate
	FROM dbo.EmployeeWorkingShiftDefault AS ep
	WHERE ep.UserId = @EmployeeId

	SELECT [EmployeeId] = df.UserId
		,[ShiftDate] = df.ShiftDate
		,[ShiftStartTime] = ISNULL(wk.ShiftStartTime, df.ShiftDate + CAST(wsc.StartTime AS DATETIME))
		,[ShiftEndTime] = ISNULL(wk.ShiftEndTime, df.ShiftDate + CAST(wsc.EndTime AS DATETIME))
		,[ShiftId] = ISNULL(wk.ShiftId, df.ShiftId)
		,[RefShiftId] = wk.RefShiftId
		,[IsDefaultShift] = CASE 
			WHEN wk.ShiftId IS NULL
				THEN 1
			ELSE 0
			END
	FROM #tmpEmployeeWorkingShiftDefault AS df WITH (NOLOCK)
	JOIN dbo.EmployeeWorkingShiftColor AS wsc WITH (NOLOCK) ON df.ShiftId = wsc.ShiftId
	LEFT JOIN dbo.EmployeeWorkingShift AS wk WITH (NOLOCK) ON df.UserId = wk.EmployeeId
		AND df.ShiftDate = wk.ShiftDate		 
		DROP TABLE #tmpEmployeeWorkingShiftDefault
	END
	ELSE
	BEGIN
		SELECT   EmployeeId
			,ShiftId
			,ShiftDate
			,RefShiftId,
			[IsDefaultShift] =0 
		FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate BETWEEN @StartDate
				AND @EndDate
	END
END