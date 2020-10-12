/*
	Created: Raymond.Le
	Date: 2019-02-25
	Task: [Redmine: #109560]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema, create table
--------------------------------
USE bodb_OWP

ALTER TABLE dbo.EmployeeWorkingShift
ADD RefShiftId INT NULL

GO
