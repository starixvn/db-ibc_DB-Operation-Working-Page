/*
	Created: Carlos.Nguyen
	Date: 201910512
	Task:  Add column (Language) [Redmine: #125019]
	DB: bodb_OWP
*/
USE bodb_OWP;
GO

ALTER TABLE dbo.[User]
ADD LanguageId NVARCHAR(50)