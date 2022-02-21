
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 220220221@Mira
Task : Add subtype on My Ticket
DB: bodb_OWP	

Revisions:
	20220221@Mira: Add subtype on My Ticket - [Redmine: #168468]
*/

--create table TicketSubtype
DROP TABLE [dbo].[TicketSubtype];
CREATE TABLE [dbo].[TicketSubtype]
([SubtypeId]   [INT] IDENTITY(1, 1) NOT NULL, 
 [TypeId]      [INT] NOT NULL, 
 [SubtypeName] [VARCHAR](100) NOT NULL, 
 CONSTRAINT [PK_TicketSubtype] PRIMARY KEY CLUSTERED([SubtypeId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

-- add subtype
ALTER TABLE dbo.TicketIssue
ADD SubtypeId INT NULL;
GO