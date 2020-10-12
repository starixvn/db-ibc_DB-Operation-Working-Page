/*
	Creator:	20181129@Kane.Le
	Task:		Add new column - [Redmine: #105043]
	Server:		DBOWP.bodb_OWP
*/

USE [bodb_OWP]
GO

-- Add Column Order
ALTER TABLE [dbo].[NotificationSetting] ADD [Order] [int] NULL
GO

-- Add Columns Pickup, Address, Level
ALTER TABLE dbo.[User] ADD Pickup BIT NULL
	,[Address] NVARCHAR(500) NULL
	,[Level] INT NULL
GO