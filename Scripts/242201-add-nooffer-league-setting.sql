/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251117@Hank
Task : Add no offer league setting
DB: bodb_OWP

Revisions:
	20251117@Hank: Add no offer league setting - [Redmine: #242201]
*/
USE bodb_OWP;
GO

ALTER TABLE LeagueManagementSetting
ADD NoOfferLive TINYINT NULL;