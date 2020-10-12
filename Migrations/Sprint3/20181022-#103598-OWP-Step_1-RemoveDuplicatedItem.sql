/*
	Created: Raymond.Le
	Date: 2018-10-22
	Task: Remove Duplicated TV, Agent, Provider, Runner
	DB: bodb_OWP
*/

USE [bodb_OWP]
GO

CREATE TABLE #tblUniqueItem (
	Id INT
	,[Text] NVARCHAR(100)
	)

CREATE TABLE #tblDuplicatedItem (
	Id INT
	,UniqueId INT
	)

CREATE TABLE #tblMatchItem (
	OWPMatchId INT
	,ItemId INT
	)

CREATE TABLE #tblReplacedMatchItem (
	OWPMatchId INT
	,ItemId INT
	)

/*------Television--------*/
-- get unique item
INSERT INTO #tblUniqueItem (
	Id
	,[Text]
	)
SELECT MIN(tv.TVId)
	,TVCode
FROM dbo.Television AS tv WITH (NOLOCK)
GROUP BY tv.TVCode

-- get duplicated item
INSERT INTO #tblDuplicatedItem (
	Id
	,UniqueId
	)
SELECT item.Id
	,ui.Id
FROM (
	SELECT tv.TVId AS Id
		,tv.TVCode AS [Text]
	FROM dbo.Television AS tv WITH (NOLOCK)
	
	EXCEPT
	SELECT Id
		,[Text]
	FROM #tblUniqueItem
	) AS item
	INNER JOIN #tblUniqueItem AS ui ON ui.[Text] = item.[Text]

-- split Ids into table
INSERT INTO #tblMatchItem (
	OWPMatchId
	,ItemId
	)
SELECT mi.OWPMatchId
	,t.val
FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	CROSS APPLY dbo.fnc_SplitStrings(mi.TVCode, ',') AS t
WHERE mi.TVCode IS NOT NULL
	AND mi.TVCode <> ''

-- insert match replaced Id into table
INSERT INTO #tblReplacedMatchItem (
	OWPMatchId
	,ItemId
	)
SELECT md.OWPMatchId
	,di.UniqueId
FROM (
	SELECT DISTINCT item.OWPMatchId
	FROM #tblMatchItem AS item
		INNER JOIN #tblDuplicatedItem AS di ON di.Id = item.ItemId
	) AS md
	INNER JOIN #tblMatchItem AS mi ON md.OWPMatchId = mi.OWPMatchId
	LEFT JOIN #tblDuplicatedItem AS di ON di.Id = mi.ItemId

-- Update table MatchInfo
UPDATE mi WITH (ROWLOCK, UPDLOCK)
SET mi.TVCode = STUFF((
			SELECT ',' + CAST(ri.ItemId AS VARCHAR(10))
			FROM #tblReplacedMatchItem AS ri
			WHERE mi.OWPMatchId = ri.OWPMatchId
			FOR XML PATH('')
			), 1, 1, '')
FROM dbo.MatchInfo AS mi
INNER JOIN #tblReplacedMatchItem AS ri ON mi.OWPMatchId = ri.OWPMatchId 

-- Remove duplicated item in table Television
DELETE tv
FROM dbo.Television AS tv
INNER JOIN #tblDuplicatedItem AS di ON tv.TVId = di.Id

/*------Agent--------*/
TRUNCATE TABLE #tblUniqueItem
TRUNCATE TABLE #tblDuplicatedItem
TRUNCATE TABLE #tblMatchItem
TRUNCATE TABLE #tblReplacedMatchItem
-- get unique item
INSERT INTO #tblUniqueItem (
	Id
	,[Text]
	)
SELECT MIN(a.AgentId)
	,a.AgentName
FROM dbo.Agent AS a WITH (NOLOCK)
GROUP BY a.AgentName

-- get duplicated item
INSERT INTO #tblDuplicatedItem (
	Id
	,UniqueId
	)
