/*
	Created: Raymond.Le
	Date: 2019-01-28
	Task: Script Sprint 10 - [Redmine: #108206]
	DB: bodb_OWP
*/

--------------------------------
-- 3. Update data
--------------------------------
USE [bodb_OWP]
GO

INSERT INTO [dbo].[EmployeeWorkingShiftTimeZoneSetting] (
	SettingId
	,[Name]
	,IsDefault
	,Offset
	)
VALUES (1, 'GMT+8', 1, 0)
	,(2, 'GMT+7', 0, - 60);

DELETE 
FROM dbo.[EmployeeWorkingShift]
WHERE ShiftId IS NULL;

GO