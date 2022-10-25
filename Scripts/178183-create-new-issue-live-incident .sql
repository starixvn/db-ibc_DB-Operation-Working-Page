
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20220929@Liam.Pham
Task : Create table TicketIssueLiveIncident
DB: bodb_OWP	

Revisions:
	20211231@Liam.Pham: Create table TicketIssueLiveIncident [Redmine: #178183]
*/

-- Table TicketIssueLiveIncident
IF OBJECT_ID('dbo.TicketIssueLiveIncident', 'U') IS NOT NULL
    DROP TABLE dbo.[TicketIssueLiveIncident]; 
GO
CREATE TABLE [dbo].[TicketIssueLiveIncident]
([Id]         INT IDENTITY(1,1) PRIMARY KEY, 
 [TicketId]   [INT] NOT NULL, 
 [OwpMatchId] [INT] NOT NULL, 
)
ON [OWP_Data];
GO

INSERT INTO [dbo].[TicketType](TypeId,TypeName)
VALUES(4,'Live Incident');

