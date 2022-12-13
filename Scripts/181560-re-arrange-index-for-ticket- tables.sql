
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20221213@Liam.Pham
Task : add more index 
DB: bodb_OWP	

Revisions:
	20211231@Liam.Pham: add more index [Redmine: #181560]
*/

CREATE NONCLUSTERED INDEX IX_RecipientType ON [dbo].[TicketRecipient]
([RecipientId], [RecipientType]
) INCLUDE([TicketId]);

CREATE NONCLUSTERED INDEX IX_GroupId ON [dbo].RecipientGroup(GroupId) INCLUDE(RecipientId);

CREATE NONCLUSTERED INDEX idx_pname ON TicketMessageReader(TicketId, RecipientId, RecipientType, GroupId) INCLUDE(IsRead, IsPinned) WITH(DROP_EXISTING = ON);

CREATE NONCLUSTERED INDEX IX_TicketId ON [dbo].TicketIssueSupport(TicketId) INCLUDE([Subject]);