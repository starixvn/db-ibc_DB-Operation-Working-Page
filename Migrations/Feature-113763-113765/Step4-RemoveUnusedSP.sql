/*
	Created: Leo.Vo
	Date: 20190521
	Task: [Redmine: #113763]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema
--------------------------------
USE bodb_OWP

drop procedure dbo.OWP_EmployeeWorkingShift_RemoveDefaultShift
drop procedure OWP_EmployeeWorkingShift_InitDefaultShiftForWeek
drop function OWP_GetUsernameByUserId

GO