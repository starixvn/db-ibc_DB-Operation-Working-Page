USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[Task_OWP_SyncInfoSiteMatch]    Script Date: 04/27/2021 14:18:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Task_OWP_SyncInfoSiteMatch]
AS
/*    
 Created: 20181030@Leo.Vo
 Task : Sync InfoSite match
 DB: bodb_OWP    
    
 Revisions:
	20181030@Leo.Vo: Initial SP - [Redmine: #103598]
	20181129@Leo.Vo: Not sync Agent - [Redmine: #105574]
	20190104@Kane.Le: Not sync IsDeleted events - [Redmine: #107257]
	20190107@Leo.Vo: Notification - [Redmine: #107257]
	20190213@Kane.Le: remove createdDate vs CreatedBy table MessageUser - [Redmine: #108723]
	20190221@Leo.Vo: Fix to sync minor match - [Redmine: #109216]
	20190304@Leo.Vo: Message for watcher - [Redmine: #109560]
	20190403@Raymond.Le: Correct data type for columns - [Redmine: #111068]
	20190506@Leo.Vo: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
	20190705@Carlos.Nguyen: Sync info site - [Redmine: #116479]
	20190816@Leo.Vo: Update message content - [Feature: #117960]
	20190918@Kane.Le: Update AgentIds - [Redmine: #120415]
	20191014@Leo.Vo: Fix issue job failed - [Redmine: #121722]
	20191022@Leo.Vo: Change Provider, OtherProvider - [Feature: #122194]
	20191108@Leo.Vo: Sync venue - [Feature: #123167]
	20200713@Mira.Nguyen: Apply new time range - [Redmine: #137410]
	20200713@Jacob: ImportingMatchInNeutralStadium - [Redmine: #137417]
	20200728@carlos.Nguyen: Update data Streaming sync from InfoSite - [Redmine: #137755]
	20200819@Mira: Archive plan for OWP tables - [Redmine: #137757]	
	20200824@Jacob: Infosite-Link matches between two sites - [Redmine: #140195]   	
	20200813@Jacob: Prematch Assignment - [Redmine: #138643]
	20201106@Jacob: Increase casting size - [Redmine: #144570]
	20210113@carlos.nguyen: Sync AdminSiteID on Interval Process- [Redmine: #148606]
	20210128@carlos.nguyen: Display Match Code - [Redmine: #149347]
	20210427@carlos.nguyen: Match-code is not displayed - [Redmine: #154164]
	20220314@carlos.nguyen: Fail to update AdminSiteId - [Redmine: #169899]
	20230926@Mira: Correct with no lock - [Redmine: #193811]
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @AssigneeMatchInfoNotificationSettingId INT = 5
		,@WatcherMatchInfoNotificationSettingId INT = 9
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		-- send message by condition date
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@SessionId VARCHAR(50) = CAST(NEWID() AS VARCHAR(50))
		,@CreatedBy INT = 0
		,@Total INT
		,@Index INT
		,@LogId INT

	-- remove data older than 1 month
	DELETE dbo.InfoSiteMatch WITH (ROWLOCK)
	WHERE EventDateTime < DATEADD(DAY, - 31, GETDATE());

	DELETE ld
	FROM dbo.InfoSiteSyncLogDetail AS ld WITH (ROWLOCK)
	INNER JOIN dbo.InfoSiteSyncLog AS l WITH (NOLOCK) ON ld.LogId = l.LogId
	WHERE l.StartTime < DATEADD(DAY, - 3, GETDATE());
	
	DELETE dbo.InfoSiteSyncLog WITH (ROWLOCK)
	WHERE StartTime < DATEADD(DAY, - 3, GETDATE());

	INSERT INTO dbo.InfoSiteSyncLog (StartTime)
	VALUES (GETDATE());

	SET @LogId = SCOPE_IDENTITY();

	--matches need to be checked before sync (home team, away team, league name)
	CREATE TABLE #tblMatch (
		OWPMatchId INT NOT NULL
		,InfoSiteMatchId INT
		,EventDate DATE NOT NULL
		,OWPLeagueId INT NOT NULL
		,OWPHomeId INT NOT NULL
		,OWPAwayId INT NOT NULL
		,IsSync BIT NOT NULL
		,IsNeutral BIT NOT NULL
		,MatchId INT
		,MatchCode NVARCHAR(50)
		);

	CREATE TABLE #tblSimilarMatchInfo (
		EventDate DATE NOT NULL
		,OWPLeagueId INT NOT NULL
		,OWPHomeId INT NOT NULL
		,OWPAwayId INT NOT NULL
		,MatchCode NVARCHAR(50)
		);

	CREATE TABLE #tblAssignee (
		UserId INT NOT NULL
		,OWPMatchId INT NOT NULL
		);

	CREATE TABLE #tblUserInSectionOfAssignee (
		UserId INT NOT NULL
		,OWPMatchId INT NOT NULL
		);
		
	CREATE TABLE #tblOldMatchTelevision (
		OWPMatchId INT NOT NULL
		,TVId INT NOT NULL
		);
		
	CREATE TABLE #tblNewMatchTelevision (
		OWPMatchId INT NOT NULL
		,TVId INT NOT NULL
		);

	CREATE TABLE #tblOldMatchAgent (
		OWPMatchId INT NOT NULL
		,AgentId INT NOT NULL
		);
		
	CREATE TABLE #tblNewMatchAgent (
		OWPMatchId INT NOT NULL
		,AgentId INT NOT NULL
		);
		
	CREATE TABLE #tblMatchChangeLog (
		OWPMatchId INT NOT NULL
		)
		
	CREATE TABLE #tblMessageChangeLog (
		OWPMatchId INT
		,OldValue NVARCHAR(2000)
		,NewValue NVARCHAR(2000)
		,TemplateCode NVARCHAR(50)
	)

	--temp list of matches planned to sync
	INSERT INTO #tblMatch (
		OWPMatchId
		,InfoSiteMatchId
		,EventDate
		,OWPLeagueId
		,OWPHomeId
		,OWPAwayId
		,IsSync
		,IsNeutral
		,MatchId
		,MatchCode
		)
	SELECT m.OWPMatchId
		,m.InfoSiteMatchId
		,CAST(DATEADD(HOUR, - 8, m.EventDateTime) AS DATE) AS EventDate
		,ISNULL(im.OWPLeagueId, m.OWPLeagueId) AS OWPLeagueId
		,ISNULL(im.OWPHomeId, m.OWPHomeId) AS OWPHomeId
		,ISNULL(im.OWPAwayId, m.OWPAwayId) AS OWPAwayId
		,1
		,ISNULL(im.IsNeutral,0)
		,im.AdminSiteMatchId
		,im.MatchCode
	FROM (
		SELECT m.OWPMatchId
			,m.EventDateTime
			,m.OWPLeagueId
			,m.OWPHomeId
			,m.OWPAwayId
			,m.InfoSiteMatchId
		FROM dbo.OWPMatch AS m WITH (NOLOCK)
		WHERE m.EventDateTime >= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00')
			AND NOT EXISTS (
				SELECT 1
				FROM dbo.MinorMatch AS mm WITH (NOLOCK)
				WHERE m.OWPMatchId = mm.MinorMatchId
				)
		) AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	LEFT JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	WHERE im.IsDeleted IS NULL OR im.IsDeleted = 0

	SELECT @Index = 0
		,@Total = COUNT(1)
	FROM #tblMatch;

	WHILE @Index < @Total
	BEGIN
		DELETE #tblSimilarMatchInfo;

		INSERT INTO #tblSimilarMatchInfo (
			EventDate
			,OWPLeagueId
			,OWPHomeId
			,OWPAwayId
			,MatchCode
			)
		SELECT EventDate
			,OWPLeagueId
			,OWPHomeId
			,OWPAwayId
			,MatchCode
		FROM #tblMatch
		GROUP BY EventDate
			,OWPLeagueId
			,OWPHomeId
			,OWPAwayId
			,MatchCode
		HAVING COUNT(1) > 1;
		
		UPDATE m
		SET m.OWPLeagueId = om.OWPLeagueId
			,m.OWPHomeId = om.OWPHomeId
			,m.OWPAwayId = om.OWPAwayId
			,m.IsSync = 0
		FROM #tblMatch AS m
		INNER JOIN #tblSimilarMatchInfo AS mi ON m.EventDate = mi.EventDate
			AND m.OWPLeagueId = mi.OWPLeagueId
			AND m.OWPHomeId = mi.OWPHomeId
			AND m.OWPAwayId = mi.OWPAwayId
			AND m.MatchCode = mi.MatchCode
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = m.OWPMatchId
		WHERE m.IsSync = 1;

		IF @@ROWCOUNT = 0
		BEGIN
			BREAK;
		END;

		SET @Index = @Index + 1;
	END;

	UPDATE dbo.InfoSiteSyncLog WITH (ROWLOCK)
	SET EndTime = GETDATE()
	WHERE LogId = @LogId;

	-- check to write log for matched not to be synced
	IF NOT EXISTS (
			SELECT 1
			FROM dbo.InfoSiteSyncLog AS il WITH (NOLOCK)
			WHERE il.LogId = (
					SELECT MAX(d.LogId)
					FROM dbo.InfoSiteSyncLogDetail AS d WITH (NOLOCK)
					)
			)
	BEGIN
		INSERT INTO dbo.InfoSiteSyncLogDetail (
			LogId
			,OWPMatchId
			,InfoSiteMatchId
			)
		SELECT @LogId
			,m.OWPMatchId
			,om.InfoSiteMatchId
		FROM #tblMatch AS m
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.OWPMatchId = om.OWPMatchId
		WHERE m.IsSync = 0
			AND om.InfoSiteMatchId IS NOT NULL;
	END;

	DELETE #tblMatch
	WHERE IsSync = 0 OR InfoSiteMatchId IS NULL

	CREATE TABLE #tblMinorMatch (
		MinorMatchId INT NOT NULL
		,ParentMatchId INT NOT NULL
		,OWPLeagueName NVARCHAR(500)
		,OWPHomeName NVARCHAR(200)
		,OWPAwayName NVARCHAR(200)
		);

	CREATE TABLE #tblMessageTemplate (
		OWPMatchId INT NOT NULL
		,MessageContent NVARCHAR(MAX) NOT NULL
		,MessageTypeId INT NOT NULL
		);

	CREATE TABLE #tblMessage (
		OWPMatchId INT NOT NULL
		,MessageId INT NOT NULL
		,MessageTypeId INT NOT NULL
		);

	CREATE TABLE #tblEventLog (
		OWPMatchId INT NOT NULL
		,OldLeagueId INT NOT NULL
		,OldHomeId INT NOT NULL
		,OldAwayId INT NOT NULL
		,IsNeutral BIT NOT NULL
		,MatchId INT
		,MatchCode NVARCHAR(50)
		);

	CREATE TABLE #tblAssigneeReceiver (
		UserId INT NOT NULL
		,OWPMatchId INT NOT NULL
		);

	-- create table to contain matches in time range
	CREATE TABLE #tblMatchInTimeRange (
		OWPMatchId INT NOT NULL
	);


	-- sync Event
	UPDATE om
	SET om.OWPLeagueId = tm.OWPLeagueId
		,om.OWPHomeId = tm.OWPHomeId
		,om.OWPAwayId = tm.OWPAwayId
		,om.IsNeutral = tm.IsNeutral
		,om.MatchId=tm.MatchId
		,om.MatchCode= tm.MatchCode
	OUTPUT DELETED.OWPMatchId
		,DELETED.OWPLeagueId
		,DELETED.OWPHomeId
		,DELETED.OWPAwayId
		,DELETED.IsNeutral
		,DELETED.MatchId
		,DELETED.MatchCode
	INTO #tblEventLog(OWPMatchId, OldLeagueId, OldHomeId, OldAwayId, IsNeutral,MatchId, MatchCode)
	FROM dbo.OWPMatch AS om WITH (ROWLOCK)
	INNER JOIN #tblMatch AS tm ON om.OWPMatchId = tm.OWPMatchId
	WHERE om.OWPLeagueId <> tm.OWPLeagueId OR
	 om.OWPHomeId <> tm.OWPHomeId OR
	 om.OWPAwayId <> tm.OWPAwayId OR
	 om.IsNeutral <> tm.IsNeutral OR
	 ISNULL(om.MatchId, 0) <> ISNULL(tm.MatchId, 0) OR
	 ISNULL(om.MatchCode, '') <> ISNULL(tm.MatchCode, '')

	-- sync TVIds
	TRUNCATE TABLE #tblMatchChangeLog
	
	INSERT INTO #tblOldMatchTelevision (
		OWPMatchId
		,TVId
		)
	SELECT m.OWPMatchId
		,mtv.TVId
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchTelevision AS mtv WITH (NOLOCK) ON m.OWPMatchId = mtv.OWPMatchId

	INSERT INTO #tblNewMatchTelevision (
		OWPMatchId
		,TVId
		)
	SELECT m.OWPMatchId
		,f.Value
	FROM #tblMatch AS m
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	CROSS APPLY dbo.fnc_SplitString(im.TVIds, ',') AS f
	WHERE im.TVIds <> '';
	
	DELETE t
	OUTPUT deleted.OWPMatchId INTO #tblMatchChangeLog (OWPMatchId)
	FROM dbo.MatchTelevision AS t WITH (ROWLOCK)
	INNER JOIN #tblMatch AS m ON t.OWPMatchId = m.OWPMatchId
	WHERE NOT EXISTS (
			SELECT 1
			FROM #tblNewMatchTelevision AS s
			WHERE s.OWPMatchId = t.OWPMatchId
				AND s.TVId = t.TVId
			);
	
	INSERT INTO dbo.MatchTelevision (
		OWPMatchId
		,TVId
		)
	OUTPUT inserted.OWPMatchId INTO #tblMatchChangeLog (OWPMatchId)
	SELECT s.OWPMatchId
		,s.TVId
	FROM #tblNewMatchTelevision AS s
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.MatchTelevision AS t WITH (NOLOCK)
			WHERE s.OWPMatchId = t.OWPMatchId
				AND s.TVId = t.TVId
			);
	
	INSERT INTO #tblMessageChangeLog (
		OWPMatchId
		,OldValue
		,NewValue
		,TemplateCode
		)
	SELECT m.OWPMatchId
		,ISNULL(STUFF((
					SELECT ', ' + tv.TVCode
					FROM #tblOldMatchTelevision AS mtv
					INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON tv.TVId = mtv.TVId
					WHERE mtv.OWPMatchId = m.OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')
		,im.TV
		,'EditTV'
	FROM #tblMatch AS m
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	WHERE EXISTS (
		SELECT 1
		FROM #tblMatchChangeLog AS l
		WHERE l.OWPMatchId = m.OWPMatchId
	)
	
	-- sync AgentIds
	TRUNCATE TABLE #tblMatchChangeLog
	
	INSERT INTO #tblOldMatchAgent (
		OWPMatchId
		,AgentId
		)
	SELECT m.OWPMatchId
		,ma.AgentId
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchAgent AS ma WITH (NOLOCK) ON m.OWPMatchId = ma.OWPMatchId
	
	INSERT INTO #tblNewMatchAgent (
		OWPMatchId
		,AgentId
		)
	SELECT m.OWPMatchId
		,f.Value
	FROM #tblMatch AS m
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	CROSS APPLY dbo.fnc_SplitString(im.AgentIds, ',') AS f
	WHERE im.AgentIds <> '';
	
	DELETE t
	OUTPUT deleted.OWPMatchId INTO #tblMatchChangeLog (OWPMatchId)
	FROM dbo.MatchAgent AS t WITH (ROWLOCK)
	INNER JOIN #tblMatch AS m ON t.OWPMatchId = m.OWPMatchId
	WHERE NOT EXISTS (
			SELECT 1
			FROM #tblNewMatchAgent AS s
			WHERE s.OWPMatchId = t.OWPMatchId
				AND s.AgentId = t.AgentId
			);
			
	INSERT INTO dbo.MatchAgent (
		OWPMatchId
		,AgentId
		)
	OUTPUT inserted.OWPMatchId INTO #tblMatchChangeLog (OWPMatchId)
	SELECT s.OWPMatchId
		,s.AgentId
	FROM #tblNewMatchAgent AS s
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.MatchAgent AS t WITH (NOLOCK)
			WHERE s.OWPMatchId = t.OWPMatchId
				AND s.AgentId = t.AgentId
			);
	
	INSERT INTO #tblMessageChangeLog (
		OWPMatchId
		,OldValue
		,NewValue
		,TemplateCode
		)
	SELECT m.OWPMatchId
		,ISNULL(STUFF((
					SELECT ', ' + ag.AgentName
					FROM #tblOldMatchAgent AS a
					INNER JOIN dbo.Agent AS ag WITH (NOLOCK) ON ag.AgentId = a.AgentId
					WHERE a.OWPMatchId = m.OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')
		,im.Agent
		,'EditAgent'
	FROM #tblMatch AS m
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	WHERE EXISTS (
		SELECT 1
		FROM #tblMatchChangeLog AS l
		WHERE l.OWPMatchId = m.OWPMatchId
	)

	-- sync Round, Division, Channel, WB, Venue, Website1, Website2, Website3, Website4
	INSERT INTO #tblMessageChangeLog (
		OWPMatchId
		,OldValue
		,NewValue
		,TemplateCode
		)
		
	SELECT m.OWPMatchId
		,mi.[Round]
		,im.[Round]
		,'EditRound'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UNION ALL
	
	SELECT m.OWPMatchId
		,mi.Division
		,im.Division
		,'EditDivision'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UNION ALL
	
	SELECT m.OWPMatchId
		,mi.Channel
		,im.Channel
		,'EditChannel'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UNION ALL
	
	SELECT m.OWPMatchId
		,mi.IPTV
		,im.IPTV
		,'EditIPTV'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UNION ALL
	
	SELECT m.OWPMatchId
		,mi.Venue
		,im.Venue
		,'EditVenue'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UNION ALL
	
	SELECT m.OWPMatchId
		,mi.WB
		,im.WB
		,'EditWB'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UNION ALL
	
	SELECT m.OWPMatchId
		,mi.Website1
		,im.Website1
		,'EditWebsite1'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UNION ALL
	
	SELECT m.OWPMatchId
		,mi.Website2
		,im.Website2
		,'EditWebsite2'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UNION ALL
	
	SELECT m.OWPMatchId
		,mi.Website3
		,im.Website3
		,'EditWebsite3'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UNION ALL
	
	SELECT m.OWPMatchId
		,mi.Website4
		,im.Website4
		,'EditWebsite4'
	FROM #tblMatch AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	
	UPDATE mi
	SET mi.[Round] = im.[Round]
		,mi.Division = im.Division
		,mi.Channel = im.Channel
		,mi.IPTV = im.IPTV
		,mi.WB = im.WB
		,mi.Venue = im.Venue
		,mi.Website1 = im.Website1
		,mi.Website2 = im.Website2
		,mi.Website3 = im.Website3
		,mi.Website4 = im.Website4
		,mi.ETPK = im.ETPK
	FROM dbo.MatchInfo AS mi WITH (ROWLOCK)
	INNER JOIN #tblMatch AS m ON mi.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON im.InfoSiteMatchId = m.InfoSiteMatchId
	
	-- sync league name, home name & away name for minor matches
	DECLARE @HomeSingleTeamOU INT = - 92
		,@AwaySingleTeamOU INT = - 93
		,@HomeSingleTeamOUOfCorners INT = - 94
		,@AwaySingleTeamOUOfCorners INT = - 95
		,@HomePenShootOut INT = - 98
		,@AwayPenShootOut INT = - 99;

	INSERT INTO #tblMinorMatch (
		MinorMatchId
		,ParentMatchId
		,OWPLeagueName
		,OWPHomeName
		,OWPAwayName
		)
	SELECT mm.MinorMatchId
		,mm.ParentMatchId
		,REPLACE(t.League, '<name>', l.OWPLeagueName)
		,REPLACE(t.Home, '<name>', CASE 
				WHEN mm.MinorBettypeId IN (
						@AwaySingleTeamOU
						,@AwaySingleTeamOUOfCorners
						,@AwayPenShootOut
						)
					THEN a.OWPTeamName
				ELSE h.OWPTeamName
				END)
		,REPLACE(t.Away, '<name>', CASE 
				WHEN mm.MinorBettypeId IN (
						@HomeSingleTeamOU
						,@HomeSingleTeamOUOfCorners
						,@HomePenShootOut
						)
					THEN h.OWPTeamName
				ELSE a.OWPTeamName
				END)
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON mm.ParentMatchId = m.OWPMatchId
	INNER JOIN #tblEventLog AS changed ON mm.ParentMatchId = changed.OWPMatchId
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
	INNER JOIN dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK) ON t.MinorBettypeId = mm.MinorBettypeId;

	INSERT INTO dbo.OWPLeague (OWPLeagueName)
	SELECT DISTINCT mm.OWPLeagueName
	FROM #tblMinorMatch AS mm
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPLeague AS l WITH (NOLOCK)
			WHERE l.OWPLeagueName = mm.OWPLeagueName
			);

	INSERT INTO dbo.OWPTeam (OWPTeamName)
	SELECT mm.OWPTeamName
	FROM (
		SELECT mm.OWPHomeName AS OWPTeamName
		FROM #tblMinorMatch AS mm
		
		UNION
		
		SELECT mm.OWPAwayName AS OWPTeamName
		FROM #tblMinorMatch AS mm
		) AS mm
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPTeam AS t WITH (NOLOCK)
			WHERE t.OWPTeamName = mm.OWPTeamName
			);

	UPDATE m
	SET m.OWPLeagueId = l.OWPLeagueId
		,m.OWPHomeId = h.OWPTeamId
		,m.OWPAwayId = a.OWPTeamId
	FROM dbo.OWPMatch AS m WITH (ROWLOCK)
	INNER JOIN #tblMinorMatch AS mm ON m.OWPMatchId = mm.MinorMatchId
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueName = mm.OWPLeagueName
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamName = mm.OWPHomeName
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamName = mm.OWPAwayName;

	-- send message by condition date
	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
	FROM dbo.fnc_GetDateTimeForTraderViewTime();

	--Store list matches edited in Time Range
	INSERT INTO #tblMatchInTimeRange (OWPMatchId)
	SELECT m.OWPMatchId
	FROM #tblMatch AS m
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.OWPMatchId = om.OWPMatchId
	LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
	WHERE om.EventDateTime >= @FromTimeSendMessage
		AND om.EventDateTime <= @ToTimeSendMessage;

	-- message template
	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		)
	SELECT mt.OWPMatchId
		,REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(t.MsgTemplateContent ,'<User>', 'InfoSite')
							,'<Match.No>', CASE 
							WHEN ISNULL(m.MatchNo, '') = '' THEN ''
							ELSE '#' + m.MatchNo
							END)
						,'<League>', nl.OWPLeagueName)
					,'<Event>', nh.OWPTeamName + CASE WHEN m.IsNeutral = 1 THEN ' (N)' ELSE '' END + ' -vs- ' + na.OWPTeamName)
				,'<OldMatch.No>', CASE 
					WHEN ISNULL(m.MatchNo, '') = '' THEN ''
					ELSE '#' + m.MatchNo
					END)
			,'<OldLeague>', ol.OWPLeagueName)
		,'<OldEvent>', oh.OWPTeamName + CASE WHEN el.IsNeutral = 1 THEN ' (N)' ELSE '' END  + ' -vs- ' + oa.OWPTeamName)
		,t.MsgTemplateId
	FROM #tblMatchInTimeRange AS mt
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON mt.OWPMatchId = m.OWPMatchId
	INNER JOIN #tblEventLog AS el ON mt.OWPMatchId = el.OWPMatchId
	INNER JOIN dbo.OWPLeague AS ol WITH (NOLOCK) ON ol.OWPLeagueId = el.OldLeagueId
	INNER JOIN dbo.OWPLeague AS nl WITH (NOLOCK) ON m.OWPLeagueId = nl.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS oh WITH (NOLOCK) ON el.OldHomeId = oh.OWPTeamId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON m.OWPHomeId = nh.OWPTeamId
	INNER JOIN dbo.OWPTeam AS oa WITH (NOLOCK) ON el.OldAwayId = oa.OWPTeamId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON m.OWPAwayId = na.OWPTeamId
	CROSS APPLY dbo.MessageTemplate AS t WITH (NOLOCK)
	WHERE t.MsgTemplateCode = 'EditMatch'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		)
	SELECT mt.OWPMatchId
		,REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(t.MsgTemplateContent, '<User>', 'InfoSite')
						,'<Match.No>', CASE 
							WHEN ISNULL(m.MatchNo, '') = ''
								THEN ''
							ELSE '#' + m.MatchNo
							END)
					,'<League>', le.OWPLeagueName)
				,'<Event>', nh.OWPTeamName + CASE WHEN m.IsNeutral = 1 THEN ' (N)' ELSE '' END +' -vs- ' + na.OWPTeamName)
			,'<Old>', ml.OldValue)
		,'<New>', ml.NewValue)
		,t.MsgTemplateId
	FROM #tblMatchInTimeRange AS mt
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON m.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblMessageChangeLog AS ml ON m.OWPMatchId = ml.OWPMatchId
	INNER JOIN dbo.MessageTemplate AS t WITH (NOLOCK) ON ml.TemplateCode = t.MsgTemplateCode
	WHERE ml.NewValue <> ml.OldValue
	
	-- insert Message assignee
	MERGE dbo.[Message] WITH (ROWLOCK) AS ms
	USING #tblMessageTemplate AS m
		ON 1 = 0
	WHEN NOT MATCHED
		THEN
			INSERT (
				MessageContent
				,CreatedBy
				,IsImportant
				,MessageType
				,IsWatcher
				)
			VALUES (
				m.MessageContent
				,@CreatedBy
				,0
				,m.MessageTypeId
				,0
				)
	OUTPUT m.OWPMatchId
		,inserted.MessageId
		,inserted.MessageType
	INTO #tblMessage(OWPMatchId, [MessageId], MessageTypeId);

	INSERT INTO #tblAssignee (
		UserId
		,OWPMatchId
		)
	SELECT DISTINCT ass.UserId
		,m.ParentMatchId
	FROM (
		SELECT OWPMatchId
			,OWPMatchId AS ParentMatchId
		FROM #tblMatchInTimeRange
		
		UNION
		
		SELECT mm.MinorMatchId AS OWPMatchId
			,ParentMatchId
		FROM #tblMatchInTimeRange AS m
		INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON m.OWPMatchId = mm.ParentMatchId
		) AS m
	INNER JOIN dbo.Assignment AS ass WITH (NOLOCK) ON ass.OWPMatchId = m.OWPMatchId
	WHERE ass.UserId IS NOT NULL;

	-- insert MessageUser assignee
	MERGE dbo.MessageUser WITH (ROWLOCK) AS mu
	USING (
		SELECT m.MessageId
			,m.OWPMatchId
			,ass.UserId
		FROM #tblMessage AS m
		INNER JOIN #tblAssignee AS ass ON m.OWPMatchId = ass.OWPMatchId
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @AssigneeMatchInfoNotificationSettingId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = ass.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		) AS m
		ON 1 = 0
	WHEN NOT MATCHED
		THEN
			INSERT (
				MessageId
				,UserId
				,SessionId
				)
			VALUES (
				m.MessageId
				,m.UserId
				,@SessionId
				)
	OUTPUT m.UserId
		,m.OWPMatchId
	INTO #tblAssigneeReceiver(UserId, OWPMatchId);

	-- insert Message watcher
	DELETE #tblMessage;

	MERGE dbo.[Message] WITH (ROWLOCK) AS ms
	USING #tblMessageTemplate AS m
		ON 1 = 0
	WHEN NOT MATCHED
		THEN
			INSERT (
				MessageContent
				,CreatedBy
				,IsImportant
				,MessageType
				,IsWatcher
				)
			VALUES (
				m.MessageContent
				,@CreatedBy
				,0
				,m.MessageTypeId
				,1
				)
	OUTPUT m.OWPMatchId
		,inserted.MessageId
		,inserted.MessageType
	INTO #tblMessage(OWPMatchId, [MessageId], MessageTypeId);

	INSERT INTO #tblUserInSectionOfAssignee (
		UserId
		,OWPMatchId
		)
	SELECT u2.UserId
		,ass1.OWPMatchId
	FROM #tblAssignee AS ass1
	INNER JOIN dbo.[User] AS u1 WITH (NOLOCK) ON ass1.UserId = u1.UserId
	INNER JOIN dbo.[User] AS u2 WITH (NOLOCK) ON u1.SectionId = u2.SectionId
	WHERE NOT EXISTS (
			SELECT 1
			FROM #tblAssigneeReceiver AS ass2
			WHERE u2.UserId = ass2.UserId
				AND ass1.OWPMatchId = ass2.OWPMatchId
			);

	-- insert MessageUser watcher
	INSERT INTO dbo.MessageUser (
		MessageId
		,UserId
		,SessionId
		)
	SELECT m.MessageId
		,ns.UserId
		,@SessionId
	FROM #tblMessage AS m
	INNER JOIN #tblUserInSectionOfAssignee AS u ON m.OWPMatchId = u.OWPMatchId
	INNER JOIN dbo.fnc_GetWatcherToSendMessage(@WatcherMatchInfoNotificationSettingId) AS ns ON u.UserId = ns.UserId;

	IF EXISTS (
			SELECT 1
			FROM #tblMessage
			)
	BEGIN
		INSERT INTO dbo.NotificationQueue (SessionId)
		SELECT @SessionId;
	END;

	DROP TABLE #tblMessageTemplate;

	DROP TABLE #tblMessage;

	DROP TABLE #tblEventLog;

	DROP TABLE #tblMatchInTimeRange;

	DROP TABLE #tblMinorMatch;

	DROP TABLE #tblMatch;

	DROP TABLE #tblSimilarMatchInfo;

	DROP TABLE #tblOldMatchTelevision;
	
	DROP TABLE #tblNewMatchTelevision;

	DROP TABLE #tblOldMatchAgent
	
	DROP TABLE #tblNewMatchAgent

	DROP TABLE #tblAssignee;

	DROP TABLE #tblUserInSectionOfAssignee;

	DROP TABLE #tblAssigneeReceiver;
	
	DROP TABLE #tblMessageChangeLog
	
	DROP TABLE #tblMatchChangeLog
END;



