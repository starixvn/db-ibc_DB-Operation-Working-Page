/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20220111@Tyler
Task : Add new user role
DB: bodb_OWP	

Revisions:
	20220111@Tyler: Add new user role - [Redmine: #167285]
*/


INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           ('UserRole'
           ,7
           ,'Unit Head'
           ,7)
GO


