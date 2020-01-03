/*
	Created: Kane.Le
	Date: 20191220
	Task: schema [Redmine: #124448]
	DB: bodb_OWP
*/

USE bodb_OWP;
GO

-- add new column Market


ALTER TABLE dbo.[LSTReport]
ALTER COLUMN [ReportDate] DATE
GO

ALTER TABLE dbo.[LSTReport]
DROP COLUMN [SectionId]
GO

ALTER TABLE dbo.[LSTReport]
DROP COLUMN [SectionName]
GO
