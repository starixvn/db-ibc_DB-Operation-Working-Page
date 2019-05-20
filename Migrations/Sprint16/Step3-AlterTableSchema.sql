/*
	Created: Leo.Vo
	Date: 20190506
	Task: [Redmine: #112737]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema
--------------------------------
USE bodb_OWP

ALTER TABLE dbo.MatchInfo
DROP COLUMN [Agent];
GO

ALTER TABLE dbo.MatchInfo
DROP COLUMN [OtherProvider];
GO

ALTER TABLE dbo.MatchInfo
DROP COLUMN [Provider];
GO

ALTER TABLE dbo.MatchInfo
DROP COLUMN [TVCode];
GO