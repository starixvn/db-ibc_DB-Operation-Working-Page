/*
	Created: Leo.Vo
	Date: 2019-03-18
	Task: [Redmine: #110322]
	DB: bodb_OWP
*/

--------------------------------
-- 3. Add Index
--------------------------------
USE bodb_OWP

-- create time shift index
CREATE UNIQUE INDEX [IX_EmployeeWorkingShiftColor_TimeShift] ON [dbo].[EmployeeWorkingShiftColor] (
	[StartTime]
	,[EndTime]
	)
WHERE IsTimeShift = 1 ON [OWP_Index];

-- create non-time shift index
CREATE UNIQUE INDEX [IX_EmployeeWorkingShiftColor_NonTimeShift] ON [dbo].[EmployeeWorkingShiftColor] (
	[ShiftCode]
	)
WHERE IsTimeShift = 0 ON [OWP_Index];

-- create INDEX for EmployeeWorkingShiftOrder
CREATE CLUSTERED INDEX	CIX_EmployeeWorkingShiftOrder ON dbo.EmployeeWorkingShiftOrder (
							SectionId	ASC
						) ON OWP_Data;
GO
