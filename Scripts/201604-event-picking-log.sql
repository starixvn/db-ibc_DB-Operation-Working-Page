
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240708@Johnny
Task : Save log
DB: bodb_OWP

Revisions:
	20240708@Johnny: Add FromService column - [Redmine: #201604]
*/

ALTER TABLE EventPickingLog
ADD FromService nvarchar(50);