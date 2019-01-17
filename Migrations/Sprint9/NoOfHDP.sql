-- init data NoOfHDP in table RefResource
INSERT INTO dbo.RefResource(RefName, ResourceId, [Value])
VALUES ('NoOfHDP', 1, '1HDP'), ('NoOfHDP', 2, '2HDP'), ('NoOfHDP', 3, '3HDP'), ('NoOfHDP', 4, '4DHP') 
GO

-- change rule
UPDATE dbo.ValidationRule
SET MessageFormat = 'Invalid NO.HDP: <content>'
WHERE RuleId = 28
GO

-- add new column NoOfHDPId in table MatchInfo
ALTER TABLE dbo.MatchInfo ADD NoOfHDPId INT DEFAULT(0)
GO

-- migrate data
UPDATE mi
SET mi.NoOfHDPId = r.ResourceId
FROM dbo.MatchInfo AS mi WITH (ROWLOCK)
	LEFT JOIN (
	SELECT ResourceId
		,Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'NoOfHDP'
	) AS r ON mi.NoOfHDP = r.Value
GO

-- drop column NoOfHDP in table MatchInfo
ALTER TABLE dbo.MatchInfo
DROP COLUMN NoOfHDP
GO