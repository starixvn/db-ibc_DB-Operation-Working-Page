/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250916@Hank
Task : Insert timezone setting into table EmployeeWorkingShiftTimeZoneSetting
DB: bodb_OWP

Revisions:
	20250916@Hank: Insert timezone setting into table EmployeeWorkingShiftTimeZoneSetting - [Redmine: #237438]
*/

use [bodb_OWP]

INSERT INTO EmployeeWorkingShiftTimeZoneSetting(SettingId, Name, IsDefault, Offset)
VALUES(3, 'GMT+5:30', 0, -150)