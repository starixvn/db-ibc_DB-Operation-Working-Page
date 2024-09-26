/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20210706@Carlos.Nguyen
Task : API Sync working shift to HRM
DB: bodb_OWP

Revisions:
	20210706@Carlos.Nguyen: API Sync working shift to HRM - [Redmine: #156338]
*/

ALTER TABLE EmployeeWorkingShift
ADD LastUpdated DATETIME;
