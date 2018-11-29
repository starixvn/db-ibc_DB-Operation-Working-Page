/*
	Creator:	20181129@Kane.Le
	Task:		Rollback Data - [Redmine: #105043]
	Server:		DBOWP.bodb_OWP
*/
USE [bodb_OWP]
GO

/* Rollback table NotificationSetting 
   1. Remove data in dbo.NotificationSettingMapping
   2. Drop column Order
   3. Init data backup
*/


DELETE
FROM dbo.NotificationSettingMapping
WHERE dbo.NotificationSettingMapping.NotificationSettingId NOT IN (
		SELECT NotificationSettingId
		FROM dbo.NotificationSetting
		)
GO


ALTER TABLE dbo.NotificationSetting

DROP COLUMN [Order]
GO

TRUNCATE TABLE dbo.NotificationSetting
GO


INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue]) VALUES (1, N'My assignment is updated', 0, N'True')
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue]) VALUES (2, N'Trader assignment of my assigned match is updated', 0, N'True')
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue]) VALUES (3, N'The note of my assigned match is updated', 0, N'True')
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue]) VALUES (4, N'The odds of my assigned match is updated', 0, N'True')
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue]) VALUES (5, N'The match info of my assigned match is updated', 0, N'True')
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue]) VALUES (6, N'The assignment of a match is updated', 1, N'False')
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue]) VALUES (7, N'The note of a match is updated', 1, N'False')
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue]) VALUES (8, N'The odds of a match is updated', 1, N'False')
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue]) VALUES (9, N'The match info of a match is updated', 1, N'False')
GO

/* Rollback table RefResource
   1. Remove data in dbo.RefResource  
*/

DELETE dbo.RefResource
WHERE RefName = 'UserLevel'
GO


/* Rollback table User
   1. Drop column in dbo.User  
*/

ALTER TABLE dbo.[User]

DROP COLUMN Pickup
	,[Address]
	,[Level]
GO