SELECT item.Id
	,ui.Id
FROM (
	SELECT a.AgentId AS Id
		,a.AgentName AS [Text]
	FROM dbo.Agent AS a WITH (NOLOCK)
	
	EXCEPT
	SELECT Id
		,[Text]
	FROM #tblUniqueItem
	) AS item
	INNER JOIN #tblUniqueItem AS ui ON ui.[Text] = item.[Text]

-- split Ids into table
INSERT INTO #tblMatchItem (
	OWPMatchId
	,ItemId
	)
SELECT mi.OWPMatchId
	,t.val
FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	CROSS APPLY dbo.fnc_SplitStrings(mi.Agent, ',') AS t
WHERE mi.Agent IS NOT NULL
	AND mi.Agent <> ''

-- insert match replaced Id into table
INSERT INTO #tblReplacedMatchItem (
	OWPMatchId
	,ItemId
	)
SELECT md.OWPMatchId
	,di.UniqueId
FROM (
	SELECT DISTINCT item.OWPMatchId
	FROM #tblMatchItem AS item
		INNER JOIN #tblDuplicatedItem AS di ON di.Id = item.ItemId
	) AS md
	INNER JOIN #tblMatchItem AS mi ON md.OWPMatchId = mi.OWPMatchId
	LEFT JOIN #tblDuplicatedItem AS di ON di.Id = mi.ItemId

-- Update table MatchInfo
UPDATE mi WITH (ROWLOCK, UPDLOCK)
SET mi.Agent = STUFF((
			SELECT ',' + CAST(ri.ItemId AS VARCHAR(10))
			FROM #tblReplacedMatchItem AS ri
			WHERE mi.OWPMatchId = ri.OWPMatchId
			FOR XML PATH('')
			), 1, 1, '')
FROM dbo.MatchInfo AS mi
INNER JOIN #tblReplacedMatchItem AS ri ON mi.OWPMatchId = ri.OWPMatchId 

-- Remove duplicated item in table Agent
DELETE a
FROM dbo.Agent AS a
INNER JOIN #tblDuplicatedItem AS di ON a.AgentId = di.Id

/*------Provider--------*/
TRUNCATE TABLE #tblUniqueItem
TRUNCATE TABLE #tblDuplicatedItem
TRUNCATE TABLE #tblMatchItem
TRUNCATE TABLE #tblReplacedMatchItem

-- get unique item
INSERT INTO #tblUniqueItem (
	Id
	,[Text]
	)
SELECT MIN(p.ProviderId)
	,p.ProviderName
FROM dbo.[Provider] AS p WITH (NOLOCK)
GROUP BY p.ProviderName

-- get duplicated item
INSERT INTO #tblDuplicatedItem (
	Id
	,UniqueId
	)
SELECT item.Id
	,ui.Id
FROM (
	SELECT p.ProviderId AS Id
		,p.ProviderName AS [Text]
	FROM dbo.[Provider] AS p WITH (NOLOCK)
	
	EXCEPT
	SELECT Id
		,[Text]
	FROM #tblUniqueItem
	) AS item
	INNER JOIN #tblUniqueItem AS ui ON ui.[Text] = item.[Text]

-- split Ids into table
INSERT INTO #tblMatchItem (
	OWPMatchId
	,ItemId
	)
SELECT mi.OWPMatchId
	,t.val
FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	CROSS APPLY dbo.fnc_SplitStrings(mi.[Provider], ',') AS t
WHERE mi.[Provider] IS NOT NULL
	AND mi.[Provider] <> ''

-- insert match replaced Id into table
INSERT INTO #tblReplacedMatchItem (
	OWPMatchId
	,ItemId
	)
SELECT md.OWPMatchId
	,di.UniqueId
