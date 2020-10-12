/*
	Created: Leo.Vo
	Date: 2019-03-18
	Task: [Redmine: #110322]
	DB: bodb_OWP
*/

--------------------------------
-- 2. Update data
--------------------------------
USE bodb_OWP

CREATE TABLE #tblValidShift (
	ShiftId INT
	,StartTime TIME(7)
	,EndTime TIME(7)
	)

CREATE TABLE #tblDuplicatedShift (
	ShiftId INT
	,CorrectShiftId INT
	)

CREATE TABLE #tblTempEmployeeWorkingShift (
	ShiftId INT
	,ShiftDate DATE
	,ShiftStartDate DATE
	,ShiftEndDate DATE
	,StartTime TIME(7)
	,EndTime TIME(7)
	);

/* Correct timeShift */
-- ShiftCode 11->17
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '11:00:00'
	,EndTime = '17:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 65

-- ShiftCode 11->18
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '11:00:00'
	,EndTime = '18:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 66

-- ShiftCode 12:45->21
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '12:45:00'
	,EndTime = '21:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 76

-- ShiftCode 12->18
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '12:00:00'
	,EndTime = '18:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 77

-- ShiftCode 12->19
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '12:00:00'
	,EndTime = '19:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 78

-- ShiftCode 13->20
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '13:00:00'
	,EndTime = '20:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 86

-- ShiftCode 14->20
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '14:00:00'
	,EndTime = '20:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 95

-- ShiftCode 14->21
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '14:00:00'
	,EndTime = '21:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 96

-- ShiftCode 15 > 24
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '15:00:00'
	,EndTime = '00:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 97
	OR ShiftId = 103

-- ShiftCode 20->03
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '20:00:00'
	,EndTime = '03:00:00'
	,IsTimeShift = 1
WHERE ShiftId = 142

-- ShiftCode 21 >0230
UPDATE [dbo].[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET StartTime = '21:00:00'
	,EndTime = '02:30:00'
	,IsTimeShift = 1
WHERE ShiftId = 261

/************/
-- get list valid time shift
INSERT INTO #tblValidShift (
	ShiftId
	,StartTime
	,EndTime
	)
SELECT MIN(wc.ShiftId)
	,wc.StartTime
	,wc.EndTime
FROM dbo.[EmployeeWorkingShiftColor] AS wc WITH (NOLOCK)
WHERE EXISTS (
		SELECT 1
		FROM dbo.[EmployeeWorkingShiftColor] AS wc2 WITH (NOLOCK)
		WHERE wc.StartTime = wc2.StartTime
			AND wc.EndTime = wc2.EndTime
			AND wc.ShiftId <> wc2.ShiftId
		)
GROUP BY wc.StartTime
	,wc.EndTime

-- get list duplicated shift
INSERT #tblDuplicatedShift (
	ShiftId
	,CorrectShiftId
	)
SELECT wc.ShiftId
	,vs.ShiftId
FROM dbo.EmployeeWorkingShiftColor AS wc WITH (NOLOCK)
	INNER JOIN #tblValidShift AS vs WITH (NOLOCK) ON vs.StartTime = wc.StartTime
	AND vs.EndTime = wc.EndTime
WHERE wc.ShiftId <> vs.ShiftId

-- update table EmployeeWorkingShift
UPDATE ws WITH (ROWLOCK, UPDLOCK)
SET ws.ShiftId = ds.CorrectShiftId
FROM dbo.EmployeeWorkingShift AS ws
	INNER JOIN #tblDuplicatedShift AS ds WITH (NOLOCK) ON ws.ShiftId = ds.ShiftId

-- update table Default Shift 
UPDATE d WITH (ROWLOCK, UPDLOCK)
SET d.ShiftId = ds.CorrectShiftId
FROM dbo.EmployeeWorkingShiftDefault AS d
	INNER JOIN #tblDuplicatedShift AS ds WITH (NOLOCK) ON d.ShiftId = ds.ShiftId

--- Update 'KIV-PH'
UPDATE dbo.[EmployeeWorkingShift] WITH (ROWLOCK, UPDLOCK)
SET ShiftId = 183
WHERE ShiftId = 184

