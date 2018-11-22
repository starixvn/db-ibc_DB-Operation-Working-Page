/*
	Created: Leo.Vo
	Date: 2018-11-22
	Task: Deactive assignment rule
	DB: bodb_OWP
*/

USE bodb_OWP
GO

-- Deactive validation rule Invalid MatchId
UPDATE [dbo].[ValidationRule]
SET IsActive = 0
WHERE RuleId = 1
GO