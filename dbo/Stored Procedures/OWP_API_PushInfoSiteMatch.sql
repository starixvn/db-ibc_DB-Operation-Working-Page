
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_API_PushInfoSiteMatch] @XML NVARCHAR(MAX)
AS
/*    
 Created: 20181030@Leo.Vo
 Task : Push InfoSite match
 DB: bodb_OWP    
    
 Revisions:
	20181030@Leo.Vo: Initial SP - [Redmine: #103598]
	20181127@Leo.Vo: Distinct LeagueName before inserting - [Redmine: #103598]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT

	--list of upload values of TV, Agent
	CREATE TABLE #tblTextList (
		InfoSiteMatchId INT NOT NULL
		,[Text] NVARCHAR(100) NOT NULL
		,OrderId INT IDENTITY(1, 1)
		)

	CREATE TABLE #tblDistinctTextList (
		InfoSiteMatchId INT NOT NULL
		,Id INT
		,[Text] NVARCHAR(100) NOT NULL
		)

	CREATE TABLE #tblInfoSiteMatchAgent (
		OWPMatchId INT NOT NULL
		,AgentIds VARCHAR(200)
		)

	CREATE TABLE #tblInfoSiteMatchTV (
		OWPMatchId INT NOT NULL
		,TVIds VARCHAR(200)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@XML

	CREATE TABLE #tblInfoSiteMatch (
		[InfoSiteMatchId] [int] NOT NULL
		,[EventDateTime] [datetime] NOT NULL
		,[UpdatedTime] [datetime] NOT NULL
		,[LeagueName] [nvarchar](2000) NOT NULL
		,[HomeName] [nvarchar](2000) NOT NULL
		,[AwayName] [nvarchar](2000) NOT NULL
		,[Round] [nvarchar](2000) NULL
		,[Division] [nvarchar](2000) NULL
		,[Agent] [nvarchar](2000) NULL
		,[TV] [nvarchar](2000) NULL
		,[Channel] [nvarchar](2000) NULL
		,[WB] [nvarchar](2000) NULL
		,[Website1] [nvarchar](2000) NULL
		,[Website2] [nvarchar](2000) NULL
		,[Website3] [nvarchar](2000) NULL
		,[Website4] [nvarchar](2000) NULL
		,[OWPLeagueId] INT NULL
		,[OWPHomeId] INT NULL
		,[OWPAwayId] INT NULL
		,[AgentIds] VARCHAR(200) NULL
		,[TVIds] VARCHAR(200) NULL
		)

	INSERT INTO #tblInfoSiteMatch (
		[InfoSiteMatchId]
		,[EventDateTime]
		,[UpdatedTime]
		,[LeagueName]
		,[HomeName]
		,[AwayName]
		,[Round]
		,[Division]
		,[Agent]
		,[TV]
		,[Channel]
		,[WB]
		,[Website1]
		,[Website2]
		,[Website3]
		,[Website4]
		)
	SELECT [InfoSiteMatchId]
		,[EventDateTime]
		,[UpdatedTime]
		,[LeagueName]
		,[HomeName]
		,[AwayName]
		,[Round]
		,[Division]
		,[Agent]
		,[LocalTV]
		,[LiveTV]
		,[WatchBet]
		,[Website1]
		,[Website2]
		,[Website3]
		,[Website4]
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH ([InfoSiteMatchId] [int], [EventDateTime] [datetime], [UpdatedTime] [datetime], [LeagueName] [nvarchar](2000), [HomeName] [nvarchar](2000), [AwayName] [nvarchar](2000), [Round] [nvarchar](2000), [Division] [nvarchar](2000), [Agent] [nvarchar](2000), [LocalTV] [nvarchar](2000), [LiveTV] [nvarchar](2000), [WatchBet] [nvarchar](2000), [Website1] [nvarchar](2000), [Website2] [nvarchar](2000), [Website3] [nvarchar](2000), [Website4] [nvarchar](2000))

	EXEC sp_xml_removedocument @idoc

	-- not process on existed records and no update
	DELETE tism
	FROM #tblInfoSiteMatch AS tism
		INNER JOIN dbo.InfoSiteMatch AS dism WITH (NOLOCK) ON tism.InfoSiteMatchId = dism.InfoSiteMatchId
		AND tism.UpdatedTime = dism.UpdatedTime

	-- insert new league
	INSERT INTO dbo.OWPLeague (OWPLeagueName)
	SELECT DISTINCT im.LeagueName
	FROM #tblInfoSiteMatch AS im
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPLeague AS l WITH (NOLOCK)
			WHERE im.LeagueName = l.OWPLeagueName
			)

	-- update OWPLeagueId
	UPDATE im
	SET im.OWPLeagueId = l.OWPLeagueId
	FROM #tblInfoSiteMatch AS im
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON im.LeagueName = l.OWPLeagueName

	-- insert new team
	INSERT INTO dbo.OWPTeam (OWPTeamName)
	SELECT TeamName
	FROM (
		SELECT im.HomeName AS TeamName
		FROM #tblInfoSiteMatch AS im
		
		UNION
		SELECT im.AwayName AS TeamName
		FROM #tblInfoSiteMatch AS im
		) AS im
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPTeam AS t WITH (NOLOCK)
			WHERE im.TeamName = t.OWPTeamName
			)

	-- update OWPHomeId
	UPDATE im
	SET im.OWPHomeId = t.OWPTeamId
	FROM #tblInfoSiteMatch AS im
		INNER JOIN dbo.OWPTeam AS t ON im.HomeName = t.OWPTeamName

	-- update OWPAwayId
	UPDATE im
	SET im.OWPAwayId = t.OWPTeamId
	FROM #tblInfoSiteMatch AS im
		INNER JOIN dbo.OWPTeam AS t ON im.AwayName = t.OWPTeamName

	-- insert new Agent
	TRUNCATE TABLE #tblTextList

	INSERT INTO #tblTextList (
		InfoSiteMatchId
		,[Text]
		)
	SELECT im.InfoSiteMatchId
		,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR(100))
	FROM #tblInfoSiteMatch AS im
		CROSS APPLY dbo.fnc_SplitStrings(im.Agent, ',') AS d
	WHERE im.Agent <> ''
		AND RTRIM(LTRIM(d.val)) <> ''

	TRUNCATE TABLE #tblDistinctTextList

	INSERT INTO #tblDistinctTextList (
		InfoSiteMatchId
		,[Text]
		)
	SELECT InfoSiteMatchId
		,[Text]
	FROM #tblTextList
	GROUP BY InfoSiteMatchId
		,[Text]
	ORDER BY MIN(OrderId) ASC

	INSERT INTO dbo.Agent (AgentName)
	SELECT DISTINCT tl.[Text]
	FROM #tblDistinctTextList AS tl
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.Agent WITH (NOLOCK)
			WHERE AgentName = tl.[Text]
			)

	UPDATE tl
	SET tl.Id = a.AgentId
	FROM #tblDistinctTextList AS tl
		INNER JOIN dbo.Agent AS a WITH (NOLOCK) ON tl.[Text] = a.AgentName

	-- update AgentIds
	UPDATE im
	SET im.AgentIds = STUFF((
				SELECT ',' + CAST(Id AS VARCHAR(10))
				FROM #tblDistinctTextList AS tl
				WHERE tl.InfoSiteMatchId = im.InfoSiteMatchId
				FOR XML PATH('')
				), 1, 1, '')
	FROM #tblInfoSiteMatch AS im

	-- insert new TV
	TRUNCATE TABLE #tblTextList

	INSERT INTO #tblTextList (
		InfoSiteMatchId
		,[Text]
		)
	SELECT im.InfoSiteMatchId
		,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR(100))
	FROM #tblInfoSiteMatch AS im
		CROSS APPLY dbo.fnc_SplitStrings(im.TV, ',') AS d
	WHERE im.TV <> ''
		AND RTRIM(LTRIM(d.val)) <> ''

	TRUNCATE TABLE #tblDistinctTextList

	INSERT INTO #tblDistinctTextList (
		InfoSiteMatchId
		,[Text]
		)
	SELECT InfoSiteMatchId
		,[Text]
	FROM #tblTextList
	GROUP BY InfoSiteMatchId
		,[Text]
	ORDER BY MIN(OrderId) ASC

	INSERT INTO dbo.Television (TVCode)
	SELECT DISTINCT tl.[Text]
	FROM #tblDistinctTextList AS tl
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.Television WITH (NOLOCK)
			WHERE TVCode = tl.[Text]
			)

	UPDATE tl
	SET tl.Id = tv.TVId
	FROM #tblDistinctTextList AS tl
		INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON tl.[Text] = tv.TVCode

	-- update TVIds
	UPDATE im
	SET im.TVIds = STUFF((
				SELECT ',' + CAST(Id AS VARCHAR(10))
				FROM #tblDistinctTextList AS tl
				WHERE tl.InfoSiteMatchId = im.InfoSiteMatchId
				FOR XML PATH('')
				), 1, 1, '')
	FROM #tblInfoSiteMatch AS im

	MERGE INTO dbo.InfoSiteMatch AS t
	USING (
		SELECT [InfoSiteMatchId]
			,[EventDateTime]
			,[UpdatedTime]
			,[LeagueName]
			,[HomeName]
			,[AwayName]
			,[Round]
			,[Division]
			,[Agent]
			,[TV]
			,[Channel]
			,[WB]
			,[Website1]
			,[Website2]
			,[Website3]
			,[Website4]
			,[OWPLeagueId]
			,[OWPHomeId]
			,[OWPAwayId]
			,[AgentIds]
			,[TVIds]
		FROM #tblInfoSiteMatch
		) AS s ON t.[InfoSiteMatchId] = s.[InfoSiteMatchId]
	WHEN MATCHED THEN
			UPDATE
			SET t.[InfoSiteMatchId] = s.[InfoSiteMatchId]
				,t.[EventDateTime] = s.[EventDateTime]
				,t.[UpdatedTime] = s.[UpdatedTime]
				,t.[LeagueName] = s.[LeagueName]
				,t.[HomeName] = s.[HomeName]
				,t.[AwayName] = s.[AwayName]
				,t.[Round] = s.[Round]
				,t.[Division] = s.[Division]
				,t.[Agent] = s.[Agent]
				,t.[TV] = s.[TV]
				,t.[Channel] = s.[Channel]
				,t.[WB] = s.[WB]
				,t.[Website1] = s.[Website1]
				,t.[Website2] = s.[Website2]
				,t.[Website3] = s.[Website3]
				,t.[Website4] = s.[Website4]
				,t.[OWPLeagueId] = s.[OWPLeagueId]
				,t.[OWPHomeId] = s.[OWPHomeId]
				,t.[OWPAwayId] = s.[OWPAwayId]
				,t.[AgentIds] = s.[AgentIds]
				,t.[TVIds] = s.[TVIds]
	WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				[InfoSiteMatchId]
				,[EventDateTime]
				,[UpdatedTime]
				,[LeagueName]
				,[HomeName]
				,[AwayName]
				,[Round]
				,[Division]
				,[Agent]
				,[TV]
				,[Channel]
				,[WB]
				,[Website1]
				,[Website2]
				,[Website3]
				,[Website4]
				,[OWPLeagueId]
				,[OWPHomeId]
				,[OWPAwayId]
				,[AgentIds]
				,[TVIds]
				)
			VALUES (
				s.[InfoSiteMatchId]
				,s.[EventDateTime]
				,s.[UpdatedTime]
				,s.[LeagueName]
				,s.[HomeName]
				,s.[AwayName]
				,s.[Round]
				,s.[Division]
				,s.[Agent]
				,s.[TV]
				,s.[Channel]
				,s.[WB]
				,s.[Website1]
				,s.[Website2]
				,s.[Website3]
				,s.[Website4]
				,s.[OWPLeagueId]
				,s.[OWPHomeId]
				,s.[OWPAwayId]
				,s.[AgentIds]
				,s.[TVIds]
				);

	DROP TABLE #tblInfoSiteMatch

	DROP TABLE #tblTextList

	DROP TABLE #tblDistinctTextList

	DROP TABLE #tblInfoSiteMatchAgent

	DROP TABLE #tblInfoSiteMatchTV
END