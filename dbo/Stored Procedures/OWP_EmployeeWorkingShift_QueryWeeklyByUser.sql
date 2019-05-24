
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryWeeklyByUser] @EmployeeId INT
	,@FromDate DATE
	,@ToDate DATE
AS
/*      
 Created: 20190204@leo.vo  
 Task : Working Shift Management
 DB: bodb_OWP      
 
 Revisions:
     20190204@leo.vo: Initial SP  - [Redmine: #111068]
	 20190522@Kane.Le: Select default shift  - [Redmine: #113763]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsJoinDefaultShift BIT
		,@GetCurrentWeek INT
		,@GetNextWeek INT

	SELECT @GetCurrentWeek = DATEPART(WEEK, GETUTCDATE())

	SELECT @GetNextWeek = DATEPART(WEEK, DATEADD(dd, 0 - (@@DATEFIRST + 5 + DATEPART(dw, @FromDate)) % 7, @FromDate))

	SELECT @IsJoinDefaultShift = CASE 
			WHEN @GetNextWeek > @GetCurrentWeek
				THEN 1
			ELSE 0
			END

	IF @IsJoinDefaultShift = 1
	BEGIN
		SET DATEFIRST 1

		DECLARE @DateOfWeek INT = 1
		DECLARE @TallyShiftDate AS TABLE (ShiftDate DATE)

		CREATE TABLE #tmpEmployeeWorkingShiftDefault (
			UserId INT
			,DateOfWeek INT
			,ShiftId INT
			,ShiftDate DATE
			);

		WITH cte
		AS (
			SELECT [rn] = ROW_NUMBER() OVER (
					ORDER BY (
							SELECT NULL
							)
					) - 1
			FROM (
				VALUES (0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
				) x10(n)
			)
		INSERT INTO @TallyShiftDate (ShiftDate)
		SELECT [ShiftDate] = DATEADD(DAY, cte.rn, @FromDate)
		FROM cte
		WHERE cte.rn <= DATEDIFF(DAY, @FromDate, @ToDate)

		INSERT INTO #tmpEmployeeWorkingShiftDefault
		SELECT @EmployeeId
			,ep.DayOfTheWeek
			,[ShiftId] = ISNULL(ep.ShiftId, 0)
			,tally.ShiftDate
		FROM @TallyShiftDate AS tally
		LEFT JOIN dbo.EmployeeWorkingShiftDefault AS ep WITH (NOLOCK) ON ep.DayOfTheWeek = DATEPART(WEEKDAY, tally.ShiftDate)
			AND @EmployeeId = ep.UserId

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

		DROP TABLE #tmpEmployeeWorkingShiftDefault

		SET DATEFIRST 7
	END
	ELSE
	BEGIN
		SELECT EmployeeId
			,ShiftId
			,ShiftDate
			,ShiftStartTime
			,ShiftEndTime
			,RefShiftId
			,0 AS [IsDefaultShift]
		FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate >= @FromDate
			AND ShiftDate <= @ToDate
	END
END;