
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20230104@Carlos.nguyen
Task : Provider arrangement log
DB: bodb_OWP

Revisions:
	20230104@Carlos.nguyen: provider arrangement log - [Redmine: #181896]
*/
-- Table 
CREATE TABLE [dbo].[ProviderArrangement]
([Id]    [INT] IDENTITY(1, 1) NOT NULL PRIMARY KEY, 
 [Value] VARCHAR(20), 
 [Order] [INT]
)

ON [OWP_Data];

--Log
INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 17, 
              'ProviderArrangement'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 17
       );
INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 45, 
              'ProviderArrangement', 
              17
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 45
       );
IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 130
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
    (130, 
     17, 
     45, 
     2, 
     N'OWP_ProviderArrangement_UpdateOderProvider', 
     N'OWP_ProviderArrangement_UpdateOderProvider', 
     N'<root><xml path="r/z"/><row item="Provider" alias="lProvider"/></root>'
    );

DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT;
        SET @StartRun = GETDATE();
		SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
EXEC dbo.OWP_WriteLog 
             @CreatorId = 0, 
             @SPName = 'OWP_ProviderArrangement_UpdateOderProvider', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @Data = '<r><z lProvider="RB2,BG,SM,RTS,BET,FC" lActionName="Initialize"/></r>', 
             @DataOld = null;

INSERT INTO ProviderArrangement
([Order], [Value])
VALUES(1, 'RB2'),
(2, 'BG'),
(3, 'SM'),
(4, 'RTS'),
(5, 'BET'),
(6, 'FC');

GO