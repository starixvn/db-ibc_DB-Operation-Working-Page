/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211104@Liam
Task : Update insert/remove recipient reader
DB: bodb_OWP	

Revisions:
	20211104@Liam.Pham: Adding RecipientType & GroupId - [Redmine: #162851]
*/

ALTER TABLE [dbo].[TicketMessageReader]
ADD [RecipientType]   INT NULL,
    [GroupId]   INT NULL
	
CREATE INDEX idx_pname
ON TicketIssueLeague (TicketId);

CREATE INDEX idx_pname
ON TicketIssueEvent (TicketId);

CREATE INDEX idx_pname
ON TicketIssueOther (TicketId);

CREATE INDEX idx_pname
ON TicketMessage (TicketId);

CREATE INDEX idx_pname
ON TicketCreator (TicketId);

CREATE INDEX idx_pname
ON TicketRecipient (TicketId);

CREATE INDEX idx_pname
ON TicketMessageReader (TicketId, RecipientId, RecipientType, GroupId );



