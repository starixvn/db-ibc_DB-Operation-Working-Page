/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241108@Tim
Task : DayShift Assignment - auto assignment
DB: bodb_OWP

Revisions:
	20241108@Tim: Add AssignBySystem column - [Redmine: #203309]
*/

ALTER TABLE dbo.PreMatchAssignment ADD AssignBySystem bit