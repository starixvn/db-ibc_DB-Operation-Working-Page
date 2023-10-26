
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20231026@los
Task : Sync round
DB: bodb_OWP

Revisions:
	20231026@los: sync round - [Redmine: #193810]
*/

ALTER TABLE InfoSiteMatch
	ADD [TeamRound] NVARCHAR(2000);   