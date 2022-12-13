
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20221213@Liam.Pham
Task : add more index 
DB: bodb_OWP	

Revisions:
	20211231@Liam.Pham: add more index [Redmine: #181560]
*/

CREATE NONCLUSTERED INDEX IX_TicketIssue ON [dbo].TicketIssue
(TicketId, TicketType, SubtypeId
) INCLUDE(TicketStatus, LastCommentDate);

CREATE NONCLUSTERED INDEX IX_TicketIssueEvent ON [dbo].TicketIssueEvent(TicketId, InfoSiteMatchId) INCLUDE(OwpHomeId, OwpAwayId);

CREATE NONCLUSTERED INDEX IX_TicketIssueLeague ON [dbo].TicketIssueLeague(TicketId, OwpLeagueId);

CREATE NONCLUSTERED INDEX IX_TicketCenterLiveIncident ON [dbo].TicketIssueLiveIncident(TicketId, OwpMatchId);

CREATE NONCLUSTERED INDEX IX_TicketIssueOther ON [dbo].TicketIssueOther(TicketId) INCLUDE([Subject]);