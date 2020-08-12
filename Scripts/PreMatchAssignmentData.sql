
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200811@Mira
Task : Pre-Match assignment
DB: bodb_OWP	

Revisions:
	20200811@Mira: Pre-Match assignment - [Redmine: #138643]
*/

INSERT INTO [dbo].[Module] ([ModuleId], [ModuleName])
VALUES (10, 'PreMatch Assignment');

INSERT INTO [dbo].[ModuleObject]([ModuleObjectId], [ModuleObjectName], [ModuleId])
VALUES (34, 'ShiftAssignment', 10);

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
 N'OWPShiftAssignmentUpdate', 
 N'OWPShiftAssignmentUpdate', 
 N'<root><xml path="r/z" /><row item="LeagueName" alias="l" /><row item="Value" alias="vl" /></root>'
),
(114, 
 10, 
 34, 
 3, 
 N'OWPShiftAssignmentDelete', 
 N'OWPShiftAssignmentDelete', 
 N'<root><xml path="r/z" /><row item="LeagueName" alias="l" /><row item="Value" alias="vl" /></root>'
),
(115, 
 10, 
 34, 
 4, 
 N'OWPShiftAssignmentRecover', 
 N'OWPShiftAssignmentRecover', 
 N'<root><xml path="r/z" /><row item="LeagueName" alias="l" /><row item="Value" alias="vl" /></root>'
);