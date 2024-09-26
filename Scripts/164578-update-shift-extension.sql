
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20211122@Mira
Task : Update shift extension
DB: bodb_OWP	

Revisions:
	20211122@Mira: Update shift extension - [Redmine: #164578]
*/

UPDATE dbo.[EmployeeWorkingShiftColor]
  SET 
      Extension = 0
WHERE Extension IS NULL;

TRUNCATE TABLE OvertimeReport;