/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251022@Hank
Task : Insert MaxbetOU into EventPickingChildMatch
DB: bodb_OWP

Revisions:
	20251022@Hank: Insert MaxbetOU into EventPickingChildMatch - [Redmine: #238985]
*/
use bodb_OWP
go

ALTER TABLE  EventPickingChildMatch
ADD MaxbetOU MONEY NULL;


ALTER TABLE  EventPicking
ADD MaxbetOu MONEY NULL;
