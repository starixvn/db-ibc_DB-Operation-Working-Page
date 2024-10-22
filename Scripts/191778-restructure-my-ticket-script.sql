
/*<info serverAlias="DBOWP-bodb02" executers="wsv_owp" isFunction="0"></info>*/
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


