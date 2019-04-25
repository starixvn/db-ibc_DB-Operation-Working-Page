/*
	Created: Raymond.Le
	Date: 2019-04-25
	Task: [Redmine: #111840]
	DB: bodb_OWP
*/
--------------------------------
-- 1. Update data
--------------------------------
USE bodb_OWP

-- Insert data log
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
	75
	,7
	,21
	,2
	,'OWP_EmployeeWorkingShift_CopyWholeShifts'
	,'OWP_EmployeeWorkingShift_CopyWholeShifts'
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftDate" alias="sd" /><row item="ShiftStartTime" alias="st" /><row item="ShiftEndTime" alias="et" /><row item="ShiftId" alias="sid" /><row item="RefShiftId" alias="rsid" /></root>'
	),
(
	76
	,7
	,21
	,3
	,'OWP_EmployeeWorkingShift_DeleteWholeShifts'
	,'OWP_EmployeeWorkingShift_DeleteWholeShifts'
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftDate" alias="sd" /><row item="ShiftStartTime" alias="st" /><row item="ShiftEndTime" alias="et" /><row item="ShiftId" alias="sid" /><row item="RefShiftId" alias="rsid" /></root>'
	)