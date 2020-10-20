
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200929@Tyler
Task : Pre-Match enhancement
DB: bodb_OWP	

Revisions:
	20200929@Tyler: Alter DB - [Redmine: #142258]
*/

--
CREATE TABLE [dbo].[PreMatchNote]
([PreMatchNoteId]  [INT] IDENTITY(1, 1) NOT NULL, 
 [OWPLeagueId]     [INT] NULL, 
 [InfoSiteMatchId] [INT] NULL, 
 [EventDate]       [DATE] NOT NULL, 
 CONSTRAINT [PK_PreMatchNote] PRIMARY KEY CLUSTERED([PreMatchNoteId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

--
CREATE TABLE [dbo].[PreMatchNoteMessage]
([PreMatchNoteMessageId] [INT] IDENTITY(1, 1) NOT NULL, 
 [PreMatchNoteId]        [INT] NOT NULL, 
 [CreatedDate]           [DATETIME] NOT NULL, 
 [UserId]                [INT] NOT NULL, 
 [Message]               [NVARCHAR](2000) NOT NULL, 
 CONSTRAINT [PK_PreMatchNoteMessage] PRIMARY KEY CLUSTERED([PreMatchNoteMessageId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

--
ALTER TABLE [dbo].[PreMatchAssignment]
ADD AssignmentType TINYINT NOT NULL
                           DEFAULT(1), 
    AssignmentNote NVARCHAR(200);
ALTER TABLE [dbo].[PreMatchAssignment] DROP CONSTRAINT [PK_PreMatchAssignment];
ALTER TABLE [dbo].[PreMatchAssignment]
ADD CONSTRAINT [PK_PreMatchAssignment] PRIMARY KEY CLUSTERED([PreMatchLeagueId] ASC, [UserId] ASC, [Bettype] ASC, [IsTakeOver] ASC, [AssignmentType] ASC);

--
INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 39, 
              N'ShiftOtherAssignment', 
              10
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 39
       );
GO

--
INSERT INTO [dbo].[LogAction]
([ActionId], 
 [ModuleId], 
 [ModuleObjectId], 
 [ActionTypeId], 
 [ActionName], 
 [SPName], 
 [LogItems]
)
       SELECT 119, 
              10, 
              39, 
              2, 
              N'OWPPreMatchAssignmentUpdateOtherAssignment', 
              N'OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment', 
              N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /><row item="UserId" alias="uid" /><row item="Username" alias="un" /><row item="Bettype" alias="bt" /><row item="IsTakeOver" alias="ito" /><row item="AssignmentNote" alias="an" /></root>'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[LogAction]
           WHERE ActionId = 119
       );