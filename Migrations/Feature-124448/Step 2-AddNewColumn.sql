/*
	Created: Carlos.Nguyen
	Date: 201912712
	Task:  Add column (Id, RequestDate, ResponseDate)
	DB: bodb_OWP
*/
USE bodb_OWP;
GO

ALTER TABLE dbo.AutoAssignmentRequest
ADD Id INT IDENTITY(1,1),
	RequestDate DATETIME,
	ResponseDate DATETIME