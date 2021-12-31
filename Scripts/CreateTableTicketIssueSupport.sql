
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211231@Johnny.Thai
Task : Create table InfoSiteSoloMatch
DB: bodb_OWP	

Revisions:
	20211231@Johnny.Thai: Create table TicketIssueSupport
*/

-- Table TicketIssueSupport
IF OBJECT_ID('dbo.TicketIssueSupport', 'U') IS NOT NULL
    DROP TABLE dbo.[TicketIssueSupport]; 
GO
CREATE TABLE [dbo].[TicketIssueSupport]
([Id] [INT] IDENTITY(1, 1) NOT NULL, 
 [TicketId]          [INT] NOT NULL, 
 [Subject]      [nvarchar](2000) NOT NULL, 
 CONSTRAINT [PK_TicketIssueSupport] PRIMARY KEY CLUSTERED([id] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

