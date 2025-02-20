/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250210@Frankie
Task : Change condition to check a Postponed Match
DB: bodb_OWP

Revisions:
	20250210@Frankie: Add IsPostponed column - [Redmine: #216746]
*/

ALTER TABLE dbo.InfoSiteMatch ADD IsPostponed BIT