/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250903@Hank
Task : Alter table LeagueManagementSetting
DB: bodb_OWP

Revisions:
	20250903@Hank: Alter table LeagueManagementSetting - [Redmine: #233199]
*/

use [bodb_OWP]

ALTER TABLE LeagueManagementSetting
ADD Remark2WD NVARCHAR(2000),
Remark2WK NVARCHAR(2000)