FROM (
	SELECT DISTINCT item.OWPMatchId
	FROM #tblMatchItem AS item
		INNER JOIN #tblDuplicatedItem AS di ON di.Id = item.ItemId
	) AS md
	INNER JOIN #tblMatchItem AS mi ON md.OWPMatchId = mi.OWPMatchId
	LEFT JOIN #tblDuplicatedItem AS di ON di.Id = mi.ItemId

-- Update table MatchInfo
UPDATE mi WITH (ROWLOCK, UPDLOCK)
SET mi.[Provider] = STUFF((
			SELECT ',' + CAST(ri.ItemId AS VARCHAR(10))
			FROM #tblReplacedMatchItem AS ri
			WHERE mi.OWPMatchId = ri.OWPMatchId
			FOR XML PATH('')
			), 1, 1, '')
FROM dbo.MatchInfo AS mi
INNER JOIN #tblReplacedMatchItem AS ri ON mi.OWPMatchId = ri.OWPMatchId 

-- Remove duplicated item in table Provider
DELETE p
FROM dbo.[Provider] AS p
INNER JOIN #tblDuplicatedItem AS di ON p.ProviderId = di.Id

/*------Runner--------*/
TRUNCATE TABLE #tblUniqueItem
TRUNCATE TABLE #tblDuplicatedItem
TRUNCATE TABLE #tblMatchItem
TRUNCATE TABLE #tblReplacedMatchItem

-- get unique item
INSERT INTO #tblUniqueItem (
	Id
	,[Text]
	)
SELECT MIN(r.RunnerId)
	,r.RunnerName
FROM dbo.Runner AS r WITH (NOLOCK)
GROUP BY r.RunnerName

-- get duplicated item
INSERT INTO #tblDuplicatedItem (
	Id
	,UniqueId
	)
SELECT item.Id
	,ui.Id
FROM (
	SELECT r.RunnerId AS Id
		,r.RunnerName AS [Text]
	FROM dbo.Runner AS r WITH (NOLOCK)
	
	EXCEPT
	SELECT Id
		,[Text]
	FROM #tblUniqueItem
	) AS item
	INNER JOIN #tblUniqueItem AS ui ON ui.[Text] = item.[Text]

-- split Ids into table
INSERT INTO #tblMatchItem (
	OWPMatchId
	,ItemId
	)
SELECT mi.OWPMatchId
	,t.val
FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	CROSS APPLY dbo.fnc_SplitStrings(mi.Runner, ',') AS t
WHERE mi.Runner IS NOT NULL
	AND mi.Runner <> ''

-- insert match replaced Id into table
INSERT INTO #tblReplacedMatchItem (
	OWPMatchId
	,ItemId
	)
SELECT md.OWPMatchId
	,di.UniqueId
FROM (
	SELECT DISTINCT item.OWPMatchId
	FROM #tblMatchItem AS item
		INNER JOIN #tblDuplicatedItem AS di ON di.Id = item.ItemId
	) AS md
	INNER JOIN #tblMatchItem AS mi ON md.OWPMatchId = mi.OWPMatchId
	LEFT JOIN #tblDuplicatedItem AS di ON di.Id = mi.ItemId

-- Update table MatchInfo
UPDATE mi WITH (ROWLOCK, UPDLOCK)
SET mi.Runner = STUFF((
			SELECT ',' + CAST(ri.ItemId AS VARCHAR(10))
			FROM #tblReplacedMatchItem AS ri
			WHERE mi.OWPMatchId = ri.OWPMatchId
			FOR XML PATH('')
			), 1, 1, '')
FROM dbo.MatchInfo AS mi
INNER JOIN #tblReplacedMatchItem AS ri ON mi.OWPMatchId = ri.OWPMatchId 

-- Remove duplicated item in table Runner
DELETE r
FROM dbo.Runner AS r
INNER JOIN #tblDuplicatedItem AS di ON r.RunnerId = di.Id

DROP TABLE #tblUniqueItem

DROP TABLE #tblDuplicatedItem

DROP TABLE #tblMatchItem

DROP TABLE #tblReplacedMatchItem

