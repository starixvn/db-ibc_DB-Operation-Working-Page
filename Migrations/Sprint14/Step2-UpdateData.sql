/*
	Created: Kane.Le
	Date: 2019-04-09
	Task: [Redmine: #111068]
	DB: bodb_OWP
*/
--------------------------------
-- 2. Update data
--------------------------------
USE bodb_OWP
-- Insert data log
INSERT INTO dbo.Module (
	ModuleId
	,ModuleName
	)
VALUES (
	7
	,'Working Shift'
	)

INSERT INTO dbo.ModuleObject (
	ModuleObjectId
	,ModuleObjectName
	,ModuleId
	)
VALUES (
	21
	,'DefaultWorkingShift'
	,7
	)

INSERT INTO dbo.LogAction (
	ActionId
	,ModuleId
	,[ModuleObjectId]
	,[ActionTypeId]
	,[ActionName]
	,[SPName]
	,[LogItems]
	)
VALUES (
	74
	,7
	,21
	,2
	,'OWP_EmployeeWorkingShift_UpdateDefaultShift'
	,'OWP_EmployeeWorkingShift_UpdateDefaultShift'
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftIds" alias="sids" /><row item="IsApplyCurrentWeek" alias="iacw" /><row item="FromDate" alias="fd" /><row item="ToDate" alias="td" /></root>'
	)

-- Update Data WorkingShift by new rule
DECLARE @RuleStartTime TIME = '01:00'
	,@RuleEndTime TIME = '06:00'

CREATE TABLE #tblTempEmployeeWorkingShift (
	ShiftId INT
	,ShiftDate DATE
	,ShiftStartDate DATE
	,ShiftEndDate DATE
	,StartTime TIME(7)
	,EndTime TIME(7)
	);

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
	AND wc.StartTime >= @RuleStartTime
	AND wc.StartTime <= @RuleEndTime

-- update Shift start date
UPDATE t
WITH (
		ROWLOCK
		,UPDLOCK
		)

SET t.ShiftStartDate = CASE WHEN DATEPART(HOUR, t.StartTime) BETWEEN 1 AND 6 THEN DATEADD(DAY, 1, t.ShiftDate)
		ELSE t.ShiftDate
		END
FROM #tblTempEmployeeWorkingShift AS t

-- update shift end date
UPDATE t
WITH (
		ROWLOCK
		,UPDLOCK
		)

SET t.ShiftEndDate = CASE WHEN DATEPART(HOUR, t.StartTime) > DATEPART(HOUR, t.EndTime)
			THEN DATEADD(DAY, 1, t.ShiftStartDate)
		ELSE t.ShiftStartDate
		END
FROM #tblTempEmployeeWorkingShift AS t

-- Update timeShift in EmployeeWorkingShift
UPDATE ws
WITH (
		ROWLOCK
		,UPDLOCK
		)

SET ws.ShiftStartTime = t.ShiftStartDate + CAST(t.StartTime AS DATETIME)
	,ws.ShiftEndTime = t.ShiftEndDate + CAST(t.EndTime AS DATETIME)
FROM dbo.[EmployeeWorkingShift] AS ws
INNER JOIN #tblTempEmployeeWorkingShift AS t WITH (NOLOCK) ON ws.ShiftId = t.ShiftId
	AND ws.ShiftDate = t.ShiftDate

DROP TABLE #tblTempEmployeeWorkingShift
GO


