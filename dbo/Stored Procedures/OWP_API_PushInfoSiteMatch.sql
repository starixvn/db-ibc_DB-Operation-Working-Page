
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_API_PushInfoSiteMatch] @XML NVARCHAR(MAX)
AS
/*    
 Created: 20181030@Leo.Vo
 Task : Push InfoSite match
 DB: bodb_OWP    
    
 Revisions:
	20181030@Leo.Vo: Initial SP - [Redmine: #103598]
	20181127@Leo.Vo: Distinct LeagueName before inserting - [Redmine: #103598]
	20181129@Leo.Vo: Not sync Agent - [Redmine: #105574]
	20181129@Leo.Vo: Not sync Agent - [Redmine: #105574]
	20190108@Kane.Le: Update Field IsDeleted - [Redmine: #105574]
	20190403@Raymond.Le: Correct data type for columns - [Redmine: #111068]
	20190918@Kane.Le: Update AgentIds - [Redmine: #120415]
	20191014@Leo.Vo: Fix issue job failed - [Redmine: #121722]
	20191108@Leo.Vo: Add venue - [Redmine: #123167]
	20200713@Jacob: ImportingMatchInNeutralStadium - [Redmine: #137417]
	20200728@carlos.Nguyen: Update data Streaming sync from InfoSite - [Redmine: #137755]
	20200913@Jacob: Sync Live Status to InfoSite - [Redmine: #134336]
	20201105@Jacob: New column ETPK - [Redmine: #144570]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT

	--list of upload values of TV
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

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@XML

	CREATE TABLE #tblInfoSiteMatch (
		 [InfoSiteMatchId] [int] NOT NULL
		,[AdminSiteMatchId] INT 
		,[IsLive] BIT NOT NULL
		,[EventDateTime] [datetime] NOT NULL
		,[UpdatedTime] [datetime] NOT NULL
		,[LeagueName] [nvarchar](500) NOT NULL
		,[HomeName] [nvarchar](200) NOT NULL
		,[AwayName] [nvarchar](200) NOT NULL
		,[Round] [nvarchar](2000) NULL
		,[Division] [nvarchar](2000) NULL
		,[Agent] [nvarchar](2000) NULL
		,[Venue] [nvarchar](100) NULL
		,[TV] [nvarchar](2000) NULL
		,[Channel] [nvarchar](100) NULL
		,[WB] [nvarchar](100) NULL
		,[Website1] [nvarchar](1000) NULL
		,[Website2] [nvarchar](1000) NULL
		,[Website3] [nvarchar](1000) NULL
		,[Website4] [nvarchar](1000) NULL
		,[OWPLeagueId] INT NULL
		,[OWPHomeId] INT NULL
		,[OWPAwayId] INT NULL
		,[TVIds] VARCHAR(200) NULL
		,AgentIds VARCHAR(200) NULL		
		,[IsNeutral] BIT NULL
		,[IPTV] NVARCHAR(2000) NULL
		,[ETPK] NVARCHAR(2000) NULL
		)

	INSERT INTO #tblInfoSiteMatch (
		 [InfoSiteMatchId]
		,[AdminSiteMatchId]
		,[IsLive] 
		,[EventDateTime]
		,[UpdatedTime]
		,[LeagueName]
		,[HomeName]
		,[AwayName]
		,[Round]
		,[Division]
		,[Agent]
		,[Venue]
		,[TV]
		,[Channel]
		,[WB]
		,[Website1]
		,[Website2]
		,[Website3]
		,[Website4]
		,[IsNeutral]
		,[IPTV]
		,[ETPK]
		)
	SELECT [InfoSiteMatchId]
	    ,[AdminSiteMatchId]
		,[IsLive] 
		,[EventDateTime]
		,[UpdatedTime]
		,[LeagueName]
		,[HomeName]
		,[AwayName]
		,[Round]
		,[Division]
		,[Agent]
		,[Venue]
		,[LocalTV]
		,[LiveTV]
		,[WatchBet]
		,[Website1]
		,[Website2]
		,[Website3]
		,[Website4]
		,[IsNeutral]
		,[IPTV]
		,[ETPK]
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
			 [InfoSiteMatchId] [int]
			,[AdminSiteMatchId] [int]
			,[IsLive] BIT
			,[EventDateTime] [datetime]
			,[UpdatedTime] [datetime]
			,[LeagueName] [nvarchar](500)
			,[HomeName] [nvarchar](200)
			,[AwayName] [nvarchar](200)
			,[Round] [nvarchar](2000)
			,[Division] [nvarchar](2000)
			,[Agent] [nvarchar](2000)
			,[Venue] [nvarchar](100)
			,[LocalTV] [nvarchar](2000)
			,[LiveTV] [nvarchar](100)
			,[WatchBet] [nvarchar](100)
			,[Website1] [nvarchar](1000)
			,[Website2] [nvarchar](1000)
			,[Website3] [nvarchar](1000)
			,[Website4] [nvarchar](1000)
			,[IsNeutral] BIT
			,[Iptv][nvarchar](2000)
			,[ETPK][nvarchar](2000) 
			)

	EXEC sp_xml_removedocument @idoc

	-- not process on records deleted or not updated
	DELETE tism
	FROM #tblInfoSiteMatch AS tism
	INNER JOIN dbo.InfoSiteMatch AS dism WITH (NOLOCK) ON tism.InfoSiteMatchId = dism.InfoSiteMatchId
	WHERE (tism.UpdatedTime = dism.UpdatedTime AND tism.IsLive = dism.IsLive) OR dism.IsDeleted = 1 

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
	SELECT im.TeamName
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
	INNER JOIN dbo.OWPTeam AS t WITH (NOLOCK) ON im.HomeName = t.OWPTeamName

	-- update OWPAwayId
	UPDATE im
	SET im.OWPAwayId = t.OWPTeamId
	FROM #tblInfoSiteMatch AS im
	INNER JOIN dbo.OWPTeam AS t WITH (NOLOCK) ON im.AwayName = t.OWPTeamName

	-- insert new TV
	TRUNCATE TABLE #tblTextList
	TRUNCATE TABLE #tblDistinctTextList

	INSERT INTO #tblTextList (
		InfoSiteMatchId
		,[Text]
		)
	SELECT im.InfoSiteMatchId
		,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR)
	FROM #tblInfoSiteMatch AS im
	CROSS APPLY dbo.fnc_SplitStrings(im.TV, ',') AS d
	WHERE im.TV <> ''
		AND RTRIM(LTRIM(d.val)) <> ''

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

	UPDATE im
	SET im.TVIds = STUFF((
				SELECT ',' + CAST(Id AS VARCHAR(10))
				FROM #tblDistinctTextList AS tl
				WHERE tl.InfoSiteMatchId = im.InfoSiteMatchId
				FOR XML PATH('')
				), 1, 1, '')
	FROM #tblInfoSiteMatch AS im

	-- insert new Agent
	TRUNCATE TABLE #tblTextList
	TRUNCATE TABLE #tblDistinctTextList

	INSERT INTO #tblTextList (
		InfoSiteMatchId
		,[Text]
		)
	SELECT im.InfoSiteMatchId
		,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR)
	FROM #tblInfoSiteMatch AS im
	CROSS APPLY dbo.fnc_SplitStrings(im.Agent, ',') AS d
	WHERE im.Agent <> ''
		AND RTRIM(LTRIM(d.val)) <> ''

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

	INSERT INTO dbo.Agent(AgentName)
	SELECT DISTINCT tl.[Text]
	FROM #tblDistinctTextList AS tl
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.Agent WITH (NOLOCK)
			WHERE AgentName = tl.[Text]
			)

	UPDATE tl
	SET tl.Id = tv.AgentId
	FROM #tblDistinctTextList AS tl
	INNER JOIN dbo.Agent AS tv WITH (NOLOCK) ON tl.[Text] = tv.AgentName

	UPDATE im
	SET im.AgentIds = STUFF((
				SELECT ',' + CAST(Id AS VARCHAR(10))
				FROM #tblDistinctTextList AS tl
				WHERE tl.InfoSiteMatchId = im.InfoSiteMatchId
				FOR XML PATH('')
				), 1, 1, '')
	FROM #tblInfoSiteMatch AS im

	MERGE INTO dbo.InfoSiteMatch AS t
	USING (
		SELECT [InfoSiteMatchId]
		    ,[AdminSiteMatchId]
			,[EventDateTime]
			,[UpdatedTime]
			,[LeagueName]
			,[HomeName]
			,[AwayName]
			,[Round]
			,[Division]
			,[Agent]
			,[Venue]
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
			,[TVIds]
			,[AgentIds]
			,[IsNeutral]
			,[IPTV]
			,[ETPK]
			,[IsLive]			
		FROM #tblInfoSiteMatch
		) AS s
		ON t.[InfoSiteMatchId] = s.[InfoSiteMatchId]
	WHEN MATCHED AND t.[IsDeleted] = 0
		THEN
			UPDATE
			SET t.[InfoSiteMatchId] = s.[InfoSiteMatchId]
			    ,t.[AdminSiteMatchId] = s.[AdminSiteMatchId]
				,t.[EventDateTime] = s.[EventDateTime]
				,t.[UpdatedTime] = s.[UpdatedTime]
				,t.[LeagueName] = s.[LeagueName]
				,t.[HomeName] = s.[HomeName]
				,t.[AwayName] = s.[AwayName]
				,t.[Round] = s.[Round]
				,t.[Division] = s.[Division]
				,t.[Agent] = s.[Agent]
				,t.[Venue] = s.[Venue]
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
				,t.[TVIds] = s.[TVIds]
				,t.[AgentIds] = s.[AgentIds]
				,t.[IsDeleted] = 0
				,t.[IsNeutral] = s.[IsNeutral]
				,t.[IPTV]=s.[IPTV]
				,t.[ETPK]=s.[ETPK]
				,t.[IsLive]=s.[IsLive]
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				[InfoSiteMatchId]
				,[AdminSiteMatchId]
				,[EventDateTime]
				,[UpdatedTime]
				,[LeagueName]
				,[HomeName]
				,[AwayName]
				,[Round]
				,[Division]
				,[Agent]
				,[Venue]
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
				,[TVIds]
				,[AgentIds]
				,[IsDeleted]
				,[IsNeutral]
				,[IPTV]
				,[ETPK]
				,[IsLive]
				)
			VALUES (
				s.[InfoSiteMatchId]
				,s.[AdminSiteMatchId]
				,s.[EventDateTime]
				,s.[UpdatedTime]
				,s.[LeagueName]
				,s.[HomeName]
				,s.[AwayName]
				,s.[Round]
				,s.[Division]
				,s.[Agent]
				,s.[Venue]
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
				,s.[TVIds]
				,s.[AgentIds]
				,0
				,[IsNeutral]
				,[IPTV]
				,s.[ETPK]
				,[IsLive]
				);

	DROP TABLE #tblInfoSiteMatch

	DROP TABLE #tblTextList

	DROP TABLE #tblDistinctTextList
END