/*
	Created: Kane.Le
	Date: 20190508
	Task: [Redmine: #112737]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Write Log
--------------------------------

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (22, 'Copy Working Shift', 7)

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
	77
	,7
	,22
	,2
	,'OWP_EmployeeWorkingShift_CopySingleShift'
	,'OWP_EmployeeWorkingShift_CopySingleShift'
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftDate" alias="sd" /><row item="ShiftStartTime" alias="st" /><row item="ShiftEndTime" alias="et" /><row item="ShiftId" alias="sid" /><row item="RefShiftId" alias="rsid" /></root>'
	)

GO