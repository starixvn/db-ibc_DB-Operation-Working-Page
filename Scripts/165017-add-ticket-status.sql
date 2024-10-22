
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20211130@Mira
Task : Add ticket status
DB: bodb_OWP	

Revisions:
	20211130@Mira: Enhance Ticket Center - [Redmine: #165017]
    2021208@Luca: Enhance Ticket Center - [Redmine: #165017]
*/

-- Add TicketStatus column
ALTER TABLE dbo.[TicketIssue]
ADD TicketStatus VARCHAR(10) NOT NULL
                             DEFAULT 'Open';

-- Table TicketStatusLog
CREATE TABLE [dbo].[TicketStatusLog]
([LogId]      [INT] IDENTITY(1, 1) NOT NULL, 
 [TicketId]   INT NOT NULL, 
 [LogDate]    [DATETIME] NOT NULL, 
 [ModifiedBy] [VARCHAR](30) NOT NULL, 
 [OldValue]   [VARCHAR](10) NULL, 
 [NewValue]   [VARCHAR](10) NULL
)
ON [OWP_Data];
GO

ALTER TABLE TicketMessageReader
ADD IsPinned BIT NOT NULL
                 DEFAULT(0);

-- Update ticket type
UPDATE dbo.TicketType
  SET 
      TypeName = 'Group Chat'
WHERE TypeId = 2;