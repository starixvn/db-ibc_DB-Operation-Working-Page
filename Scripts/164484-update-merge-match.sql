
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20211112@Mira
Task : Merge Match
DB: bodb_OWP	

Revisions:
	20211112@Mira: Modify merge match behavior - [Redmine: #164484]
*/

ALTER TABLE dbo.[InfositeMatch]
ADD ParentId INT;
ALTER TABLE dbo.[ServiceActionLog]
ADD InfoSiteMatchId INT;