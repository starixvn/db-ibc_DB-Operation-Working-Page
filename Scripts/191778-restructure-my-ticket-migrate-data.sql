
/*<info serverAlias="DBOWP-bodb02" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20230802@Los
Task : Init script
DB: bodb_OWP

Revisions:
	20230802@Los: Init script - [Redmine: #191778]
*/

UPDATE ti
SET ti.OwpLeagueId_New=te.OwpLeagueId,
	ti.OwpHomeId_New=te.OwpHomeId,
	ti.OwpAwayId_New=te.OwpAwayId,
	ti.InfoSiteMatchId_New=te.InfoSiteMatchId,
	ti.EventType_New=2
FROM TicketIssue AS ti WITH ( NOLOCK ) INNER JOIN TicketIssueEvent AS te WITH ( NOLOCK ) ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.OwpLeagueId_New=te.OwpLeagueId,
 ti.EventType_New=1
FROM TicketIssue AS ti WITH ( NOLOCK ) INNER JOIN TicketIssueLeague AS te WITH ( NOLOCK ) ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.OwpMatchId_New=te.OwpMatchId
,ti.EventType_New=5
FROM TicketIssue AS ti WITH ( NOLOCK ) INNER JOIN TicketIssueLiveIncident AS te WITH ( NOLOCK ) ON ti.TicketId=te.TicketId


UPDATE ti
SET ti.Subject_New=te.[Subject],
	ti.AdminsiteId_New=te.AdminsiteId,
	ti.EventType_New=6
FROM TicketIssue AS ti WITH ( NOLOCK ) INNER JOIN TicketIssueLogWork AS te WITH ( NOLOCK ) ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.Subject_New=te.[Subject]
,ti.EventType_New=3
FROM TicketIssue AS ti WITH ( NOLOCK ) INNER JOIN TicketIssueOther AS te WITH ( NOLOCK ) ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.Subject_New=te.[Subject]
,ti.EventType_New=4
FROM TicketIssue AS ti WITH ( NOLOCK ) INNER JOIN TicketIssueSupport AS te WITH ( NOLOCK ) ON ti.TicketId=te.TicketId

