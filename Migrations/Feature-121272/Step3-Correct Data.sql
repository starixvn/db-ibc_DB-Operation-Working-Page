 /*
	Created: Tyler.Dang
	Date: 20191004
	Task: Initial correct data [Redmine: #121308]
	DB: bodb_OWP
*/

DELETE FROM EmployeeWorkingShift WHERE ShiftId IN (300, 301, 302, 303);

DELETE FROM EmployeeWorkingShiftColor WHERE ShiftId IN (300, 301, 302, 303);

INSERT INTO [dbo].[EmployeeWorkingShiftColor]
           ([ShiftCode]
           ,[Background]
           ,[Color]
           ,[StartTime]
           ,[EndTime]
           ,[IsTimeShift]
           ,[Extension])
     VALUES
           (''
		   ,'#000000'
           ,'#ffffff'
           ,'7:00:00'
           ,'15:00:00'
           ,1
           ,2)

INSERT INTO [dbo].[EmployeeWorkingShiftColor]
           ([ShiftCode]
           ,[Background]
           ,[Color]
           ,[StartTime]
           ,[EndTime]
           ,[IsTimeShift]
           ,[Extension])
     VALUES
           (''
		   ,'#000000'
           ,'#ffffff'
           ,'7:00:00'
           ,'18:00:00'
           ,1
           ,2) 