/*
	Created: Leo.Vo
	Date: 20191011
	Task: [Redmine: #121765]
	DB: bodb_OWP
*/

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (29, 'UserRemark', 7)

INSERT INTO dbo.LogAction (ActionId	,ModuleId ,[ModuleObjectId]	,[ActionTypeId]	,[ActionName] ,[SPName]	,[LogItems])
VALUES (99, 7 ,29 ,2 ,'OWP_EmployeeWorkingShift_UpdateRemark' ,'OWP_EmployeeWorkingShift_UpdateRemark' ,'<root><xml path="r/z" /><row item="Category" alias="ca" /><row item="Remark" alias="rm" /></root>')
	
GO
