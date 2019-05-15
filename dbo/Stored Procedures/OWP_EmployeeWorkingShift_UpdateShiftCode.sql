
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateShiftCode] @ActorId INT
	,@EmployeeId INT
	,@ShiftId INT
	,@ShiftDate DATE
	,@IsOvertime BIT = 0
AS
/*    
 Created: 20180914@Kane.Le
 Task : Edit working shift by date
 DB: bodb_OWP
 
Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
	20190215@Leo.Vo: Init default shift - [Redmine: #108723]
	20190312@Leo.Vo: Add overtime - [Redmine: #109560]
	20190409@Raymond.Le: Correct rule ShiftCode GMT+8 - [Redmine: #111068]
	20190515@Kane.Le: Change follow assign shift in next week - [Redmine: #112737]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartTime TIME(7)
		,@EndTime TIME(7)
		,@IsTimeShift BIT
		,@ShiftStartTime DATETIME = NULL
		,@ShiftEndTime DATETIME = NULL
		,@StartDate DATE
		,@EndDate DATE
		,@IsInit BIT
		,@DayOfTheWeek INT

		,@IsJoinDefaultShift BIT
		,@GetCurrentWeek INT
		,@GetNextWeek INT		

	SELECT @GetCurrentWeek = DATEPART(wk, GETUTCDATE())	
	SELECT @GetNextWeek= DATEPART(wk,  DATEADD(dd, 0 - (@@DATEFIRST + 5 + DATEPART(dw, @ShiftDate)) % 7, @ShiftDate))

	IF @GetNextWeek > @GetCurrentWeek
	BEGIN
	SET @IsJoinDefaultShift = 1
	END
	ELSE
	BEGIN
	SET @IsJoinDefaultShift = 0
	END
	
	
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
		


	-- check condition to init default shift weekly
	SELECT @StartDate = StartDate
		,@EndDate = EndDate
		,@IsInit = IsInit
	FROM dbo.fnc_CheckToInitDefaultShiftWeekly(@EmployeeId, @ShiftDate)

	SELECT @StartTime = StartTime
		,@EndTime = EndTime
		,@IsTimeShift = IsTimeShift
	FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
	WHERE ShiftId = @ShiftId

	IF @IsTimeShift = 1
	BEGIN
		SELECT @ShiftStartTime = @ShiftDate + CAST(@StartTime AS DATETIME)
			,@ShiftEndTime = @ShiftDate + CAST(@EndTime AS DATETIME)

		IF DATEPART(HOUR, @StartTime) BETWEEN 1 AND 6
		BEGIN
			SELECT @ShiftStartTime = DATEADD(DAY, 1, @ShiftStartTime)
				,@ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
		END
		
		IF @StartTime > @EndTime
		BEGIN
			SET @ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
		END
	END

	-- try to update
	UPDATE dbo.EmployeeWorkingShift WITH (ROWLOCK)
	SET RefShiftId = (CASE 
			WHEN @IsOvertime = 1 THEN CASE 
					WHEN RefShiftId IS NULL THEN ShiftId
					ELSE RefShiftId
					END
			ELSE NULL END
			)
		,ShiftId = @ShiftId
		,ShiftStartTime = @ShiftStartTime
		,ShiftEndTime = @ShiftEndTime
	WHERE EmployeeId = @EmployeeId
		AND ShiftDate = @ShiftDate

	-- no working shift updated then should insert
	IF @@ROWCOUNT = 0
		
	BEGIN
		IF @IsJoinDefaultShift = 1 AND @IsOvertime = 1
		BEGIN
		DECLARE @RefShiftId INT = NULL

		SET DATEFIRST 1;
		WITH cte AS (
	SELECT	[rn] = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))- 1
	FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) x10(n) 
)
INSERT INTO @TallyShiftDate (ShiftDate)
SELECT	[ShiftDate] = DATEADD(DAY, cte.rn, @FromDate)
FROM	cte
WHERE	cte.rn <= DATEDIFF(DAY, @FromDate, @ToDate)

		INSERT INTO #tmpEmployeeWorkingShiftDefault
		SELECT u.UserId, ep.DayOfTheWeek, [ShiftId]=ISNULL(ep.ShiftId, 0), tally.ShiftDate from @TallyShiftDate AS tally 
		CROSS JOIN dbo.[User] AS u WITH (NOLOCK)
		LEFT JOIN dbo.EmployeeWorkingShiftDefault AS ep
				ON  ep.DayOfTheWeek = DATEPART(WEEKDAY, tally.ShiftDate)
				AND u.UserId = ep.UserId
				WHERE u.UserId = @EmployeeId 
		SELECT @RefShiftId = tmp.ShiftId from #tmpEmployeeWorkingShiftDefault as tmp
							WHERE tmp.ShiftDate = @ShiftDate AND tmp.UserId = @EmployeeId
		END
		 
		INSERT INTO dbo.EmployeeWorkingShift (
			EmployeeId
			,ShiftId
			,ShiftDate
			,ShiftStartTime
			,ShiftEndTime
			,RefShiftId
			)
		VALUES (
			@EmployeeId
			,@ShiftId
			,@ShiftDate
			,@ShiftStartTime
			,@ShiftEndTime
			,@RefShiftId
			);
	END
	
	-- init default shift weekly
	/*
	IF @IsInit = 1
	BEGIN	 
		EXECUTE dbo.[OWP_EmployeeWorkingShift_InitDefaultShiftForWeek] @EmployeeId = @EmployeeId
			,@StartDate = @StartDate
			,@EndDate = @EndDate
			 
	END
	*/
 
	

	IF @IsJoinDefaultShift = 1
	BEGIN
	SET DATEFIRST 1;
	WITH cte AS (
	SELECT	[rn] = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))- 1
	FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) x10(n) 
	)
	INSERT INTO @TallyShiftDate (ShiftDate)
	SELECT	[ShiftDate] = DATEADD(DAY, cte.rn, @FromDate)
	FROM	cte
	WHERE	cte.rn <= DATEDIFF(DAY, @FromDate, @ToDate)
	TRUNCATE TABLE #tmpEmployeeWorkingShiftDefault
	INSERT INTO #tmpEmployeeWorkingShiftDefault
	SELECT u.UserId, ep.DayOfTheWeek, [ShiftId]=ISNULL(ep.ShiftId, 0), tally.ShiftDate from @TallyShiftDate AS tally 
	CROSS JOIN dbo.[User] AS u WITH (NOLOCK)
	LEFT JOIN dbo.EmployeeWorkingShiftDefault AS ep
			ON  ep.DayOfTheWeek = DATEPART(WEEKDAY, tally.ShiftDate)
			AND u.UserId = ep.UserId
			WHERE u.UserId = @EmployeeId

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
	LEFT JOIN dbo.EmployeeWorkingShiftColor AS wsc WITH (NOLOCK) ON df.ShiftId = wsc.ShiftId
	LEFT JOIN dbo.EmployeeWorkingShift AS wk WITH (NOLOCK) ON df.UserId = wk.EmployeeId
		AND df.ShiftDate = wk.ShiftDate
	
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

	DROP TABLE #tmpEmployeeWorkingShiftDefault

END