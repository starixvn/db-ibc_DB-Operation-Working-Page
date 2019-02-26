/*
	Created: Raymond.Le
	Date: 2019-01-28
	Task: Script Sprint 10 - [Redmine: #108206]
	DB: bodb_OWP
*/

--------------------------------
-- 4. Drop table, column
--------------------------------
USE [bodb_OWP]
GO

-- Remove column _ShiftCode
DROP INDEX dbo.[EmployeeWorkingShift].IX_EmployeeWorkingShift_ShiftCode;

ALTER TABLE dbo.[EmployeeWorkingShift]
DROP COLUMN _ShiftCode;

-- Alter column ShiftId
ALTER TABLE dbo.[EmployeeWorkingShift]
ALTER COLUMN ShiftId INT NOT NULL;

CREATE NONCLUSTERED INDEX IX_EmployeeWorkingShift_ShiftId ON dbo.[EmployeeWorkingShift] (ShiftId ASC) ON OWP_Index;

-- Drop table EmployeeWorkingShiftColor_Old
DROP TABLE EmployeeWorkingShiftColor_Old