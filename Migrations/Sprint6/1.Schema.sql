USE [bodb_OWP]
GO

/*
Created: 20181128@Kane.Le
Task : Schema Sprint 6
DB: bodb_OWP

Revisions:
	20181128@Kane.Le: Add column for table User - [Redmine: #105043]
*/
ALTER TABLE [dbo].[NotificationSetting] ADD [Order] [int] NULL
GO

-- 
ALTER TABLE dbo.[User] ADD Pickup BIT NULL
	,[Address] NVARCHAR(500) NULL
	,[Level] INT NULL
GO