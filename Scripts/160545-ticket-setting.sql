
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20210907@Mira
Task : Ticket Setting
DB: bodb_OWP	

Revisions:
	20210907@Mira: Create tables for ticket setting - [Redmine: #160545]
*/

-- Table RecipientGroup
IF OBJECT_ID('dbo.RecipientGroup', 'U') IS NOT NULL
    DROP TABLE dbo.[RecipientGroup]; 
GO
CREATE TABLE [dbo].[RecipientGroup]
([RecipientGroupId] [INT] IDENTITY(1, 1) NOT NULL, 
 [GroupId]          [INT] NOT NULL, 
 [RecipientId]      [INT] NOT NULL, 
 CONSTRAINT [PK_RecipientGroup_1] PRIMARY KEY CLUSTERED([RecipientGroupId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

-- Table TicketGroup
IF OBJECT_ID('dbo.TicketGroup', 'U') IS NOT NULL
    DROP TABLE dbo.[TicketGroup]; 
GO
CREATE TABLE [dbo].[TicketGroup]
([GroupId]   [INT] IDENTITY(1, 1) NOT NULL, 
 [GroupName] [VARCHAR](50) NOT NULL, 
 CONSTRAINT [PK_TicketGroup] PRIMARY KEY CLUSTERED([GroupId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

-- Table TicketType
IF OBJECT_ID('dbo.TicketType', 'U') IS NOT NULL
    DROP TABLE dbo.[TicketType]; 
GO
CREATE TABLE [dbo].[TicketType]
([TypeId]   [INT] IDENTITY(1, 1) NOT NULL, 
 [TypeName] [VARCHAR](50) NOT NULL, 
 CONSTRAINT [PK_TicketType] PRIMARY KEY CLUSTERED([TypeId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

-- Table TypeRecipient
IF OBJECT_ID('dbo.TypeRecipient', 'U') IS NOT NULL
    DROP TABLE dbo.[TypeRecipient]; 
GO
CREATE TABLE [dbo].[TypeRecipient]
([TicketTypeRecipientId] [INT] IDENTITY(1, 1) NOT NULL, 
 [TypeId]                [INT] NOT NULL, 
 [RecipientType]         [TINYINT] NOT NULL, 
 [RecipientId]           [INT] NOT NULL, 
 CONSTRAINT [PK_TypeRecipient] PRIMARY KEY CLUSTERED([TicketTypeRecipientId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO