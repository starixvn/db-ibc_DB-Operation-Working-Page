/*
	Created: Raymond.Le
	Date: 2019-01-28
	Task: Script Sprint 10 - [Redmine: #108206]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema, create table
--------------------------------
USE [bodb_OWP]
GO

-- Add column ShiftId to table [EmployeeWorkingShift]
ALTER TABLE [dbo].[EmployeeWorkingShift] ADD ShiftId INT NULL;

-- Rename column ShiftCode to _ShiftCode
EXECUTE sys.sp_rename 'dbo.EmployeeWorkingShift.ShiftCode', '_ShiftCode', 'COLUMN';

-- Rename table EmployeeWorkingShiftColor to EmployeeWorkingShiftColor_Old
EXECUTE sys.sp_rename 'dbo.EmployeeWorkingShiftColor', 'EmployeeWorkingShiftColor_Old';
EXECUTE sys.sp_rename 'PK_EmployeeWorkingShiftColor', 'PK_EmployeeWorkingShiftColor_Old';
EXECUTE sys.sp_rename 'DF_EmployeeWorkingShiftColor_Background', 'DF_EmployeeWorkingShiftColor_Background_Old';
EXECUTE sys.sp_rename 'DF_EmployeeWorkingShiftColor_Color', 'DF_EmployeeWorkingShiftColor_Color_Old';

-- Create new table [EmployeeWorkingShiftColor]
CREATE TABLE [dbo].[EmployeeWorkingShiftColor] (
	[ShiftId] [int] IDENTITY(1, 1) NOT NULL
	,[ShiftCode] [nvarchar](50) NOT NULL
	,[Background] [varchar](50) NOT NULL CONSTRAINT [DF_EmployeeWorkingShiftColor_Background] DEFAULT('')
	,[Color] [varchar](50) NOT NULL CONSTRAINT [DF_EmployeeWorkingShiftColor_Color] DEFAULT('')
	,[StartTime] [time](7) NULL
	,[EndTime] [time](7) NULL
	,[IsTimeShift] [bit] NOT NULL
	,CONSTRAINT [PK_EmployeeWorkingShiftColor] PRIMARY KEY CLUSTERED ([ShiftId] ASC)
	) ON [OWP_Data];

-- create table EmployeeWorkingShiftTimeZoneSetting
CREATE TABLE [dbo].[EmployeeWorkingShiftTimeZoneSetting] (
	[SettingId] [smallint] NOT NULL
	,[Name] [nvarchar](20) NOT NULL
	,[IsDefault] [bit] NOT NULL
	,[Offset] [smallint] NOT NULL
	,CONSTRAINT [PK_EmployeeWorkingShiftTimeZoneSetting] PRIMARY KEY CLUSTERED ([SettingId] ASC)
	) ON [OWP_Data];

-- Add column to table [User]
ALTER TABLE dbo.[User] ADD TimeZoneSettingId SMALLINT NULL;
GO