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

INSERT INTO dbo.ValidationRule(RuleId
	,RuleName
	,IsActive
	,RuleResultType
	,Category
	,MessageFormat
	,SPName)
VALUES (31
	,'Duplicate InfoSiteID of matches'
	,1
	,1
	,1
	,'Duplicate InfoSiteID of matches: row <content>'
	,'OWP_ValidationRule_CheckRuleNumber31')
	,(32
	,'Duplicate MatchNo. of matches'
	,1
	,1
	,1
	,'Duplicate MatchNo. of matches: row <content>'
	,'OWP_ValidationRule_CheckRuleNumber32')
	
INSERT INTO dbo.FunctionRule(FunctionId
	,RuleId
	,[Order])
VALUES (3,31,31),
	(3,33,32)
	
GO