
/*<info serverAlias="DBACC-bodb02" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230802@Los
Task : Init script
DB: bodb_OWP

Revisions:
	20230802@Los: Init script - [Redmine: #191778]
*/

ALTER TABLE TicketIssue
ADD  OwpLeagueIdzzz INT,
	OwpHomeIdzzz INT,
	OwpAwayIdzzz INT,
	InfoSiteMatchIdzzz INT,
	AdminsiteIdzzz INT,
	OwpMatchIdzzz INT,
	[Subjectzzz] NVARCHAR(2000)

UPDATE ti
SET ti.OwpLeagueIdzzz=te.OwpLeagueId,
	ti.OwpHomeIdzzz=te.OwpHomeId,
	ti.OwpAwayIdzzz=te.OwpAwayId,
	ti.InfoSiteMatchIdzzz=te.InfoSiteMatchId
FROM TicketIssue AS ti INNER JOIN TicketIssueEvent AS te ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.OwpLeagueIdzzz=te.OwpLeagueId
FROM TicketIssue AS ti INNER JOIN TicketIssueLeague AS te ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.OwpMatchIdzzz=te.OwpMatchId
FROM TicketIssue AS ti INNER JOIN TicketIssueLiveIncident AS te ON ti.TicketId=te.TicketId


UPDATE ti
SET ti.[Subjectzzz]=te.[Subject],
	ti.AdminsiteIdzzz=te.AdminsiteId
FROM TicketIssue AS ti INNER JOIN TicketIssueLogWork AS te ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.[Subjectzzz]=te.[Subject]
FROM TicketIssue AS ti INNER JOIN TicketIssueOther AS te ON ti.TicketId=te.TicketId

UPDATE ti
SET ti.[Subjectzzz]=te.[Subject]
FROM TicketIssue AS ti INNER JOIN TicketIssueSupport AS te ON ti.TicketId=te.TicketId
