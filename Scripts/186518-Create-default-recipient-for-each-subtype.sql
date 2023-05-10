
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230510@Johnny
Task : Create default recipient for each subtype
DB: bodb_OWP	

Revisions:
	20230301@Johnny: Add SubTypeId By Recipient - [Redmine: #186518]
*/

DELETE FROM TicketTypeRecipient;
ALTER TABLE TicketTypeRecipient
ADD SubTypeId INT;