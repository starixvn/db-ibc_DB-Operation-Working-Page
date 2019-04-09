/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Task_OWP_SyncDefaultWorkingShift]
	@CurrentDate DATETIME = NULL
AS
/*
Created: 20190213@Raymond.Le
Task : Auto insert default shift data to table EmployeeWorkingShift
DB: bodb_OWP

Revisions:
	20190213@Raymond.Le: Initial SP - [Redmine: #108723]
	20190409@Raymond.Le: Correct rule GMT+8 ShiftCode - [Redmine: #111068]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @CurrentDateGMTplus8 DATETIME
			,@NextWeekStartDate DATE

	SET @CurrentDate = ISNULL(@CurrentDate, GETDATE())
	SET @CurrentDateGMTplus8 = DATEADD(HOUR,12, @CurrentDate)
	SET @NextWeekStartDate = DATEADD(DAY, 7 + 2 - DATEPART(WEEKDAY, @CurrentDateGMTplus8), CAST(@CurrentDateGMTplus8 AS DATE))	 

	CREATE TABLE #tblEmployeeInsertedShift (
		UserId INT
	)

	CREATE TABLE #tblDefaultWorkingShift(
		UserId INT
		,ShiftId INT
		,ShiftDate DATE
		,ShiftStartDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndDate DATE
		,ShiftEndTime DATETIME
		,IsTimeShift BIT
	)

	-- Get list employee has inserted working shift in nextweek
	INSERT INTO #tblEmployeeInsertedShift(
		UserId
	)
	SELECT DISTINCT ws.EmployeeId
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
	WHERE ws.ShiftDate BETWEEN @NextWeekStartDate AND DATEADD(DAY, 6, @NextWeekStartDate)

	-- Insert default working shift from Monday to Sunday for all user (must ignore disable... user)
	INSERT INTO #tblDefaultWorkingShift(
		UserId
		,ShiftId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,IsTimeShift
	)
	SELECT u.UserId
		,ds.ShiftId
		,CASE WHEN ds.DayOfTheWeek = 1 THEN @NextWeekStartDate
			WHEN ds.DayOfTheWeek = 2 THEN DATEADD(DAY, 1, @NextWeekStartDate)
			WHEN ds.DayOfTheWeek = 3 THEN DATEADD(DAY, 2, @NextWeekStartDate)
			WHEN ds.DayOfTheWeek = 4 THEN DATEADD(DAY, 3, @NextWeekStartDate)
			WHEN ds.DayOfTheWeek = 5 THEN DATEADD(DAY, 4, @NextWeekStartDate)
			WHEN ds.DayOfTheWeek = 6 THEN DATEADD(DAY, 5, @NextWeekStartDate)
			WHEN ds.DayOfTheWeek = 7 THEN DATEADD(DAY, 6, @NextWeekStartDate)
			END	 AS ShiftDate
		,sc.StartTime
		,sc.EndTime
		,sc.IsTimeShift
	FROM dbo.[User] AS u WITH (NOLOCK)
	INNER JOIN dbo.EmployeeWorkingShiftDefault AS ds WITH (NOLOCK) ON u.UserId = ds.UserId
	LEFT JOIN dbo.EmployeeWorkingShiftColor AS sc WITH (NOLOCK) ON ds.ShiftId = sc.ShiftId
	WHERE NOT EXISTS (
		SELECT 1
		FROM #tblEmployeeInsertedShift AS ui  WITH (NOLOCK)
		WHERE ui.UserId = u.UserId
	)

	--Update shift start date
	UPDATE ds WITH (ROWLOCK, UPDLOCK)
	SET ds.ShiftStartDate = CASE WHEN DATEPART(HOUR, ds.ShiftStartTime) BETWEEN 1 AND 6 THEN DATEADD(DAY, 1, ds.ShiftDate)
								ELSE ds.ShiftDate END
	FROM #tblDefaultWorkingShift AS ds
	WHERE ds.IsTimeShift = 1

	--Update shift end date
	UPDATE ds WITH (ROWLOCK, UPDLOCK)
	SET ds.ShiftEndDate = CASE WHEN DATEPART(HOUR, ds.ShiftEndTime) < DATEPART(HOUR, ds.ShiftStartTime) THEN DATEADD(DAY, 1, ds.ShiftStartDate)
								ELSE ds.ShiftStartDate END
	FROM #tblDefaultWorkingShift AS ds
	WHERE ds.IsTimeShift = 1

	INSERT INTO dbo.EmployeeWorkingShift(
		EmployeeId
		,ShiftId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
	)
	SELECT ds.UserId
		,ds.ShiftId
		,ds.ShiftDate
		,ds.ShiftStartDate + ds.ShiftStartTime
		,ds.ShiftEndDate + ds.ShiftEndTime
	FROM #tblDefaultWorkingShift AS ds WITH (NOLOCK)
	WHERE ds.IsTimeShift = 1
	UNION

	SELECT ds.UserId
		,ds.ShiftId
		,ds.ShiftDate
		,NULL
		,NULL
	FROM #tblDefaultWorkingShift AS ds WITH (NOLOCK)
	WHERE ds.IsTimeShift = 0

	DROP TABLE #tblEmployeeInsertedShift
	DROP TABLE #tblDefaultWorkingShift
END