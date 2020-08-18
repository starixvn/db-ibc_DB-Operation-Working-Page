
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200811@Mira
Task : Pre-Match assignment
DB: bodb_OWP	

Revisions:
	20200811@Mira: Pre-Match assignment - [Redmine: #138643]
	20200818@Tyler: Pre-Match assignment log - [Redmine: #138643]
*/

INSERT INTO [dbo].[Module] ([ModuleId], [ModuleName])
VALUES (10, 'PreMatchAssignment');

INSERT INTO [dbo].[ModuleObject]([ModuleObjectId], [ModuleObjectName], [ModuleId])
VALUES (34, 'ShiftAssignment', 10);

INSERT INTO [dbo].[ModuleObject]([ModuleObjectId], [ModuleObjectName], [ModuleId])
VALUES (35, 'Remark', 10);

INSERT INTO [dbo].[ModuleObject]([ModuleObjectId], [ModuleObjectName], [ModuleId])
VALUES (36, 'League', 10);

INSERT INTO [dbo].[ModuleObject]([ModuleObjectId], [ModuleObjectName], [ModuleId])
VALUES (37, 'NightShiftStartTime', 10);

INSERT INTO [dbo].[LogActionType]([ActionTypeName])
VALUES ('Recover');

INSERT INTO [dbo].[LogAction]
([ActionId], 
 [ModuleId], 
 [ModuleObjectId], 
 [ActionTypeId], 
 [ActionName], 
 [SPName], 
 [LogItems]
)
VALUES
(113, 
 10, 
 34, 
 2, 
 N'OWPPreMatchAssignmentUpdateAssignment', 
 N'OWP_PreMatchAssignment_InsertUpdateDeleteAssignment', 
 N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /><row item="UserId" alias="uid" /><row item="Bettype" alias="bt" /><row item="IsTakeOver" alias="ito" /></root>'
),
(114, 
 10, 
 36, 
 3, 
 N'OWPPreMatchAssignmentDeleteLeague', 
 N'OWP_PreMatchAssignment_DeleteLeague', 
 N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /></root>'
),
(115, 
 10, 
 36, 
 4, 
 N'OWPPreMatchAssignmentRecoverLeague', 
 N'OWP_PreMatchAssignment_Recover', 
 N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /></root>'
),
(116, 
 10, 
 35, 
 2, 
 N'OWPPreMatchAssignmentUpdateRemark', 
 N'OWP_PreMatchAssignment_Update', 
 N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /><row item="Remark" alias="rm" /></root>'
),
(117, 
 10, 
 37, 
 2, 
 N'OWPPreMatchAssignmentUpdateStartTime', 
 N'OWP_PreMatchAssignment_UpdateStartTime', 
 N'<root><xml path="r/z" /><row item="Date" alias="d" /><row item="StartTime" alias="t" /></root>'
);


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'OWP_Infosite_TruncateCacheTable')
	DROP PROCEDURE OWP_Infosite_TruncateCacheTable
GO

