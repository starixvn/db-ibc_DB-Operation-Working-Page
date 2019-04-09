/*
	Created: 
	Date: 
	Task: [Redmine: #111068]
	DB: bodb_OWP
*/
--------------------------------
-- 2. Update data
--------------------------------
USE bodb_OWP

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

