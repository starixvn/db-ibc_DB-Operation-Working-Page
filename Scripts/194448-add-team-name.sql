/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20231016@los
Task : Export event picking
DB: bodb_OWP	

Revisions:
	20231016@los: Export event picking [Redmine: #194448]
*/

ALTER TABLE EventPickingLog
ADD HomeUpdated BIT,
AwayUpdated BIT
