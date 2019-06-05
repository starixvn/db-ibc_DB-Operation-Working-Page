/*
	Created: Kane.Le
	Date: 20190530
	Task: [Redmine: #112737]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Write Log
--------------------------------

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (27, 'EmployeeWorkingShiftPublish', 7)

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
	89
	,7
	,27
	,2
	,'OWP_EmployeeWorkingShiftPublish_Update'
	,'OWP_EmployeeWorkingShiftPublish_Update'
	,'<root><xml path="r/z" /><row item="SectionId" alias="sid" /><row item="FromDate" alias="frd" /><row item="ToDate" alias="tod" /><row item="IsPublished" alias="isp" /><row item="LastPublishedById" alias="uid" /><row item="LastPublishedDate" alias="lad" /></root>'
	)

GO