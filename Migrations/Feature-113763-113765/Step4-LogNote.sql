/*
	Created: Tyler.Dang
	Date: 20191016
	Task: [Redmine: #121901]
	DB: bodb_OWP
*/

INSERT INTO dbo.LogAction (ActionId	,ModuleId ,[ModuleObjectId]	,[ActionTypeId]	,[ActionName] ,[SPName]	,[LogItems])
VALUES (100, 7 ,25 ,1 ,'OWP_EmployeeWorkingShift_InsertNote' ,'OWP_EmployeeWorkingShift_InsertNote' ,'<root><xml path="r/z" /><row item="UserId" alias="ui" /><row item="CreatedDate" alias="cd" /><row item="Note" alias="nt" /><row item="ShiftDate" alias="sd" /></root>')

INSERT INTO dbo.LogAction (ActionId	,ModuleId ,[ModuleObjectId]	,[ActionTypeId]	,[ActionName] ,[SPName]	,[LogItems])
VALUES (101, 7 ,25 ,2 ,'OWP_EmployeeWorkingShift_UpdateNote' ,'OWP_EmployeeWorkingShift_UpdateNote' ,'<root><xml path="r/z" /><row item="CreatedDate" alias="cd" /><row item="Note" alias="nt" /><row item="CreatedBy" alias="cb" /></root>')

INSERT INTO dbo.LogAction (ActionId	,ModuleId ,[ModuleObjectId]	,[ActionTypeId]	,[ActionName] ,[SPName]	,[LogItems])
VALUES (102, 7 ,25 ,3 ,'OWP_EmployeeWorkingShift_DeleteNote' ,'OWP_EmployeeWorkingShift_DeleteNote' ,'<root><xml path="r/z" /><row item="CreatedDate" alias="cd" /><row item="Note" alias="nt" /><row item="CreatedBy" alias="cb" /><row item="ShiftDate" alias="sd" /><row item="UserId" alias="ui" /></root>')

GO
