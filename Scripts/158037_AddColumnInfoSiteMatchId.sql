/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211015@Liam
Task : Adding InfoSiteMatchId to TicketIssueEvent
DB: bodb_OWP	

Revisions:
	20211015@Liam: Adding InfoSiteMatchId to TicketIssueEvent - [Redmine: #158037]
*/

ALTER TABLE [dbo].[TicketIssueEvent]
ADD [InfoSiteMatchId]   INT NULL;