UPDATE dbo.EmployeeWorkingShiftDefault WITH (ROWLOCK, UPDLOCK)
SET ShiftId = 183
WHERE ShiftId = 184

/* Update ShiftStartTime, ShiftEndTime in table EmployeeWorkingShift */
INSERT INTO #tblTempEmployeeWorkingShift (
	ShiftId
	,ShiftDate
	,StartTime
	,EndTime
	)
SELECT DISTINCT ws.ShiftId
	,ws.ShiftDate
	,wc.StartTime
	,wc.EndTime
FROM dbo.[EmployeeWorkingShift] AS ws WITH (NOLOCK)
	INNER JOIN dbo.[EmployeeWorkingShiftColor] AS wc WITH (NOLOCK) ON ws.ShiftId = wc.ShiftId
WHERE wc.IsTimeShift = 1

-- update Shift start date
UPDATE t WITH (ROWLOCK, UPDLOCK)
SET t.ShiftStartDate = CASE 
		WHEN DATEPART(HOUR, t.StartTime) < 6 THEN DATEADD(DAY, 1, t.ShiftDate)
		ELSE t.ShiftDate
		END
FROM #tblTempEmployeeWorkingShift AS t

-- update shift end date
UPDATE t WITH (ROWLOCK, UPDLOCK)
SET t.ShiftEndDate = CASE 
		WHEN DATEPART(HOUR, t.StartTime) > DATEPART(HOUR, t.EndTime) THEN DATEADD(DAY, 1, t.ShiftStartDate)
		ELSE t.ShiftStartDate
		END
FROM #tblTempEmployeeWorkingShift AS t

-- Update timeShift in EmployeeWorkingShift
UPDATE ws WITH (ROWLOCK, UPDLOCK)
SET ws.ShiftStartTime = t.ShiftStartDate + CAST(t.StartTime AS DATETIME)
	,ws.ShiftEndTime = t.ShiftEndDate + CAST(t.EndTime AS DATETIME)
FROM dbo.[EmployeeWorkingShift] AS ws
	INNER JOIN #tblTempEmployeeWorkingShift AS t WITH (NOLOCK) ON ws.ShiftId = t.ShiftId
	AND ws.ShiftDate = t.ShiftDate

-- Update NON-timeshift in EmployeeWorkingShift
UPDATE ws WITH (ROWLOCK, UPDLOCK)
SET ws.ShiftStartTime = NULL
	,ws.ShiftEndTime = NULL
FROM dbo.[EmployeeWorkingShift] AS ws
	INNER JOIN dbo.EmployeeWorkingShiftColor AS wc WITH (NOLOCK) ON ws.ShiftId = wc.ShiftId
WHERE wc.IsTimeShift = 0

-- DELETE duplicate shift in EmployeeWorkingShiftColor
DELETE c
FROM dbo.EmployeeWorkingShiftColor AS c WITH (ROWLOCK, UPDLOCK)
WHERE EXISTS (
		SELECT 1
		FROM #tblDuplicatedShift AS d WITH (NOLOCK)
		WHERE d.ShiftId = c.ShiftId
		)

-- DELETE shift '-', 'KIV-PH'
DELETE c
FROM dbo.EmployeeWorkingShiftColor AS c WITH (ROWLOCK, UPDLOCK)
WHERE c.ShiftId IN (1, 184)

-- DELETE shift not existed in system
DELETE ws
FROM dbo.EmployeeWorkingShift AS ws WITH (ROWLOCK, UPDLOCK)
WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK)
		WHERE ws.ShiftId = c.ShiftId
		)

DELETE d
FROM dbo.EmployeeWorkingShiftDefault AS d WITH (ROWLOCK, UPDLOCK)
WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK)
		WHERE d.ShiftId = c.ShiftId
		)
		
-- set shiftCode = '' if isTimeShift
UPDATE dbo.[EmployeeWorkingShiftColor] WITH (ROWLOCK, UPDLOCK)
SET ShiftCode = ''
WHERE IsTimeShift = 1

DROP TABLE #tblValidShift

DROP TABLE #tblDuplicatedShift

DROP TABLE #tblTempEmployeeWorkingShift

GO
