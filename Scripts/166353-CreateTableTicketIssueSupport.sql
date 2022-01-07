
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211231@Johnny.Thai
Task : Create table InfoSiteSoloMatch
DB: bodb_OWP	

Revisions:
	20211231@Johnny.Thai: Enhance Ticket Center - [Redmine: #166353]
*/

-- Table TicketIssueSupport
IF OBJECT_ID('dbo.TicketIssueSupport', 'U') IS NOT NULL
    DROP TABLE dbo.[TicketIssueSupport]; 
GO
CREATE TABLE [dbo].[TicketIssueSupport]
([Id]       [INT] IDENTITY(1, 1) NOT NULL, 
 [TicketId] [INT] NOT NULL, 
 [Subject]  [NVARCHAR](2000) NOT NULL, 
 CONSTRAINT [PK_TicketIssueSupport] PRIMARY KEY CLUSTERED([id] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

-- Table TicketType
IF OBJECT_ID('dbo.TicketType', 'U') IS NOT NULL
    DROP TABLE dbo.[TicketType]; 
GO
CREATE TABLE [dbo].[TicketType]
([TypeId]   [INT] NOT NULL, 
 [TypeName] [VARCHAR](50) NOT NULL, 
 CONSTRAINT [PK_TicketType] PRIMARY KEY CLUSTERED([TypeId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

--Insert Ticket Type
INSERT INTO [dbo].[TicketType]
([TypeId], 
 [TypeName]
)
VALUES
(1, 'Event Checking'),
(2, 'Others'),
(3, 'Ticket Support')
GO