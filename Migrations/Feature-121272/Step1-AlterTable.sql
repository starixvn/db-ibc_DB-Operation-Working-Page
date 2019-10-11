/*
	Created: Kane.Le
	Date: 20191002
	Task: Alter table WorkingShiftColor [Redmine: #121272]
	DB: bodb_OWP
*/
USE bodb_OWP
ALTER TABLE EmployeeWorkingShiftColor
ADD Extension INT
	
GO

ALTER TABLE [dbo].[EmployeeWorkingShiftColor] ADD  CONSTRAINT [DF_EmployeeWorkingShiftColor_Extension]  DEFAULT (0) FOR [Extension]
GO

UPDATE dbo.EmployeeWorkingShiftColor SET Extension=0
GO

DROP INDEX [EmployeeWorkingShiftColor].IX_EmployeeWorkingShiftColor_TimeShift

CREATE UNIQUE NONCLUSTERED INDEX [IX_EmployeeWorkingShiftColor_TimeShift] ON [dbo].[EmployeeWorkingShiftColor]
(
	[StartTime] ASC,
	[EndTime] ASC,
	[Extension] ASC
)
WHERE ([IsTimeShift]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Index]
GO

DROP PROCEDURE dbo.OWP_EmployeeWorkingShiftColorIns;
DROP PROCEDURE dbo.OWP_AutoAssignment_DataExport;
GO  
