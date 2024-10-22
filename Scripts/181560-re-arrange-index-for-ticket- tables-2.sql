
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20221213@Liam.Pham
Task : add more index 
DB: bodb_OWP	

Revisions:
	20211231@Liam.Pham: add more index [Redmine: #181560]
*/

CREATE NONCLUSTERED INDEX IX_TicketIssue ON [dbo].TicketIssue
(TicketType, SubtypeId, TicketStatus
) INCLUDE(LastCommentDate);

CREATE NONCLUSTERED INDEX idx_pname ON [dbo].TicketIssueEvent(TicketId, InfoSiteMatchId) INCLUDE(OwpHomeId, OwpAwayId) WITH(DROP_EXISTING = ON);

CREATE NONCLUSTERED INDEX idx_pname ON [dbo].TicketIssueLeague(TicketId, OwpLeagueId) WITH(DROP_EXISTING = ON);

CREATE NONCLUSTERED INDEX idx_pname ON [dbo].TicketIssueOther(TicketId) INCLUDE([Subject]) WITH(DROP_EXISTING = ON);

CREATE NONCLUSTERED INDEX IX_TicketCenterLiveIncident ON [dbo].TicketIssueLiveIncident(TicketId, OwpMatchId);