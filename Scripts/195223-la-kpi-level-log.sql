
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20231012@Mira
Task : LAKPI log
DB: bodb_OWP

Revisions:
	20231012@Mira: write log - [Redmine: #195223]
*/

-- Log
INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 18, 
              'LAKpi'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 18
       );
INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 46, 
              'LAKpi', 
              18
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 46
       );
IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 131
)
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
    (131, 
     18, 
     46, 
     2, 
     N'OWP_Kpi_UpdateTargetLevel', 
     N'OWP_Kpi_UpdateTargetLevel', 
     N'<root><xml path="r/z"/><row item="TargetId" alias="target"/></root>'
    );