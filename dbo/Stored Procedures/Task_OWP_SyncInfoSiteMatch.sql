
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Task_OWP_SyncInfoSiteMatch]
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
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@SessionId VARCHAR(50) = CAST(NEWID() AS VARCHAR(50))
		,@CreatedBy INT = 0
		,@Total INT
		,@Index INT
		,@LogId INT
		,@StartTime DATETIME = GETDATE()
		,@LastUploadTime DATETIME;

	CREATE TABLE #tblRemoveSession (LogId INT NOT NULL);

	-- remove old data
	DELETE dbo.InfoSiteMatch
	WITH (ROWLOCK)
	WHERE EventDateTime < DATEADD(DAY, - 3, GETDATE());

	DELETE dbo.InfoSiteSyncLog
	WITH (ROWLOCK)
	OUTPUT deleted.LogId
	INTO #tblRemoveSession(LogId)
	WHERE StartTime < DATEADD(DAY, - 3, GETDATE());

	DELETE ld
	FROM dbo.InfoSiteSyncLogDetail AS ld WITH (ROWLOCK)
	INNER JOIN #tblRemoveSession AS s ON ld.LogId = s.LogId;

	INSERT INTO dbo.InfoSiteSyncLog (StartTime)
	VALUES (@StartTime);

	SET @LogId = @@IDENTITY;

	--matches need to be checked before sync (home team, away team, league name)
	CREATE TABLE #tblMatch (
		OWPMatchId INT NOT NULL
		,InfoSiteMatchId INT
		,EventDate DATE NOT NULL
		,OWPLeagueId INT NOT NULL
		,OWPHomeId INT NOT NULL
		,OWPAwayId INT NOT NULL
		,IsSync BIT NOT NULL
		);

	CREATE TABLE #tblSimilarMatchInfo (
		EventDate DATE NOT NULL
		,OWPLeagueId INT NOT NULL
		,OWPHomeId INT NOT NULL
		,OWPAwayId INT NOT NULL
		);

	CREATE TABLE #tblAssignee (
		UserId INT NOT NULL
		,OWPMatchId INT NOT NULL
		);

	CREATE TABLE #tblUserInSectionOfAssignee (
		UserId INT NOT NULL
		,OWPMatchId INT NOT NULL
		);

	CREATE TABLE #tblMatchTelevision (
		OWPMatchId INT NOT NULL
		,TVId INT NOT NULL
		);

	CREATE TABLE #tblMatchAgent (
		OWPMatchId INT NOT NULL
		,AgentId INT NOT NULL
		);

	--temp list of matches planned to sync
	INSERT INTO #tblMatch (
		OWPMatchId
		,InfoSiteMatchId
		,EventDate
		,OWPLeagueId
		,OWPHomeId
		,OWPAwayId
		,IsSync
		)
	SELECT m.OWPMatchId
		,m.InfoSiteMatchId
		,CAST(DATEADD(HOUR, - 8, m.EventDateTime) AS DATE) AS EventDate
		,ISNULL(im.OWPLeagueId, m.OWPLeagueId) AS OWPLeagueId
		,ISNULL(im.OWPHomeId, m.OWPHomeId) AS OWPHomeId
		,ISNULL(im.OWPAwayId, m.OWPAwayId) AS OWPAwayId
		,1
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
				FROM dbo.MinorMatch AS mm
				WHERE m.OWPMatchId = mm.MinorMatchId
				)
		) AS m
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	LEFT JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId;

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
			)
		SELECT EventDate
			,OWPLeagueId
			,OWPHomeId
			,OWPAwayId
		FROM #tblMatch
		GROUP BY EventDate
			,OWPLeagueId
			,OWPHomeId
			,OWPAwayId
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
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = m.OWPMatchId
		WHERE m.IsSync = 1;

		IF @@ROWCOUNT = 0
		BEGIN
			BREAK;
		END;

		SET @Index = @Index + 1;
	END;

	UPDATE dbo.InfoSiteSyncLog
	WITH (ROWLOCK)

	SET EndTime = GETDATE()
	WHERE LogId = @LogId;

	SELECT @LastUploadTime = MAX(CreatedDate)
	FROM dbo.AssignmentUploadingLog WITH (NOLOCK);

	-- check to write log for matched not to be synced
	IF NOT EXISTS (
			SELECT 1
			FROM dbo.InfoSiteSyncLog AS il WITH (NOLOCK)
			WHERE il.LogId = (
					SELECT MAX(d.LogId)
					FROM dbo.InfoSiteSyncLogDetail AS d WITH (NOLOCK)
					)
				AND il.StartTime >= @LastUploadTime
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
		INNER JOIN dbo.OWPMatch AS om ON m.OWPMatchId = om.OWPMatchId
		WHERE m.IsSync = 0
			AND om.InfoSiteMatchId IS NOT NULL;
	END;

	DELETE m
	FROM #tblMatch AS m
	WHERE m.IsSync = 0
		OR m.InfoSiteMatchId IS NULL;

	-- create temp table remove IsDeleted
	CREATE TABLE #tblInfoSiteMatch (
		[InfoSiteMatchId] [INT] NOT NULL
		,[EventDateTime] [DATETIME] NOT NULL
		,[UpdatedTime] [DATETIME] NOT NULL
		,[LeagueName] [NVARCHAR](500) NOT NULL
		,[HomeName] [NVARCHAR](200) NOT NULL
		,[AwayName] [NVARCHAR](200) NOT NULL
		,[Round] [NVARCHAR](2000) NULL
		,[Division] [NVARCHAR](2000) NULL
		,[Agent] [NVARCHAR](2000) NULL
		,[TV] [NVARCHAR](2000) NULL
		,[Channel] [NVARCHAR](100) NULL
		,[WB] [NVARCHAR](100) NULL
		,[Website1] [NVARCHAR](1000) NULL
		,[Website2] [NVARCHAR](1000) NULL
		,[Website3] [NVARCHAR](1000) NULL
		,[Website4] [NVARCHAR](1000) NULL
		,[OWPLeagueId] [INT] NOT NULL
		,[OWPHomeId] [INT] NOT NULL
		,[OWPAwayId] [INT] NOT NULL
		,[AgentIds] [VARCHAR](200) NULL
		,[TVIds] [VARCHAR](200) NULL
		,[IsDeleted] [BIT] NULL
		);

	INSERT INTO #tblInfoSiteMatch
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
		,[IsDeleted]
	FROM dbo.InfoSiteMatch WITH (NOLOCK)
	WHERE IsDeleted <> 1;

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
		,IsImportant BIT NOT NULL
		);

	CREATE TABLE #tblMessage (
		OWPMatchId INT NOT NULL
		,MessageId INT NOT NULL
		,MessageTypeId INT NOT NULL
		);

	CREATE TABLE #tblLeagueLog (
		OWPMatchId INT NOT NULL
		,NewOWPLeagueId INT NOT NULL
		,OldOWPLeagueId INT NOT NULL
		,OldOWPLeagueName NVARCHAR(500)
		);

	CREATE TABLE #tblHomeTeamLog (
		OWPMatchId INT NOT NULL
		,OldOWPHomeId INT NOT NULL
		,OldOWPAwayId INT NOT NULL
		);

	CREATE TABLE #tblAwayTeamLog (
		OWPMatchId INT NOT NULL
		,OldOWPHomeId INT NOT NULL
		,OldOWPAwayId INT NOT NULL
		);

	CREATE TABLE #tblTeamLog (
		OWPMatchId INT NOT NULL
		,OldOWPHomeId INT NOT NULL
		,OldOWPAwayId INT NOT NULL
		);

	CREATE TABLE #tblRound (
		OWPMatchId INT NOT NULL
		,OldRound NVARCHAR(2000)
		,NewRound NVARCHAR(2000)
		,OldDivision NVARCHAR(2000)
		,NewDivision NVARCHAR(2000)
		,OldChannel NVARCHAR(2000)
		,NewChannel NVARCHAR(2000)
		,OldWB NVARCHAR(2000)
		,NewWB NVARCHAR(2000)
		,OldWebsite1 NVARCHAR(2000)
		,NewWebsite1 NVARCHAR(1000)
		,OldWebsite2 NVARCHAR(1000)
		,NewWebsite2 NVARCHAR(1000)
		,OldWebsite3 NVARCHAR(1000)
		,NewWebsite3 NVARCHAR(1000)
		,OldWebsite4 NVARCHAR(1000)
		,NewWebsite4 NVARCHAR(1000)
		);

	CREATE TABLE #tblTv2ToSendMessage (
		OWPMatchId INT NOT NULL
		,OldTV NVARCHAR(2000)
		,NewTV NVARCHAR(2000)
		);

	CREATE TABLE #tblAgentToSendMessage (
		OWPMatchId INT NOT NULL
		,OldAgent NVARCHAR(2000)
		,NewAgent NVARCHAR(2000)
		);

	CREATE TABLE #tblAssigneeReceiver (
		UserId INT NOT NULL
		,OWPMatchId INT NOT NULL
		);

	-- list of minor bettypes Corner & Booking but not 15 mins
	CREATE TABLE #tblCornerBookingBetTypes (MinorBetTypeId INT NOT NULL);

	INSERT INTO #tblCornerBookingBetTypes
	SELECT MinorBettypeId
	FROM dbo.MinorBettype WITH (NOLOCK)
	WHERE ParentBetTypeId IS NULL
		AND IsActive = 1
		AND MinorBettypeName NOT LIKE '%15 mins%'
		AND (
			MinorBettypeName LIKE '%corner%'
			OR MinorBettypeName LIKE '%booking%'
			);

	-- create table to contain matches in time range
	CREATE TABLE #tblMatchInTimeRange (OWPMatchId INT NOT NULL);

	-- sync League
	UPDATE om
	SET om.OWPLeagueId = tm.OWPLeagueId
	OUTPUT INSERTED.OWPMatchId
		,INSERTED.OWPLeagueId
		,DELETED.OWPLeagueId
	INTO #tblLeagueLog(OWPMatchId, NewOWPLeagueId, OldOWPLeagueId)
	FROM dbo.OWPMatch AS om WITH (ROWLOCK)
	INNER JOIN #tblMatch AS tm ON om.OWPMatchId = tm.OWPMatchId
	WHERE om.OWPLeagueId <> tm.OWPLeagueId;

	UPDATE #tblLeagueLog
	SET OldOWPLeagueName = (
			SELECT OWPLeagueName
			FROM dbo.OWPLeague AS l WITH (NOLOCK)
			WHERE l.OWPLeagueId = #tblLeagueLog.OldOWPLeagueId
			)

	-- sync Home
	UPDATE om
	SET om.OWPHomeId = tm.OWPHomeId
	OUTPUT INSERTED.OWPMatchId
		,DELETED.OWPHomeId
		,INSERTED.OWPAwayId
	INTO #tblHomeTeamLog(OWPMatchId, OldOWPHomeId, OldOWPAwayId)
	FROM dbo.OWPMatch AS om WITH (ROWLOCK)
	INNER JOIN #tblMatch AS tm ON om.OWPMatchId = tm.OWPMatchId
	WHERE om.OWPHomeId <> tm.OWPHomeId;

	-- sync Away
	UPDATE om
	SET om.OWPAwayId = tm.OWPAwayId
	OUTPUT INSERTED.OWPMatchId
		,INSERTED.OWPHomeId
		,DELETED.OWPAwayId
	INTO #tblAwayTeamLog(OWPMatchId, OldOWPHomeId, OldOWPAwayId)
	FROM dbo.OWPMatch AS om WITH (ROWLOCK)
	INNER JOIN #tblMatch AS tm ON om.OWPMatchId = tm.OWPMatchId
	WHERE om.OWPAwayId <> tm.OWPAwayId;

	-- insert data to table TeamLog
	INSERT INTO #tblTeamLog (
		OWPMatchId
		,OldOWPHomeId
		,OldOWPAwayId
		)
	SELECT ISNULL(h.OWPMatchId, a.OWPMatchId)
		,ISNULL(h.OldOWPHomeId, a.OldOWPHomeId)
		,ISNULL(a.OldOWPAwayId, h.OldOWPAwayId)
	FROM #tblHomeTeamLog AS h
	FULL JOIN #tblAwayTeamLog AS a ON h.OWPMatchId = a.OWPMatchId;

	INSERT INTO #tblTv2ToSendMessage (
		OWPMatchId
		,OldTV
		,NewTV
		)
	SELECT m.OWPMatchId
		,ISNULL(STUFF((
					SELECT ', ' + CAST(tv.TVCode AS NVARCHAR)
					FROM dbo.MatchTelevision AS a WITH (NOLOCK)
					INNER JOIN #tblMatch AS m ON m.OWPMatchId = a.OWPMatchId
					INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON tv.TVId = a.TVId
					FOR XML PATH('')
					), 1, 2, ''), '') AS OldTV
		,im.TV
	FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
	INNER JOIN #tblMatch AS m ON m.OWPMatchId = om.OWPMatchId

	-- sync TVIds
	INSERT INTO #tblMatchTelevision (
		OWPMatchId
		,TVId
		)
	SELECT m.OWPMatchId
		,f.val
	FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
	INNER JOIN #tblMatch AS m ON m.OWPMatchId = om.OWPMatchId
	CROSS APPLY dbo.fnc_SplitStrings(im.TVIds, ',') AS f
	WHERE im.TVIds <> '';

	DELETE t
	FROM dbo.MatchTelevision AS t WITH (ROWLOCK)
	INNER JOIN #tblMatch AS m ON t.OWPMatchId = m.OWPMatchId
	WHERE NOT EXISTS (
			SELECT 1
			FROM #tblMatchTelevision AS s
			WHERE s.OWPMatchId = t.OWPMatchId
				AND s.TVId = t.TVId
			);

	INSERT INTO dbo.MatchTelevision (
		OWPMatchId
		,TVId
		)
	SELECT s.OWPMatchId
		,s.TVId
	FROM #tblMatchTelevision AS s
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.MatchTelevision AS t WITH (NOLOCK)
			WHERE s.OWPMatchId = t.OWPMatchId
				AND s.TVId = t.TVId
			);

	INSERT INTO #tblAgentToSendMessage (
		OWPMatchId
		,OldAgent
		,NewAgent
		)
	SELECT m.OWPMatchId
		,ISNULL(STUFF((
					SELECT ', ' + CAST(ag.AgentName AS NVARCHAR)
					FROM dbo.MatchAgent AS a WITH (NOLOCK)
					INNER JOIN #tblMatch AS m ON m.OWPMatchId = a.OWPMatchId
					INNER JOIN dbo.Agent AS ag WITH (NOLOCK) ON ag.AgentId = a.AgentId
					FOR XML PATH('')
					), 1, 2, ''), '') AS OldAgent
		,im.Agent
	FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
	INNER JOIN #tblMatch AS m ON m.OWPMatchId = om.OWPMatchId

	-- sync AgentIds
	INSERT INTO #tblMatchAgent (
		OWPMatchId
		,AgentId
		)
	SELECT m.OWPMatchId
		,f.val
	FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
	INNER JOIN #tblMatch AS m ON m.OWPMatchId = om.OWPMatchId
	CROSS APPLY dbo.fnc_SplitStrings(im.AgentIds, ',') AS f
	WHERE im.AgentIds <> '';

	DELETE t
	FROM dbo.MatchAgent AS t WITH (ROWLOCK)
	INNER JOIN #tblMatch AS m ON t.OWPMatchId = m.OWPMatchId
	WHERE NOT EXISTS (
			SELECT 1
			FROM #tblMatchAgent AS s
			WHERE s.OWPMatchId = t.OWPMatchId
				AND s.AgentId = t.AgentId
			);

	INSERT INTO dbo.MatchAgent (
		OWPMatchId
		,AgentId
		)
	SELECT s.OWPMatchId
		,s.AgentId
	FROM #tblMatchAgent AS s
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.MatchAgent AS t WITH (NOLOCK)
			WHERE s.OWPMatchId = t.OWPMatchId
				AND s.AgentId = t.AgentId
			);

	-- sync Round, Division, Channel, WB, Website1, Website2, Website3, Website4
	INSERT INTO #tblRound (
		OWPMatchId
		,OldRound
		,NewRound
		,OldDivision
		,NewDivision
		,OldChannel
		,NewChannel
		,OldWB
		,NewWB
		,OldWebsite1
		,NewWebsite1
		,OldWebsite2
		,NewWebsite2
		,OldWebsite3
		,NewWebsite3
		,OldWebsite4
		,NewWebsite4
		)
	SELECT om.OWPMatchId
		,oldm.[Round]
		,im.[Round]
		,oldm.Division
		,im.Division
		,oldm.Channel
		,im.Channel
		,oldm.WB
		,im.WB
		,oldm.Website1
		,im.Website1
		,oldm.Website2
		,im.Website2
		,oldm.Website3
		,im.Website3
		,oldm.Website4
		,im.Website4
	FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
	INNER JOIN dbo.MatchInfo AS oldm WITH (NOLOCK) ON om.OWPMatchId = oldm.OWPMatchId
	INNER JOIN #tblMatch AS m ON m.OWPMatchId = om.OWPMatchId

	MERGE INTO dbo.MatchInfo AS mi
	USING (
		SELECT om.OWPMatchId
			,im.[Round]
			,im.Division
			,im.Channel
			,im.WB
			,im.Website1
			,im.Website2
			,im.Website3
			,im.Website4
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
		INNER JOIN #tblMatch AS m ON m.OWPMatchId = om.OWPMatchId
		) AS im
		ON mi.OWPMatchId = im.OWPMatchId
	WHEN MATCHED
		THEN
			UPDATE
			SET mi.[Round] = im.[Round]
				,mi.Division = im.Division
				,mi.Channel = im.Channel
				,mi.WB = im.WB
				,mi.Website1 = im.Website1
				,mi.Website2 = im.Website2
				,mi.Website3 = im.Website3
				,mi.Website4 = im.Website4;

	-- send message by condition date
	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
		,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime();

	--Store list matches edited in Time Range
	INSERT INTO #tblMatchInTimeRange (OWPMatchId)
	SELECT l.OWPMatchId
	FROM (
		SELECT OWPMatchId
		FROM #tblLeagueLog
		
		UNION
		
		SELECT OWPMatchId
		FROM #tblTeamLog
		) AS l
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON l.OWPMatchId = om.OWPMatchId
	LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON l.OWPMatchId = mm.MinorMatchId
	WHERE (
			(
				mm.MinorBettypeId IS NULL
				AND om.EventDateTime >= @FromTimeSendMessage
				AND om.EventDateTime <= @ToTimeSendMessage
				)
			OR (
				mm.MinorBettypeId IS NOT NULL
				AND 1 = (
					CASE 
						WHEN EXISTS (
								SELECT 1
								FROM #tblCornerBookingBetTypes
								WHERE MinorBettypeId = mm.MinorBettypeId
								)
							THEN CASE 
									WHEN om.EventDateTime >= @FromTimeSendMessageSpecialBettype
										AND om.EventDateTime <= @ToTimeSendMessageSpecialBettype
										THEN 1
									ELSE 0
									END
						ELSE CASE 
								WHEN om.EventDateTime >= @FromTimeSendMessage
									AND om.EventDateTime <= @ToTimeSendMessage
									THEN 1
								ELSE 0
								END
						END
					)
				)
			);

	-- message template
	DECLARE @MessageTemplate NVARCHAR(1000)
		,@MessageTypeId INT

	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditMatch'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<OldMatch.No>', m.MatchNo), '<OldLeague>', ole.OldOWPLeagueName), '<OldEvent>', oh.OWPTeamName + ' -vs- ' + oa.OWPTeamName) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS oh WITH (NOLOCK) ON oh.OWPTeamId = l.OldOWPHomeId
	INNER JOIN dbo.OWPTeam AS oa WITH (NOLOCK) ON oa.OWPTeamId = l.OldOWPAwayId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblLeagueLog AS ole WITH (NOLOCK) ON ole.NewOWPLeagueId = m.OWPLeagueId

	-- TV
	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditTV'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldTV), '<New>', r.NewTV) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblTv2ToSendMessage AS r ON r.OWPMatchId = mt.OWPMatchId

	-- Agent
	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditAgent'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldAgent), '<New>', r.NewAgent) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblAgentToSendMessage AS r ON r.OWPMatchId = mt.OWPMatchId

	-- Round
	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditRound'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldRound), '<New>', r.NewRound) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblRound AS r ON r.OWPMatchId = mt.OWPMatchId

	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditDivision'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>',CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldDivision), '<New>', r.NewDivision) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblRound AS r ON r.OWPMatchId = mt.OWPMatchId

	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditChannel'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldChannel), '<New>', r.NewChannel) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblRound AS r ON r.OWPMatchId = mt.OWPMatchId

	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditWB'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldWB), '<New>', r.NewWB) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblRound AS r ON r.OWPMatchId = mt.OWPMatchId

	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditWebsite1'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldWebsite1), '<New>', r.NewWebsite1) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblRound AS r ON r.OWPMatchId = mt.OWPMatchId

	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditWebsite2'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldWebsite2), '<New>', r.NewWebsite2) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblRound AS r ON r.OWPMatchId = mt.OWPMatchId

	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditWebsite3'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldWebsite3), '<New>', r.NewWebsite3) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblRound AS r ON r.OWPMatchId = mt.OWPMatchId

	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageTypeId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditWebsite4'

	INSERT INTO #tblMessageTemplate (
		OWPMatchId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT l.OWPMatchId
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', 'InfoSite'), '<Match.No>', CASE 
								WHEN ISNULL(m.MatchNo, '') = ''
									THEN ''
								ELSE '#' + m.MatchNo
								END), '<League>', le.OWPLeagueName), '<Event>', na.OWPTeamName + ' -vs- ' + na.OWPTeamName), '<Old>', r.OldWebsite4), '<New>', r.NewWebsite4) AS MessageContent
		,@MessageTypeId
		,1
	FROM #tblTeamLog AS l
	INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.OWPLeague AS le WITH (NOLOCK) ON le.OWPLeagueId = m.OWPLeagueId
	INNER JOIN #tblRound AS r ON r.OWPMatchId = mt.OWPMatchId

	--INNER JOIN dbo.OWPLeague AS ol WITH(NOLOCK) ON ol.OWPLeagueId = l.OldOWPLeagueId;
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
				,m.IsImportant
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
	INNER JOIN (
		SELECT OWPMatchId
		FROM #tblLeagueLog
		
		UNION
		
		SELECT OWPMatchId
		FROM #tblTeamLog
		) AS changed ON mm.ParentMatchId = changed.OWPMatchId
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

	DROP TABLE #tblCornerBookingBetTypes;

	DROP TABLE #tblInfoSiteMatch;

	DROP TABLE #tblMessageTemplate;

	DROP TABLE #tblMessage;

	DROP TABLE #tblLeagueLog;

	DROP TABLE #tblHomeTeamLog;

	DROP TABLE #tblAwayTeamLog;

	DROP TABLE #tblTeamLog;

	DROP TABLE #tblMatchInTimeRange;

	DROP TABLE #tblMinorMatch;

	DROP TABLE #tblRemoveSession;

	DROP TABLE #tblMatch;

	DROP TABLE #tblSimilarMatchInfo;

	DROP TABLE #tblMatchTelevision;

	DROP TABLE #tblMatchAgent

	DROP TABLE #tblRound

	DROP TABLE #tblTv2ToSendMessage

	DROP TABLE #tblAgentToSendMessage

	DROP TABLE #tblAssignee;

	DROP TABLE #tblUserInSectionOfAssignee;

	DROP TABLE #tblAssigneeReceiver;
END;