
/*
	Created: xxx
	Date: 
	Task: schema [Redmine: #123167]
	DB: bodb_OWP
*/

USE bodb_OWP;
GO

ALTER TABLE dbo.InfositeMatch
ADD Venue NVARCHAR(100)

ALTER TABLE dbo.AssignmentUploadingLog
ADD IsUploadPHAssignment BIT CONSTRAINT [DF_AssignmentUploadingLogg_IsUploadPHAssignment] DEFAULT (0) NOT NULL