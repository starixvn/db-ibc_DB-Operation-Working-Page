/*
	Creator:	20181129@Kane.Le
	Task:		Init Data - [Redmine: #105043]
	Server:		DBOWP.bodb_OWP
*/

USE [bodb_OWP]
GO

-- InitData NotificationSetting
TRUNCATE TABLE [dbo].[NotificationSetting]

INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (1, N'My assignment is updated', 0, N'True', 1)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (2, N'Trader assignment of my assigned match is updated', 0, N'True', 2)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (3, N'The note of my assigned match is updated', 0, N'True', 4)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (4, N'The odds of my assigned match is updated', 0, N'True', 5)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (5, N'The match info of my assigned match is updated', 0, N'True', 6)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (6, N'The assignment of a match is updated', 1, N'False', 1)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (7, N'The note of a match is updated', 1, N'False', 2)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (8, N'The odds of a match is updated', 1, N'False', 3)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (9, N'The match info of a match is updated', 1, N'False', 4)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (10, N'LA assignment of my assigned match is updated', 0, N'True', 3)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (11, N'The provider info of my assigned match is updated', 0, N'True', 7)
GO

-- InitData RefResource UserLevel
INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(10, 'UserLevel', 1, 'A')
INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(11, 'UserLevel', 2, 'B')
INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(12, 'UserLevel', 3, 'C')
INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(13, 'UserLevel', 4, 'D')
INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(14, 'UserLevel', 5, 'F')
GO