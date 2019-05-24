/*
	Created: Leo.Vo
	Date: 20190521
	Task: [Redmine: #113763]
	DB: bodb_OWP
*/
--------------------------------
-- 2. Update data
--------------------------------
USE bodb_OWP

UPDATE dbo.[ModuleObject] WITH (ROWLOCK)
SET ModuleObjectName = 'EmployeeWorkingShiftDefault'
WHERE ModuleObjectId = 21

UPDATE dbo.[ModuleObject] WITH (ROWLOCK)
SET ModuleObjectName = 'EmployeeWorkingShift'
WHERE ModuleObjectId = 22

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (23, 'EmployeeWorkingShiftColor', 7)

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (24, 'EmployeeWorkingSettingTimeZone', 7)

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (25, 'EmployeeWorkingNote', 7)

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (26, 'EmployeeWorkingShiftOrder', 7)

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
	78
	,7
	,22
	,2
	,'OWP_EmployeeWorkingShift_UpdateShiftCode'
	,'OWP_EmployeeWorkingShift_UpdateShiftCode'
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftDate" alias="sd" /><row item="ShiftStartTime" alias="st" /><row item="ShiftEndTime" alias="et" /><row item="ShiftId" alias="sid" /><row item="RefShiftId" alias="rsid" /><row item="IsOvertime" alias="iot" /></root>'
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
	79
	,7
	,22
	,3
	,'OWP_EmployeeWorkingShift_RemoveShiftCode'
	,'OWP_EmployeeWorkingShift_RemoveShiftCode'
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftDate" alias="sd" /><row item="ShiftStartTime" alias="st" /><row item="ShiftEndTime" alias="et" /><row item="ShiftId" alias="sid" /><row item="RefShiftId" alias="rsid" /></root>'
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
	80
	,7
	,23
	,1
	,'OWP_EmployeeWorkingShift_QuickInsert_WorkingShiftColor'
	,'OWP_EmployeeWorkingShift_QuickInsert_WorkingShiftColor'
	,'<root><xml path="r/z" /><row item="ShiftId" alias="sid" /><row item="ShiftCode" alias="sc" /><row item="Background" alias="bg" /><row item="Color" alias="c" /><row item="StartTime" alias="st" /><row item="EndTime" alias="et" /><row item="IsTimeShift" alias="its" /></root>'
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
	81
	,7
	,23
	,3
	,'OWP_EmployeeWorkingShift_QuickDelete_WorkingShiftColor'
	,'OWP_EmployeeWorkingShift_QuickDelete_WorkingShiftColor'
	,'<root><xml path="r/z" /><row item="ShiftId" alias="sid" /><row item="ShiftCode" alias="sc" /><row item="Background" alias="bg" /><row item="Color" alias="c" /><row item="StartTime" alias="st" /><row item="EndTime" alias="et" /><row item="IsTimeShift" alias="its" /></root>'
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
	82
	,7
	,24
	,2
	,'OWP_EmployeeWorkingShiftTimeZone_UpdateUserSetting'
	,'OWP_EmployeeWorkingShiftTimeZone_UpdateUserSetting'
	,'<root><xml path="r/z" /><row item="UserId" alias="uid" /><row item="TimeZoneSettingId" alias="tzid" /></root>'
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
	83
	,7
	,25
	,2
	,'OWP_EmployeeWorkingShift_UpdateNote'
	,'OWP_EmployeeWorkingShift_UpdateNote'
	,'<root><xml path="r/z" /><row item="UserId" alias="uid" /><row item="note" alias="no" /></root>'
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
	84
	,7
	,23
	,1
	,'Task_OWP_SyncDefaultWorkingShift'
	,'Task_OWP_SyncDefaultWorkingShift'
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftDate" alias="sd" /><row item="ShiftId" alias="sid" /><row item="ShiftStartTime" alias="sst" /><row item="ShiftEndTime" alias="set" /></root>'
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
	85
	,7
	,23
	,2
	,'OWP_EmployeeWorkingShift_Upload'
	,'OWP_EmployeeWorkingShift_Upload'
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftDate" alias="sd" /><row item="ShiftId" alias="sid" /><row item="ShiftStartTime" alias="sst" /><row item="ShiftEndTime" alias="set" /><row item="RefShiftId" alias="rsid" /></root>'
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
	86
	,7
	,23
	,2
	,'OWP_EmployeeWorkingShiftColorUpd'
	,'OWP_EmployeeWorkingShiftColorUpd'
	,'<root><xml path="r/z" /><row item="ShiftId" alias="sid" /><row item="ShiftCode" alias="sc" /><row item="Background" alias="bg" /><row item="Color" alias="cl" /><row item="StartTime" alias="sst" /><row item="EndTime" alias="set" /><row item="IsTimeShift" alias="its" /></root>'
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
	87
	,7
	,23
	,2
	,'OWP_EmployeeWorkingShift_CopyWeekly'
	,'OWP_EmployeeWorkingShift_CopyWeekly'
	,'<root><xml path="r/z" /><row item="EmployeeId" alias="eid" /><row item="ShiftDate" alias="sd" /><row item="ShiftId" alias="sid" /><row item="ShiftStartTime" alias="sst" /><row item="ShiftEndTime" alias="set" /><row item="RefShiftId" alias="rsid" /></root>'
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
	88
	,7
	,23
	,2
	,'OWP_EmployeeWorkingShift_SaveOrder'
	,'OWP_EmployeeWorkingShift_SaveOrder'
	,'<root><xml path="r/z" /><row item="UserId" alias="uid" /><row item="EmployeeIds" alias="eids" /></root>'
	)

GO