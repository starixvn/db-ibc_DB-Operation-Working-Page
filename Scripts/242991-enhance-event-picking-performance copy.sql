/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251111@Los
Task : Enhance event picking performance
DB: bodb_OWP

Revisions:
	20251111@Los: Enhance event picking performance - [Redmine: #242991]
*/
USE bodb_OWP;
GO

ALTER TABLE LeagueManagementSetting
ADD NoOfferLive TINYINT NULL;