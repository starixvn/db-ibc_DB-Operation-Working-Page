
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240801@Carlos.nguyen
Task : Remove/insert league setting
DB: bodb_OWP

Revisions:
	20240801@Los: Remove/insert special product   - [Redmine: #207942]
*/

------------- log ------------------

INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 50, 
              'RemoveSpecialProduct'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 50
       );
GO

INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 51, 
              'AddSpecialProduct'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 51
       );
GO


INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 70, 
              'RemoveSpecialProduct', 
              50
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 70
       );
GO

INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 71, 
              'AddSpecialProduct', 
              51
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 71
       );
GO

IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 150
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
    (150, 
     50, 
     70, 
     3, 
     N'OWP_EventPicking_RemoveSpecialProduct', 
     N'OWP_EventPicking_RemoveSpecialProduct', 
     N'<root><xml path="r/z"/><row item="ParentMatchId" />
				<row item="MinorBettypeId" />
				<row item="NoOfHDP" />
				<row item="MaxbetHDP" />
				<row item="SpreadHDP" />
				<row item="SpreadOU" />
				</root>'
    );
GO

IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 151
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
    (151, 
     51, 
     71, 
     1, 
     N'OWP_EventPicking_AddSpecialProduct', 
     N'OWP_EventPicking_AddSpecialProduct', 
     N'<root><xml path="r/z"/><row item="ParentMatchId" />
				<row item="MinorBettypeId" />
				<row item="NoOfHDP" />
				<row item="MaxbetHDP" />
				<row item="SpreadHDP" />
				<row item="SpreadOU" />
				</root>'
    );
GO