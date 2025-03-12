/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

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
	20201106@Jacob: Increase casting size - [Redmine: #144570]
	20210128@CarlosNguyen: Sync MatchCode - [Redmine: #149347]
	20211109@CarlosNguyen: Solve deadlock issue of InfoSite event sync - [Redmine: #164343]
	20211119@CarlosNguyen: Enhance-auto-assignment - [Redmine: #163362]
	20211214@Liam.Pham: Sync ProviderTV - [Redmine: #163362]
	20220224@tyler: upgrade XML package - [Redmine: #168050]   
	20220510@Mira: Update IsDeleted for re-created events - [Redmine: #172559]   
	20221110@Liam.Pham: Sync more info - [Redmine: #179302]
	20240307@Mira: Save IsHomeBlackList column - [Redmine: #201375]
	20240325@Mira: correct agent length - [Redmine: #202817]
	20240327@Mira: solve deadlock - [Redmine: #200841]
	20240419@Mira: save league, home, away blacklist column - [Redmine: #203309]
	20240423@Mira: save team round column, resolve blacklist - [Redmine: #204002]
	20241113@Frankie: not change provider field after insert new match - [Redmine: #213590]
	20241125@Tim: sync MatchStatus, HomeBadRanking, AwayBadRanking, HomeDowngrade, AwayDowngrade, RoundConfirm - [Redmine: #214095]
	20250210@Frankie: sync IsPostponed - [Redmine: #216746]
	20250302@Frankie: change condition change provider [Redmine: #218237]
	20250312@Frankie: Add column 'LastStatus' table InfoSiteMatch [Redmine: #219537]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT

	--list of upload values of TV
	CREATE TABLE #tblTextList (
		InfoSiteMatchId INT NOT NULL
		,[Text] NVARCHAR(2000) NOT NULL
		,OrderId INT IDENTITY(1, 1)
		)

	CREATE TABLE #tblDistinctTextList (
		InfoSiteMatchId INT NOT NULL
		,Id INT
		,[Text] NVARCHAR(2000) NOT NULL
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
		,[TeamRound] [nvarchar](2000) NULL
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
		,[MatchCode] NVARCHAR(50)
		,[Provider] NVARCHAR(2000)
		,[OtherProvider] NVARCHAR(2000)
		,[Remark] NVARCHAR(2000)
		,[ProviderUsed] NVARCHAR(2000)
		,[ProviderTV] NVARCHAR(200)
		,[IsTest] BIT 
		,[Remark2] NVARCHAR(2000)
		,[HomeRemark] NVARCHAR(2000)
		,[AwayRemark] NVARCHAR(2000)
		,[TotalRound] NVARCHAR(2000)
		,[IsLeagueBlackList] BIT
		,[IsHomeBlackList] BIT
		,[IsAwayBlackList] BIT
		,IsHomeBadRanking BIT
		,IsAwayBadRanking BIT
		,IsHomeDowngrade BIT
		,IsAwayDowngrade BIT
		,IsPostponed BIT
		,LastStatus NVARCHAR(20)
		,MatchStatus TINYINT
		,RoundConfirm VARCHAR(3)
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
		,[TeamRound]
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
		,[MatchCode]
		,[Provider]
		,[OtherProvider]
		,[Remark]
		,[ProviderUsed]
		,[ProviderTV]
		,[IsTest]
		,[Remark2] 
		,[HomeRemark]
		,[AwayRemark] 
		,[TotalRound]
		,[IsLeagueBlackList]
		,[IsHomeBlackList]
		,[IsAwayBlackList]
		,IsHomeBadRanking
		,IsAwayBadRanking
		,IsHomeDowngrade
		,IsAwayDowngrade
		,IsPostponed
		,LastStatus
		,MatchStatus
		,RoundConfirm
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
		,[TeamRound]
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
		,[MatchCode]
		,[Provider]
		,[OtherProvider]
		,[Remark]
		,[ProviderUsed]
		,[ProviderTV]
		,[IsTest]
		,[Remark2] 
		,[HomeRemark]
		,[AwayRemark] 
		,[TotalRound]
		,[IsLeagueBlackList]
		,[IsHomeBlackList]
		,[IsAwayBlackList]
		,IsHomeBadRanking
		,IsAwayBadRanking
		,IsHomeDowngrade
		,IsAwayDowngrade
		,IsPostponed
		,LastStatus
		,MatchStatus
		,RoundConfirm
	FROM OPENXML(@idoc, '/Root/Event', 1) WITH (
		[InfoSiteMatchId] [int]
		,[AdminSiteMatchId] [int]
		,[IsLive] BIT
		,[EventDateTime] [datetime]
		,[UpdatedTime] [datetime]
		,[LeagueName] [nvarchar](500)
		,[HomeName] [nvarchar](200)
		,[AwayName] [nvarchar](200)
		,[Round] [nvarchar](2000)
		,[TeamRound] [nvarchar](2000)
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
		,[MatchCode][nvarchar](50) 
		,[Provider][nvarchar](2000) 
		,[OtherProvider][nvarchar](2000) 
		,[Remark] NVARCHAR(2000)
		,[ProviderUsed][nvarchar](2000)
		,[ProviderTV][nvarchar](200)
		,[IsTest] BIT
		,[Remark2] [nvarchar](2000)
		,[HomeRemark] [nvarchar](2000)
		,[AwayRemark] [nvarchar](2000)
		,[TotalRound] [nvarchar](2000)
		,[IsLeagueBlackList] BIT
		,[IsHomeBlackList] BIT
		,[IsAwayBlackList] BIT
		,IsHomeBadRanking BIT
		,IsAwayBadRanking BIT
		,IsHomeDowngrade BIT
		,IsAwayDowngrade BIT
		,IsPostponed BIT
		,LastStatus NVARCHAR(20)
		,MatchStatus TINYINT
		,RoundConfirm VARCHAR(3)
		)

	EXEC sp_xml_removedocument @idoc

	-- remove data older than 1 month
	DECLARE @DeletedDate DATETIME= DATEADD(DAY, -31, CAST(GETDATE() AS DATE)); 
	DELETE #tblInfoSiteMatch 
	WHERE EventDateTime < @DeletedDate

	CREATE CLUSTERED INDEX IX_tbl#tblInfoSiteMatch_InfoSiteMatchId
	ON #tblInfoSiteMatch(InfoSiteMatchId ASC)

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
		,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR(2000))
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
				SELECT ',' + CAST(Id AS VARCHAR(100))
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
		,CAST(RTRIM(LTRIM(d.val)) AS NVARCHAR(2000))
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
				SELECT ',' + CAST(Id AS VARCHAR(100))
				FROM #tblDistinctTextList AS tl
				WHERE tl.InfoSiteMatchId = im.InfoSiteMatchId
				FOR XML PATH('')
				), 1, 1, '')
	FROM #tblInfoSiteMatch AS im

	-- Update
	UPDATE t
	SET t.[InfoSiteMatchId] = s.[InfoSiteMatchId], 
		t.[AdminSiteMatchId] = s.[AdminSiteMatchId], 
		t.[EventDateTime] = s.[EventDateTime], 
		t.[UpdatedTime] = s.[UpdatedTime], 
		t.[LeagueName] = s.[LeagueName], 
		t.[HomeName] = s.[HomeName], 
		t.[AwayName] = s.[AwayName], 
		t.[Round] = s.[Round], 
		t.[TeamRound] = s.[TeamRound],
		t.[Division] = s.[Division], 
		t.[Agent] = s.[Agent], 
		t.[Venue] = s.[Venue], 
		t.[TV] = s.[TV], 
		t.[Channel] = s.[Channel], 
		t.[WB] = s.[WB], 
		t.[Website1] = s.[Website1], 
		t.[Website2] = s.[Website2], 
		t.[Website3] = s.[Website3], 
		t.[Website4] = s.[Website4], 
		t.[OWPLeagueId] = s.[OWPLeagueId], 
		t.[OWPHomeId] = s.[OWPHomeId], 
		t.[OWPAwayId] = s.[OWPAwayId], 
		t.[TVIds] = s.[TVIds], 
		t.[AgentIds] = s.[AgentIds], 
		t.[IsDeleted] = 0, 
		t.[IsNeutral] = s.[IsNeutral], 
		t.[IPTV] = s.[IPTV], 
		t.[ETPK] = s.[ETPK], 
		t.[IsLive] = s.[IsLive], 
		t.[MatchCode] = s.[MatchCode], 
		t.[Provider] = s.[Provider],
		t.[OtherProvider] = s.[OtherProvider], 
		t.[Remark] = s.[Remark], 
		t.[ProviderUsed] = s.[ProviderUsed], 
		t.[ProviderTV] = s.[ProviderTV], 
		t.[IsTest] = s.[IsTest], 
		t.[Remark2] = s.[Remark2], 
		t.[HomeRemark] = s.[HomeRemark], 
		t.[AwayRemark] = s.[AwayRemark], 
		t.[TotalRound] = s.[TotalRound], 
		t.[IsLeagueBlackList] = s.[IsLeagueBlackList],
		t.[IsHomeBlackList] = s.[IsHomeBlackList],
		t.[IsAwayBlackList] = s.[IsAwayBlackList],
		t.MatchStatus = s.MatchStatus,
		t.IsHomeBadRanking = s.IsHomeBadRanking,
		t.IsAwayBadRanking = s.IsAwayBadRanking,
		t.IsHomeDowngrade = s.IsHomeDowngrade,
		t.IsAwayDowngrade = s.IsAwayDowngrade,
		t.IsPostponed = s.IsPostponed,
		t.LastStatus = s.LastStatus,
		t.RoundConfirm = s.RoundConfirm
	FROM dbo.InfoSiteMatch AS t WITH (ROWLOCK, UPDLOCK)
		 JOIN #tblInfoSiteMatch AS s ON t.[InfoSiteMatchId] = s.[InfoSiteMatchId];

	-- insert
	INSERT INTO dbo.InfoSiteMatch (
		[InfoSiteMatchId], 
		[AdminSiteMatchId], 
		[EventDateTime], 
		[UpdatedTime], 
		[LeagueName], 
		[HomeName], 
		[AwayName], 
		[Round], 
		[Division], 
		[Agent], 
		[Venue], 
		[TV], 
		[Channel], 
		[WB], 
		[Website1], 
		[Website2], 
		[Website3], 
		[Website4], 
		[OWPLeagueId], 
		[OWPHomeId], 
		[OWPAwayId], 
		[TVIds], 
		[AgentIds], 
		[IsDeleted], 
		[IsNeutral], 
		[IPTV], 
		[ETPK], 
		[IsLive], 
		[MatchCode], 
		[Provider], 
		[OtherProvider], 
		[Remark], 
		[ProviderUsed], 
		[ProviderTV], 
		[IsTest], 
		[Remark2], 
		[HomeRemark], 
		[AwayRemark], 
		[TotalRound], 
		[IsLeagueBlackList],
		[IsHomeBlackList],
		[IsAwayBlackList],
		IsHomeBadRanking,
		IsAwayBadRanking,
		IsHomeDowngrade,
		IsAwayDowngrade,
		IsPostponed,
		LastStatus,
		MatchStatus,
		RoundConfirm
	)
	SELECT s.[InfoSiteMatchId], 
		s.[AdminSiteMatchId], 
		s.[EventDateTime], 
		s.[UpdatedTime], 
		s.[LeagueName], 
		s.[HomeName], 
		s.[AwayName], 
		s.[Round], 
		s.[Division], 
		s.[Agent], 
		s.[Venue], 
		s.[TV], 
		s.[Channel], 
		s.[WB], 
		s.[Website1], 
		s.[Website2], 
		s.[Website3], 
		s.[Website4], 
		s.[OWPLeagueId], 
		s.[OWPHomeId], 
		s.[OWPAwayId], 
		s.[TVIds], 
		s.[AgentIds], 
		0, 
		s.[IsNeutral], 
		s.[IPTV], 
		s.[ETPK], 
		s.[IsLive], 
		s.[MatchCode], 
		s.[Provider], 
		s.[OtherProvider], 
		s.[Remark], 
		s.[ProviderUsed], 
		s.[ProviderTV], 
		s.[IsTest], 
		s.[Remark2], 
		s.[HomeRemark], 
		s.[AwayRemark], 
		s.[TotalRound], 
		s.[IsLeagueBlackList],
		s.[IsHomeBlackList],
		s.[IsAwayBlackList],
		s.IsHomeBadRanking,
		s.IsAwayBadRanking,
		s.IsHomeDowngrade,
		s.IsAwayDowngrade,
		s.IsPostponed,
		s.LastStatus,
		s.MatchStatus,
		s.RoundConfirm
	FROM #tblInfoSiteMatch AS s
		LEFT JOIN dbo.InfoSiteMatch AS t WITH (NOLOCK) ON s.[InfoSiteMatchId] = t.[InfoSiteMatchId]
	WHERE t.[InfoSiteMatchId] IS NULL;

    -- Drop table	
	DROP TABLE #tblInfoSiteMatch

	DROP TABLE #tblTextList

	DROP TABLE #tblDistinctTextList
END
