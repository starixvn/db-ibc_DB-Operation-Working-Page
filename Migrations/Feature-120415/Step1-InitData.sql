/*
	Created: Leo.Vo
	Date: 20190919
	Task: Inactive warning rules [Redmine: #120415]
	DB: bodb_OWP
*/
USE bodb_OWP

UPDATE dbo.ValidationRule WITH (ROWLOCK)
SET IsActive = 0
WHERE RuleResultType <> 1

GO