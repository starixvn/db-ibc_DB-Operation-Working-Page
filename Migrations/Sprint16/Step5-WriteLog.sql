/*
	Created: Kane.Le
	Date: 20190508
	Task: [Redmine: #112737]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Write Log
--------------------------------

DECLARE @ModuleId INT,
@ModuleObjectId INT,
@ActionId INT
DECLARE @SPName NVARCHAR(50) ='OWP_EmployeeWorkingShift_CopySingleShift'
DECLARE @ModuleObjectName NVARCHAR(50) ='Copy Working Shift'
SELECT @ModuleObjectId = MAX(m.ModuleObjectId) FROM dbo.ModuleObject m WITH (NOLOCK)
SELECT @ModuleId = m.ModuleId FROM dbo.Module m WITH (NOLOCK) WHERE m.ModuleName='Working Shift'
--SELECT @ModuleId, @ModuleObjectId
IF NOT EXISTS (SELECT 1 FROM dbo.ModuleObject AS m WITH (NOLOCK) WHERE m.ModuleObjectName = @ModuleObjectName)
BEGIN

SET @ModuleObjectId = @ModuleObjectId + 1
INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (@ModuleObjectId  , 'Copy Working Shift', @ModuleId)
END

IF NOT EXISTS (SELECT 1 FROM dbo.LogAction AS l WITH (NOLOCK) WHERE l.SPName = @SPName)
BEGIN
SELECT @ActionId = MAX(m.ActionId) FROM dbo.LogAction m WITH (NOLOCK)
SET @ActionId = @ActionId + 1
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
	@ActionId
	,@ModuleId
	,@ModuleObjectId
	,2
	,@SPName
	,@SPName
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftDate" alias="sd" /><row item="ShiftStartTime" alias="st" /><row item="ShiftEndTime" alias="et" /><row item="ShiftId" alias="sid" /><row item="RefShiftId" alias="rsid" /></root>'
	)

END