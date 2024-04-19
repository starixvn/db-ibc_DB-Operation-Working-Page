
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240402@Johnny
Task : Add match assignees section for ticket
DB: bodb_OWP	

Revisions:
	20240402@Johnny: Init script - [Redmine: #202819]
*/

ALTER TABLE MatchInfo
ADD [Agent_EST]  NVARCHAR(2000), 
    [Remark_EST] NVARCHAR(2000), 
    [RemarkBy]   NVARCHAR(2000);
ALTER TABLE MatchInfo_Old
ADD [Agent_EST]  NVARCHAR(2000), 
    [Remark_EST] NVARCHAR(2000), 
    [RemarkBy]   NVARCHAR(2000);
INSERT INTO [dbo].[RefResource]
([RefName], 
 [ResourceId], 
 [Value], 
 [Order]
)
VALUES
('AssigneeType', 
 4, 
 'Match Assignees', 
 0
);
GO

CREATE TABLE [ProviderVerification]
([Id]            INT IDENTITY(1, 1) PRIMARY KEY, 
 [OWPMatchId]    INT, 
 [ESTNote]       NVARCHAR(4000), 
 [IsConfirmManual]      BIT
);

CREATE TABLE [MatchAgentConfirm]
([Id]            INT IDENTITY(1, 1) PRIMARY KEY, 
 [OWPMatchId] INT , 
 [AgentId] INT
)

CREATE TABLE [AgentOption]
([Id] INT IDENTITY(1, 1) PRIMARY KEY, 
 AgentId INT ,
 AgentName NVARCHAR(255)
)

INSERT INTO AgentOption (AgentId, AgentName)
VALUES (1, '365GV'), 
       (2, 'Betradar'), 
       (3, 'BG'), 
       (4, 'FC'), 
       (5, 'IMG'), 
       (6, 'RB2'), 
       (7, 'RB3'), 
       (8, 'RTS'), 
       (9, 'SLR'), 
       (10, 'WOO'),
       (11, 'Streaming'),
       (12, 'Cancel');


SET IDENTITY_INSERT TicketSubtype ON;
INSERT INTO TicketSubtype
(SubtypeId, 
SubtypeName, 
TypeId
)
VALUES
(27, 
'Provider Checking', 
4
);
SET IDENTITY_INSERT TicketSubtype OFF;

--- lOG ---- 

INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 19, 
              'Provider Verification'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 19
       );

INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 47, 
              'Provider Verification', 
              19
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 47
       );

IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 132
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
    (132, 
     19, 
     47, 
     2, 
     N'OWP_ProviderVerification_SaveAgentConfirm', 
     N'OWP_ProviderVerification_SaveAgentConfirm', 
     N'<root><xml path="r/z"/><row item="AgentConfirm" alias="agentConfirm"/></root>'
    );

	IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 133
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
    (133, 
     19, 
     47, 
     2, 
     N'OWP_ProviderVerification_SaveEstNote', 
     N'OWP_ProviderVerification_SaveEstNote', 
     N'<root><xml path="r/z"/><row item="EstNote" alias="estNote"/></root>'
    );