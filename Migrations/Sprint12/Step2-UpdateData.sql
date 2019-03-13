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

-- remove similar shift
DECLARE @tblSimilarShift TABLE (
	ShiftId INT NOT NULL
	,StartTime TIME(7) NOT NULL
	,EndTime TIME(7) NOT NULL
	,IsTimeShift BIT NOT NULL
	)

INSERT INTO @tblSimilarShift (
	ShiftId
	,StartTime
	,EndTime
	,IsTimeShift
	)
SELECT MIN(ShiftId)
	,StartTime
	,EndTime
	,IsTimeShift
FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
GROUP BY StartTime
	,EndTime
	,IsTimeShift
HAVING COUNT(1) > 1
	AND IsTimeShift <> 0

DECLARE @tblRemoveShift TABLE (
	ShiftId INT NOT NULL
	,OriginalShiftId INT NOT NULL
	)

INSERT INTO @tblRemoveShift (
	ShiftId
	,OriginalShiftId
	)
SELECT sc.ShiftId
	,ss.ShiftId
FROM dbo.EmployeeWorkingShiftColor AS sc WITH (NOLOCK)
	INNER JOIN @tblSimilarShift AS ss ON sc.StartTime = ss.StartTime
	AND sc.EndTime = ss.EndTime
	AND sc.IsTimeShift = ss.IsTimeShift
WHERE sc.ShiftId <> ss.ShiftId

UPDATE s
SET s.ShiftId = rm.OriginalShiftId
FROM dbo.EmployeeWorkingShift AS s WITH (ROWLOCK)
	INNER JOIN @tblRemoveShift AS rm ON s.ShiftId = rm.ShiftId

DELETE sc
FROM dbo.EmployeeWorkingShiftColor AS sc WITH (ROWLOCK)
	INNER JOIN @tblRemoveShift AS rm ON sc.ShiftId = rm.ShiftId
GO

-- create index
CREATE UNIQUE INDEX [IX_EmployeeWorkingShiftColor_TimeShift] ON [dbo].[EmployeeWorkingShiftColor] (
	[StartTime]
	,[EndTime]
	,[IsTimeShift]
	)
WHERE IsTimeShift = 1 ON [OWP_Index];

