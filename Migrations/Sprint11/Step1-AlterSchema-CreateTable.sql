/*
	Created: Raymond.Le
	Date: 2019-02-25
	Task: [Redmine: #108723]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema, create table
--------------------------------
USE bodb_OWP

-- Remove 2 columns in table MessageUser
ALTER TABLE dbo.MessageUser
DROP CONSTRAINT [DF_MessageUser_CreatedDate];

ALTER TABLE dbo.MessageUser
DROP COLUMN [CreatedDate];

ALTER TABLE dbo.MessageUser
DROP COLUMN [CreatedBy];

-- Create table EmployeeWorkingShiftDefault
CREATE TABLE [dbo].[EmployeeWorkingShiftDefault](
	[UserId] [int] NOT NULL,
	[DayOfTheWeek] [smallint] NOT NULL,
	[ShiftId] [int] NOT NULL,
 CONSTRAINT [PK_EmployeeWorkingShiftDefault] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[DayOfTheWeek] ASC
)
) ON [OWP_Data];

-- Add column IsWatcher into table [Message]
ALTER TABLE dbo.[Message]
ADD IsWatcher BIT NULL;

ALTER TABLE dbo.[Message] 
ADD CONSTRAINT [DF_Message_IsWatcher] DEFAULT ((0)) FOR IsWatcher;

-- create table write log sync InfoSite
CREATE TABLE [dbo].[InfoSiteSyncLog] (
    [LogId]     INT      IDENTITY (1, 1) NOT NULL,
    [StartTime] DATETIME CONSTRAINT [DF_InfoSiteSyncLog_StartTime] DEFAULT (getdate()) NOT NULL,
    [EndTime]   DATETIME NULL,
    CONSTRAINT [PK_InfoSiteSyncLog] PRIMARY KEY CLUSTERED ([LogId] ASC)
) ON [OWP_Data];

CREATE NONCLUSTERED INDEX [IX_InfoSiteSyncLog]
    ON [dbo].[InfoSiteSyncLog]([StartTime] ASC)
    ON [OWP_Index];

GO

CREATE TABLE [dbo].[InfoSiteSyncLogDetail] (
    [LogId]           INT NOT NULL,
    [OWPMatchId]      INT NOT NULL,
    [InfoSiteMatchId] INT NOT NULL,
    CONSTRAINT [PK_InfoSiteSyncLogDetail] PRIMARY KEY CLUSTERED ([LogId] ASC, [OWPMatchId] ASC)
) ON [OWP_Data];

-- create table NotificationSettingMessageTemplate
CREATE TABLE [dbo].[NotificationSettingMessageTemplate](
	[NotificationSettingId] [smallint] NOT NULL,
	[MessageTemplateId] [smallint] NOT NULL,
 CONSTRAINT [PK_NotificationSettingMessageTemplate] PRIMARY KEY CLUSTERED 
(
	[NotificationSettingId] ASC,
	[MessageTemplateId] ASC
)
) ON [OWP_Data];

GO
