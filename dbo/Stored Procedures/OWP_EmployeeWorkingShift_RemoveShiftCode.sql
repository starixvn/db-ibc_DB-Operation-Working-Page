
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
		,@IsJoinDefaultShift BIT
		,@GetCurrentWeek INT
		,@GetNextWeek INT		

	SELECT @GetCurrentWeek = DATEPART(WEEK, GETUTCDATE())	
	SELECT @GetNextWeek= DATEPART(WEEK,  DATEADD(dd, 0 - (@@DATEFIRST + 5 + DATEPART(dw, @ShiftDate)) % 7, @ShiftDate))

	IF @GetNextWeek > @GetCurrentWeek
	BEGIN
	SET @IsJoinDefaultShift = 1
	END
	ELSE
	BEGIN
	SET @IsJoinDefaultShift = 0
	END


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

	IF @IsJoinDefaultShift = 1
	BEGIN
	SET DATEFIRST 1;
	DECLARE @DateOfWeek INT = 1
	DECLARE	@TallyShiftDate AS TABLE (ShiftDate DATE)
	DECLARE @FromDate DATETIME = DATEADD(WEEK, DATEDIFF(DAY, 0, @ShiftDate)/7, 0)
    DECLARE @ToDate DATETIME =   DATEADD(WEEK, DATEDIFF(DAY, 0, @ShiftDate)/7, 6)
	
	CREATE TABLE #tmpEmployeeWorkingShiftDefault (
		UserId INT
		,DateOfWeek INT
		,ShiftId INT
		,ShiftDate DATE		 
		);

	WITH cte AS (
	SELECT	[rn] = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))- 1
	FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) x10(n) 
	)
	INSERT INTO @TallyShiftDate (ShiftDate)
	SELECT	[ShiftDate] = DATEADD(DAY, cte.rn, @FromDate)
	FROM	cte
	WHERE	cte.rn <= DATEDIFF(DAY, @FromDate, @ToDate)
	 	 
	INSERT INTO #tmpEmployeeWorkingShiftDefault
	SELECT u.UserId, ep.DayOfTheWeek, [ShiftId]=ISNULL(ep.ShiftId, 0), tally.ShiftDate
	
	FROM @TallyShiftDate AS tally 
	CROSS JOIN dbo.[User] AS u WITH (NOLOCK)
	LEFT JOIN dbo.EmployeeWorkingShiftDefault AS ep
			ON  ep.DayOfTheWeek = DATEPART(WEEKDAY, tally.ShiftDate)
			AND u.UserId = ep.UserId
			 

	SELECT TOP 1  [EmployeeId] = UserId
		,[ShiftId] = ISNULL(wk.ShiftId, df.ShiftId)
		,df.ShiftDate
		,[RefShiftId] = 0
		 ,[IsDefaultShift] = CASE 
				WHEN wk.ShiftId IS NULL
					THEN 1
				ELSE 0
				END
	FROM  #tmpEmployeeWorkingShiftDefault df
	LEFT JOIN dbo.EmployeeWorkingShift AS wk WITH (NOLOCK) ON df.UserId = wk.EmployeeId
		AND df.ShiftDate = wk.ShiftDate
		WHERE df.ShiftDate = @ShiftDate AND df.UserId = @EmployeeId

	DROP TABLE #tmpEmployeeWorkingShiftDefault	
	END
	ELSE
	BEGIN
	SELECT TOP 1  EmployeeId
			,ShiftId
			,ShiftDate
			,RefShiftId,
			[IsDefaultShift] =0 
		FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate = @ShiftDate

	END
	SET DATEFIRST 7
END