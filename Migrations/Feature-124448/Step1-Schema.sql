/*
	Created: 
	Date: 
	Task: schema [Redmine: #]
	DB: bodb_OWP
*/

USE bodb_OWP;
GO

-- add new column Market
ALTER TABLE dbo.MatchInfo
ADD Market NVARCHAR(250)