/*
	Created: Raymond.Le
	Date: 2019-01-17
	Task: Script sprint 9 - [Redmine: #107257]
	DB: bodb_OWP
*/

--------------------------------
-- 3. Remove unused Column, SP
--------------------------------
USE [bodb_OWP]
GO

-- drop column KOTimeRemark in table MatchInfo
ALTER TABLE dbo.MatchInfo
DROP COLUMN KOTimeRemark;

-- drop column NoOfHDP in table MatchInfo
ALTER TABLE dbo.MatchInfo
DROP COLUMN NoOfHDP;

-- delete unused SP
DROP PROCEDURE dbo.DEL_OWP_Provider_GetAll;
DROP PROCEDURE dbo.DEL_OWP_LiveDetail_Provider_GetByMatchId;
DROP PROCEDURE dbo.DEL_OWP_Runner_GetAll;
DROP PROCEDURE dbo.DEL_OWP_LiveDetail_Runner_GetByMatchId;
GO
