
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20200910@Tyler
Task : Event checking
DB: bodb_OWP	

Revisions:
	20200910@Tyler: Create tables for PreMatch issue - [Redmine: #140620]
*/
/****** Object:  Table [dbo].[PreMatchIssue]    Script Date: 9/10/2020 1:25:17 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
IF OBJECT_ID('dbo.PreMatchIssue', 'U') IS NOT NULL
    DROP TABLE dbo.[PreMatchIssue]; 
GO
CREATE TABLE [dbo].[PreMatchIssue]
([PreMatchIssueId] [INT] IDENTITY(1, 1) NOT NULL, 
 [OWPLeagueId]     [INT] NULL, 
 [InfoSiteMatchId] [INT] NULL, 
 [EventDate]       [DATE] NOT NULL, 
 [IsDone]          [BIT] NOT NULL, 
 CONSTRAINT [PK_PreMatchIssue] PRIMARY KEY CLUSTERED([PreMatchIssueId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

/****** Object:  Table [dbo].[PreMatchIssueMessage]    Script Date: 9/10/2020 1:25:18 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
IF OBJECT_ID('dbo.PreMatchIssueMessage', 'U') IS NOT NULL
    DROP TABLE dbo.[PreMatchIssueMessage]; 
GO
CREATE TABLE [dbo].[PreMatchIssueMessage]
([PreMatchIssueMessageId] [INT] IDENTITY(1, 1) NOT NULL, 
 [PreMatchIssueId]        [INT] NOT NULL, 
 [CreatedDate]            [DATETIME] NOT NULL, 
 [UserId]                 [INT] NOT NULL, 
 [Message]                [NVARCHAR](2000) NOT NULL, 
 CONSTRAINT [PK_PreMatchIssueMessage] PRIMARY KEY CLUSTERED([PreMatchIssueMessageId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

/****** Object:  Table [dbo].[PreMatchIssueReceiver]    Script Date: 9/10/2020 1:25:18 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
IF OBJECT_ID('dbo.PreMatchIssueReceiver', 'U') IS NOT NULL
    DROP TABLE dbo.[PreMatchIssueReceiver]; 
GO
CREATE TABLE [dbo].[PreMatchIssueReceiver]
([PreMatchIssueId] [INT] NOT NULL, 
 [UserId]          [INT] NOT NULL, 
 [IsRead]          [BIT] NOT NULL
                         CONSTRAINT [PK_PreMatchIssueReceiver] PRIMARY KEY CLUSTERED ([PreMatchIssueId] ASC, [UserId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

--Insert log data
INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 11, 
              N'EventChecking'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 11
       );
GO

INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 38, 
              N'Issue', 
              11
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 38
       );
GO

INSERT INTO [dbo].[LogAction]
([ActionId], 
 [ModuleId], 
 [ModuleObjectId], 
 [ActionTypeId], 
 [ActionName], 
 [SPName], 
 [LogItems]
)
       SELECT 118, 
              11, 
              38, 
              2, 
              N'OWPEventCheckingUpdateIssueDone', 
              N'OWP_EventChecking_UpdateIssueIsDone', 
              N'<root><xml path="r/z" /><row item="PreMatchIssueId" alias="pmiid" /><row item="IsDone" alias="d" /></root>'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[LogAction] WITH(NOLOCK)
           WHERE [ActionId] = 118
       );
GO