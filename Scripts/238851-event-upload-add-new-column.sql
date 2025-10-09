/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251009@Los
Task : add two column AIO BT, SOP
DB: bodb_OWP

Revisions:
	20251009@Los: add two column AIO BT, SOP - [Redmine: #238851]
*/

ALTER TABLE MatchInfo
ADD AIOBT NVARCHAR(2000),
SOP NVARCHAR(MAX)