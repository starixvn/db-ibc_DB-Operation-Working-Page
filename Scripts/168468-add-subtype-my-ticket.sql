
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
-- add subtype to log delete ticket
UPDATE LogAction
SET LogItems = N'<root><xml path="r/z" /><row item="TicketId" alias="tId" /><row item="TicketType" alias="tType" /><row item="SubtypeId" alias="tSubtypeId" /><row item="CreatedDate" alias="tCreDate" /><row item="TicketStatus" alias="tStatus" /><row item="CreatorId" alias="tCreId" /><row item="OWPLeagueName" alias="OwpLeagueName" /><row item="HomeName" alias="HomeName" /><row item="AwayName" alias="AwayName" /><row item="Subject" alias="Subject" /><row item="InfoSiteMatchId" alias="InfoSiteMatchId" /><row item="EventDateTime" alias="EventDateTime" /></root>'
WHERE ActionId = 122