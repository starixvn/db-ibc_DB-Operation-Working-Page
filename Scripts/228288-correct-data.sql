/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250522@Frankie
Task : Disable KO Time Update in 180days API
DB: bodb_OWP

Revisions:
	20250522@Frankie: Correct data event picking [Redmine: #228288]
*/

DELETE FROM EventPickingLog WHERE id = 4133876;