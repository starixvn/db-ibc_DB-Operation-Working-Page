/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250210@Frankie
Task : Support Match Suspended
DB: bodb_OWP

Revisions:
	20250210@Frankie: Support Match Suspended - [Redmine: #216746]
*/

INSERT INTO dbo.EventPickingUpdateType (Id, UpdateType, RAndDUpdate)
VALUES (52, 'Match Suspended', 'Match Suspended')
