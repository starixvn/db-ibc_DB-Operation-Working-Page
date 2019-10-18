/*
	Created: Kane.Le
	Date: 20191017
	Task: schema [Redmine: #121765]
	DB: bodb_OWP
*/
USE bodb_OWP
GO

-- add column ProviderName max length 2000
ALTER TABLE [Provider]
ALTER COLUMN ProviderName NVARCHAR(2000)
GO

-- add column OtherProviderName max length 2000
ALTER TABLE [OtherProvider]
ALTER COLUMN OtherProviderName NVARCHAR(2000)
GO
