
/*<info serverAlias="DBACC-bodb02" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230802@Los
Task : Init script
DB: bodb_OWP

Revisions:
	20230802@Los: Init script - [Redmine: #191778]
*/


ALTER TABLE TicketIssue
ADD  	OwpLeagueId_New 	INT,
		OwpHomeId_New 	INT,
		OwpAwayId_New 	INT,
		InfoSiteMatchId_New INT,
		AdminsiteId_New INT,
		OwpMatchId_New INT,
		Subject_New NVARCHAR(2000),
		EventType_New 	INT

UPDATE ti
SET ti.OwpLeagueId_New=te.OwpLeagueId,
	ti.OwpHomeId_New=te.OwpHomeId,
	ti.OwpAwayId_New=te.OwpAwayId,
	ti.InfoSiteMatchId_New=te.InfoSiteMatchId,
	ti.EventType_New=2
FROM TicketIssue AS ti INNER JOIN TicketIssueEvent AS te ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.OwpLeagueId_New=te.OwpLeagueId,
 ti.EventType_New=1
FROM TicketIssue AS ti INNER JOIN TicketIssueLeague AS te ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.OwpMatchId_New=te.OwpMatchId
,ti.EventType_New=5
FROM TicketIssue AS ti INNER JOIN TicketIssueLiveIncident AS te ON ti.TicketId=te.TicketId


UPDATE ti
SET ti.Subject_New=te.[Subject],
	ti.AdminsiteId_New=te.AdminsiteId,
	ti.EventType_New=6
FROM TicketIssue AS ti INNER JOIN TicketIssueLogWork AS te ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.Subject_New=te.[Subject]
,ti.EventType_New=3
FROM TicketIssue AS ti INNER JOIN TicketIssueOther AS te ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.Subject_New=te.[Subject]
,ti.EventType_New=4
FROM TicketIssue AS ti INNER JOIN TicketIssueSupport AS te ON ti.TicketId=te.TicketId


--DROP PROCEDURE [dbo].[OWP_TicketIssueEvent_Create]
--DROP PROCEDURE [dbo].[OWP_TicketIssueLeague_Create]
--DROP PROCEDURE [dbo].[OWP_TicketIssueLiveIncident_Create]
--DROP PROCEDURE [dbo].[OWP_TicketIssueLogWork_Create]
--DROP PROCEDURE [dbo].[OWP_TicketIssueOther_Create]
--DROP PROCEDURE [dbo].[OWP_TicketIssueSupport_Create]
