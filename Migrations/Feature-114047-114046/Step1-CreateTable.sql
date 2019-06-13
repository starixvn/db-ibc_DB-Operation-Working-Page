/*
	Created: Kane.Le
	Date: 20190530
	Task: [Redmine: #112737]
	DB: bodb_OWP
*/
USE bodb_OWP

CREATE TABLE [dbo].[EmployeeWorkingShiftPublish] (
	[SectionId] INT NOT NULL
	,FromDate DATETIME NOT NULL
	,ToDate DATETIME NOT NULL
	,IsPublished BIT DEFAULT(0)
	,LastPublishedById INT NOT NULL
	,LastPublishedDate DATETIME NOT NULL DEFAULT GETDATE()
	);
GO

CREATE INDEX IDX_EmployeeWorkingShiftPublish_SectionId
ON [dbo].[EmployeeWorkingShiftPublish] (SectionId);