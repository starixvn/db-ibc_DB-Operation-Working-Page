/*
	Created: Leo.Vo
	Date: 20190506
	Task: [Redmine: #112737]
	DB: bodb_OWP
*/
--------------------------------
-- 2. Update data
--------------------------------
USE bodb_OWP

INSERT INTO dbo.MatchAgent (
	OWPMatchId
	,AgentId
	)
SELECT DISTINCT mi.OWPMatchId
	,f.val
FROM MatchInfo AS mi WITH (NOLOCK)
	CROSS APPLY dbo.fnc_SplitStrings(mi.[Agent], ',') AS f
WHERE mi.[Agent] IS NOT NULL
GO

INSERT INTO dbo.MatchOtherProvider (
	OWPMatchId
	,OtherProviderId
	)
SELECT DISTINCT mi.OWPMatchId
	,f.val
FROM MatchInfo AS mi WITH (NOLOCK)
	CROSS APPLY dbo.fnc_SplitStrings(mi.[OtherProvider], ',') AS f
WHERE mi.[OtherProvider] IS NOT NULL
GO

INSERT INTO dbo.MatchProvider (
	OWPMatchId
	,ProviderId
	)
SELECT DISTINCT mi.OWPMatchId
	,f.val
FROM MatchInfo AS mi WITH (NOLOCK)
	CROSS APPLY dbo.fnc_SplitStrings(mi.[Provider], ',') AS f
WHERE mi.[Provider] IS NOT NULL
GO

INSERT INTO dbo.MatchTelevision (
	OWPMatchId
	,TVId
	)
SELECT DISTINCT mi.OWPMatchId
	,f.val
FROM MatchInfo AS mi WITH (NOLOCK)
	CROSS APPLY dbo.fnc_SplitStrings(mi.[TVCode], ',') AS f
WHERE mi.[TVCode] IS NOT NULL
GO

UPDATE dbo.ValidationRule WITH (ROWLOCK)
SET RuleResultType = 1 
WHERE RuleId=28

UPDATE dbo.ValidationRule WITH (ROWLOCK)
SET RuleResultType = 1 
WHERE RuleId=29

GO