USE bodb_OWP
GO

-- Deactive validation rule Invalid MatchId
UPDATE [dbo].[ValidationRule]
SET IsActive = 0
WHERE RuleId = 1
GO