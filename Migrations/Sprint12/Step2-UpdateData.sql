/*
	Created: Raymond.Le
	Date: 2019-02-25
	Task: [Redmine: #108723]
	DB: bodb_OWP
*/

--------------------------------
-- 2. Update data
--------------------------------
USE bodb_OWP

-- remove similar time shift
DECLARE @tblSimilarTimeShift TABLE (
	ShiftId INT NOT NULL
	,StartTime TIME(7) NOT NULL
	,EndTime TIME(7) NOT NULL
	)

INSERT INTO @tblSimilarTimeShift (
	ShiftId
	,StartTime
	,EndTime
	)
SELECT MIN(ShiftId)
	,StartTime
	,EndTime
FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
GROUP BY StartTime
	,EndTime
	,IsTimeShift
HAVING COUNT(1) > 1
	AND IsTimeShift = 1

DECLARE @tblRemoveTimeShift TABLE (
	ShiftId INT NOT NULL
	,OriginalShiftId INT NOT NULL
	)

INSERT INTO @tblRemoveTimeShift (
	ShiftId
	,OriginalShiftId
	)
SELECT sc.ShiftId
	,ss.ShiftId
FROM dbo.EmployeeWorkingShiftColor AS sc WITH (NOLOCK)
	INNER JOIN @tblSimilarTimeShift AS ss ON sc.StartTime = ss.StartTime
	AND sc.EndTime = ss.EndTime
	AND sc.IsTimeShift = 1
WHERE sc.ShiftId <> ss.ShiftId

UPDATE s
SET s.ShiftId = rm.OriginalShiftId
FROM dbo.EmployeeWorkingShift AS s WITH (ROWLOCK)
	INNER JOIN @tblRemoveTimeShift AS rm ON s.ShiftId = rm.ShiftId
	
UPDATE s
SET s.ShiftId = rm.OriginalShiftId
FROM dbo.EmployeeWorkingShiftDefault AS s WITH (ROWLOCK)
	INNER JOIN @tblRemoveTimeShift AS rm ON s.ShiftId = rm.ShiftId

DELETE sc
FROM dbo.EmployeeWorkingShiftColor AS sc WITH (ROWLOCK)
	INNER JOIN @tblRemoveTimeShift AS rm ON sc.ShiftId = rm.ShiftId
GO

-- create time shift index
CREATE UNIQUE INDEX [IX_EmployeeWorkingShiftColor_TimeShift] ON [dbo].[EmployeeWorkingShiftColor] (
	[StartTime]
	,[EndTime]
	)
WHERE IsTimeShift = 1 ON [OWP_Index];


-- remove similar non-time shift
DECLARE @tblSimilarNonTimeShift TABLE (
	ShiftId INT NOT NULL
	,ShiftCode NVARCHAR(50) NOT NULL
	)

INSERT INTO @tblSimilarNonTimeShift (
	ShiftId
	,ShiftCode
	)
SELECT MIN(ShiftId)
	,ShiftCode
FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
GROUP BY ShiftCode
	,IsTimeShift
HAVING COUNT(1) > 1
	AND IsTimeShift = 0

DECLARE @tblRemoveNonTimeShift TABLE (
	ShiftId INT NOT NULL
	,OriginalShiftId INT NOT NULL
	)

INSERT INTO @tblRemoveNonTimeShift (
	ShiftId
	,OriginalShiftId
	)
SELECT sc.ShiftId
	,ss.ShiftId
FROM dbo.EmployeeWorkingShiftColor AS sc WITH (NOLOCK)
	INNER JOIN @tblSimilarNonTimeShift AS ss ON sc.ShiftCode = ss.ShiftCode
	AND sc.IsTimeShift = 0
WHERE sc.ShiftId <> ss.ShiftId

UPDATE s
SET s.ShiftId = rm.OriginalShiftId
FROM dbo.EmployeeWorkingShift AS s WITH (ROWLOCK)
	INNER JOIN @tblRemoveNonTimeShift AS rm ON s.ShiftId = rm.ShiftId
	
UPDATE s
SET s.ShiftId = rm.OriginalShiftId
FROM dbo.EmployeeWorkingShiftDefault AS s WITH (ROWLOCK)
	INNER JOIN @tblRemoveNonTimeShift AS rm ON s.ShiftId = rm.ShiftId

DELETE sc
FROM dbo.EmployeeWorkingShiftColor AS sc WITH (ROWLOCK)
	INNER JOIN @tblRemoveNonTimeShift AS rm ON sc.ShiftId = rm.ShiftId
GO

-- create non-time shift index
CREATE UNIQUE INDEX [IX_EmployeeWorkingShiftColor_NonTimeShift] ON [dbo].[EmployeeWorkingShiftColor] (
	[ShiftCode]
	)
WHERE IsTimeShift = 0 ON [OWP_Index];