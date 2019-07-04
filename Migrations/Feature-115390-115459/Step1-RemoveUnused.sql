/*
	Created: Leo.Vo
	Date: 20190704
	Task: [Redmine: #115459]
	DB: bodb_OWP
*/
USE bodb_OWP

DROP TABLE dbo.NotificationSettingMessageTemplate
GO

ALTER TABLE dbo.MessageTemplate
DROP CONSTRAINT DF_MessageTemplate_IsActive
GO

ALTER TABLE dbo.MessageTemplate
DROP COLUMN IsActive
GO