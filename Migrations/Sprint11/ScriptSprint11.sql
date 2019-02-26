/*
	Created: Raymond.Le
	Date: 2019-02-15
	Task: [Redmine: #108723]
	DB: bodb_OWP
*/

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

-- Add column IsWatcher into table
ALTER TABLE dbo.[Message]
ADD IsWatcher BIT NULL;

ALTER TABLE dbo.[Message] 
ADD CONSTRAINT [DF_Message_IsWatcher] DEFAULT ((0)) FOR IsWatcher

UPDATE [dbo].[Message] WITH (ROWLOCK, UPDLOCK)
SET IsWatcher = 0;

-- Update data table NotificationSetting
UPDATE [dbo].[NotificationSetting] WITH (ROWLOCK, UPDLOCK)
SET NAME = 'Trader assignment of a match is updated'
WHERE NotificationSettingId = 6

UPDATE [dbo].[NotificationSetting] WITH (ROWLOCK, UPDLOCK)
SET [Order] = 3
WHERE NotificationSettingId = 7

UPDATE [dbo].[NotificationSetting] WITH (ROWLOCK, UPDLOCK)
SET [Order] = 4
WHERE NotificationSettingId = 8

UPDATE [dbo].[NotificationSetting] WITH (ROWLOCK, UPDLOCK)
SET [Order] = 5
WHERE NotificationSettingId = 9

INSERT INTO [dbo].[NotificationSetting] (
		NotificationSettingId
		,Name
		,IsWatcher
		,DefaultValue
		,[Order]	
)
VALUES 
(12, 'LA assignment of a match is updated', 1, 'False', 2),
(13, 'The provider info of a match is updated', 1, 'False', 6);

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

-- insert data into NotificationSettingMessageTemplate
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (1, 1)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (1, 2)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (1, 8)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (1, 9)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (1, 10)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (2, 12)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (3, 3)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (3, 4)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (3, 5)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (4, 13)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 6)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 7)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 19)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 20)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 21)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 22)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 23)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 24)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 26)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 27)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 28)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 29)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 30)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 31)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (5, 32)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (6, 12)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (7, 3)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (7, 4)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (7, 5)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (8, 13)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 6)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 7)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 19)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 20)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 21)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 22)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 23)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 24)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 26)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 27)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 28)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 29)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 30)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 31)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (9, 32)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (10, 12)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (11, 11)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (11, 14)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (11, 15)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (11, 16)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (11, 17)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (11, 18)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (11, 25)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (12, 12)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (13, 11)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (13, 14)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (13, 15)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (13, 16)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (13, 17)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (13, 18)
GO
INSERT [dbo].[NotificationSettingMessageTemplate] ([NotificationSettingId], [MessageTemplateId]) VALUES (13, 25)
GO


