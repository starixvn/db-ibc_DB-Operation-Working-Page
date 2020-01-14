/*
	Created: Kane.Le
	Date: 20191220
	Task: schema [Redmine: #124448]
	DB: bodb_OWP
*/

USE bodb_OWP;
GO


ALTER TABLE dbo.[LSTReport]
ALTER COLUMN [ReportDate] DATE
GO
