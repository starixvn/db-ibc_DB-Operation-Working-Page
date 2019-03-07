
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
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @NotificationSettingId INT = 5
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
		,@EditLeagueMessageTemplate NVARCHAR(1000)
		,@EditLeagueMessageTemplateId INT
		,@EditTeamMessageTemplate NVARCHAR(1000)
		,@EditTeamMessageTemplateId INT
		,@SessionId VARCHAR(50) = CAST(NEWID() AS VARCHAR(50))
		,@CreatedBy INT = 0
		,@Total INT
		,@Index INT
		,@LogId INT
		,@StartTime DATETIME = GETDATE()
		,@LastUploadTime DATETIME

	CREATE TABLE #tblRemoveSession (LogId INT NOT NULL)

	-- remove old data
	DELETE dbo.InfoSiteMatch WITH (ROWLOCK)
	WHERE EventDateTime < DATEADD(DAY, - 3, GETDATE())

	DELETE dbo.InfoSiteSyncLog WITH (ROWLOCK)
	OUTPUT deleted.LogId
	INTO #tblRemoveSession(LogId)
	WHERE StartTime < DATEADD(DAY, - 3, GETDATE())

	DELETE ld
	FROM dbo.InfoSiteSyncLogDetail AS ld WITH (ROWLOCK)
		INNER JOIN #tblRemoveSession AS s ON ld.LogId = s.LogId

	INSERT INTO dbo.InfoSiteSyncLog (StartTime)
	VALUES (@StartTime)

	SET @LogId = @@IDENTITY

	--matches need to be checked before sync
	CREATE TABLE #tblMatch (
		OWPMatchId INT NOT NULL
		,EventDate DATE NOT NULL
		,OWPLeagueId INT NOT NULL
		,OWPHomeId INT NOT NULL
		,OWPAwayId INT NOT NULL
		,IsSync BIT NOT NULL
		)

	CREATE TABLE #tblSimilarMatchInfo (
		EventDate DATE NOT NULL
		,OWPLeagueId INT NOT NULL
		,OWPHomeId INT NOT NULL
		,OWPAwayId INT NOT NULL
		)

	--temp list of matches planned to sync
	INSERT INTO #tblMatch (
		OWPMatchId
		,EventDate
		,OWPLeagueId
		,OWPHomeId
		,OWPAwayId
		,IsSync
		)
	SELECT m.OWPMatchId
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
		LEFT JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId

	SELECT @Index = 0
		,@Total = COUNT(1)
	FROM #tblMatch

	WHILE @Index < @Total
	BEGIN
		DELETE #tblSimilarMatchInfo

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
		HAVING COUNT(1) > 1

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
		WHERE m.IsSync = 1

		IF @@ROWCOUNT = 0
		BEGIN
			BREAK
		END

		SET @Index = @Index + 1
	END

	UPDATE dbo.InfoSiteSyncLog WITH (ROWLOCK)
	SET EndTime = GETDATE()
	WHERE LogId = @LogId

	SELECT @LastUploadTime = MAX(CreatedDate)
	FROM dbo.AssignmentUploadingLog WITH (NOLOCK)

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
			AND om.InfoSiteMatchId IS NOT NULL
	END

	--remove matches not to be synced
	DELETE #tblMatch
	WHERE IsSync = 0

	-- create temp table remove IsDeleted
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
		,[OWPLeagueId] [int] NOT NULL
		,[OWPHomeId] [int] NOT NULL
		,[OWPAwayId] [int] NOT NULL
		,[AgentIds] [varchar](200) NULL
		,[TVIds] [varchar](200) NULL
		,[IsDeleted] [bit] NULL
		)

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
	WHERE IsDeleted <> 1

	SELECT @EditLeagueMessageTemplateId = MsgTemplateId
		,@EditLeagueMessageTemplate = MsgTemplateContent
	FROM dbo.MessageTemplate WITH (NOLOCK)
	WHERE MsgTemplateCode = 'EditLeague'

	SELECT @EditTeamMessageTemplateId = MsgTemplateId
		,@EditTeamMessageTemplate = MsgTemplateContent
	FROM dbo.MessageTemplate WITH (NOLOCK)
	WHERE MsgTemplateCode = 'EditTeam'

	CREATE TABLE #tblMinorMatch (
		MinorMatchId INT NOT NULL
		,ParentMatchId INT NOT NULL
		,OWPLeagueName NVARCHAR(200)
		,OWPHomeName NVARCHAR(200)
		,OWPAwayName NVARCHAR(200)
		)

	CREATE TABLE #tblMessage (
		UserId INT NOT NULL
		,MessageContent NVARCHAR(MAX) NOT NULL
		,MessageTypeId INT NOT NULL
		,IsImportant BIT NOT NULL
		)

	CREATE TABLE #tblLeagueLog (
		OWPMatchId INT NOT NULL
		,NewOWPLeagueId INT NOT NULL
		,OldOWPLeagueId INT NOT NULL
		)

	CREATE TABLE #tblHomeTeamLog (
		OWPMatchId INT NOT NULL
		,OldOWPHomeId INT NOT NULL
		,OldOWPAwayId INT NOT NULL
		)

	CREATE TABLE #tblAwayTeamLog (
		OWPMatchId INT NOT NULL
		,OldOWPHomeId INT NOT NULL
		,OldOWPAwayId INT NOT NULL
		)

	CREATE TABLE #tblTeamLog (
		OWPMatchId INT NOT NULL
		,OldOWPHomeId INT NOT NULL
		,OldOWPAwayId INT NOT NULL
		)

	-- list of minor bettypes Corner & Booking but not 15 mins
	CREATE TABLE #tblCornerBookingBetTypes (MinorBetTypeId INT NOT NULL)

	INSERT INTO #tblCornerBookingBetTypes
	SELECT MinorBettypeId
	FROM dbo.MinorBettype WITH (NOLOCK)
	WHERE ParentBetTypeId IS NULL
		AND IsActive = 1
		AND MinorBettypeName NOT LIKE '%15 mins%'
		AND (
			MinorBettypeName LIKE '%corner%'
			OR MinorBettypeName LIKE '%booking%'
			)

	-- create table to contain matches in time range
	CREATE TABLE #tblMatchInTimeRange (OWPMatchId INT NOT NULL)

	-- sync League
	UPDATE om
	SET om.OWPLeagueId = tm.OWPLeagueId
	OUTPUT INSERTED.OWPMatchId
		,INSERTED.OWPLeagueId
		,DELETED.OWPLeagueId
	INTO #tblLeagueLog(OWPMatchId, NewOWPLeagueId, OldOWPLeagueId)
	FROM dbo.OWPMatch AS om WITH (ROWLOCK)
		INNER JOIN #tblMatch AS tm ON om.OWPMatchId = tm.OWPMatchId
	WHERE om.OWPLeagueId <> tm.OWPLeagueId

	-- sync Home
	UPDATE om
	SET om.OWPHomeId = tm.OWPHomeId
	OUTPUT INSERTED.OWPMatchId
		,DELETED.OWPHomeId
		,INSERTED.OWPAwayId
	INTO #tblHomeTeamLog(OWPMatchId, OldOWPHomeId, OldOWPAwayId)
	FROM dbo.OWPMatch AS om WITH (ROWLOCK)
		INNER JOIN #tblMatch AS tm ON om.OWPMatchId = tm.OWPMatchId
	WHERE om.OWPHomeId <> tm.OWPHomeId

	-- sync Away
	UPDATE om
	SET om.OWPAwayId = tm.OWPAwayId
	OUTPUT INSERTED.OWPMatchId
		,INSERTED.OWPHomeId
		,DELETED.OWPAwayId
	INTO #tblAwayTeamLog(OWPMatchId, OldOWPHomeId, OldOWPAwayId)
	FROM dbo.OWPMatch AS om WITH (ROWLOCK)
		INNER JOIN #tblMatch AS tm ON om.OWPMatchId = tm.OWPMatchId
	WHERE om.OWPAwayId <> tm.OWPAwayId

	-- insert data to table TeamLog
	INSERT #tblTeamLog (
		OWPMatchId
		,OldOWPHomeId
		,OldOWPAwayId
		)
	SELECT ISNULL(h.OWPMatchId, a.OWPMatchId)
		,ISNULL(h.OldOWPHomeId, a.OldOWPHomeId)
		,ISNULL(a.OldOWPAwayId, h.OldOWPAwayId)
	FROM #tblHomeTeamLog AS h
		FULL JOIN #tblAwayTeamLog AS a ON h.OWPMatchId = a.OWPMatchId

	-- sync TVIds
	MERGE INTO dbo.MatchInfo AS om
	USING (
		SELECT om.OWPMatchId
			,im.TVIds
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
			INNER JOIN #tblMatch AS m ON m.OWPMatchId = om.OWPMatchId
		) AS im ON om.OWPMatchId = im.OWPMatchId
	WHEN MATCHED
		AND om.TVCode <> im.TVIds THEN
			UPDATE
			SET om.TVCode = im.TVIds;

	-- sync Round, Division, Channel, WB, Website1, Website2, Website3, Website4
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
		) AS im ON mi.OWPMatchId = im.OWPMatchId
	WHEN MATCHED THEN
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
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

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
				AND 1 = (CASE 
					WHEN EXISTS (
							SELECT 1
							FROM #tblCornerBookingBetTypes
							WHERE MinorBettypeId = mm.MinorBettypeId
							) THEN CASE 
							WHEN om.EventDateTime >= @FromTimeSendMessageSpecialBettype
								AND om.EventDateTime <= @ToTimeSendMessageSpecialBettype THEN 1
							ELSE 0
							END
					ELSE CASE 
							WHEN om.EventDateTime >= @FromTimeSendMessage
								AND om.EventDateTime <= @ToTimeSendMessage THEN 1
							ELSE 0
							END END
					)
				)
			)

	-- message for team
	INSERT INTO #tblMessage (
		UserId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT ass.UserId
		,m.MessageContent
		,@EditTeamMessageTemplateId
		,1
	FROM (
		SELECT l.OWPMatchId
			,REPLACE(REPLACE(@EditTeamMessageTemplate, '<oldevent>', oh.OWPTeamName + ' vs ' + oa.OWPTeamName), '<newevent>', nh.OWPTeamName + ' vs ' + na.OWPTeamName) AS MessageContent
		FROM #tblTeamLog AS l
			INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
			INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
			INNER JOIN dbo.OWPTeam AS oh WITH (NOLOCK) ON oh.OWPTeamId = l.OldOWPHomeId
			INNER JOIN dbo.OWPTeam AS oa WITH (NOLOCK) ON oa.OWPTeamId = l.OldOWPAwayId
			INNER JOIN dbo.OWPTeam AS nh WITH (NOLOCK) ON nh.OWPTeamId = m.OWPHomeId
			INNER JOIN dbo.OWPTeam AS na WITH (NOLOCK) ON na.OWPTeamId = m.OWPAwayId
		) AS m
		INNER JOIN (
		SELECT DISTINCT ass.UserId
			,ass.OWPMatchId
		FROM dbo.Assignment AS ass WITH (NOLOCK)
			INNER JOIN #tblTeamLog AS l ON ass.OWPMatchId = l.OWPMatchId
			INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
		WHERE ass.UserId IS NOT NULL
		) AS ass ON m.OWPMatchId = ass.OWPMatchId

	-- message for league
	INSERT INTO #tblMessage (
		UserId
		,MessageContent
		,MessageTypeId
		,IsImportant
		)
	SELECT ass.UserId
		,m.MessageContent
		,@EditLeagueMessageTemplateId
		,1
	FROM (
		SELECT l.OWPMatchId
			,REPLACE(REPLACE(REPLACE(REPLACE(@EditLeagueMessageTemplate, '<home>', h.OWPTeamName), '<away>', a.OWPTeamName), '<oldvalue>', ol.OWPLeagueName), '<newvalue>', nl.OWPLeagueName) AS MessageContent
		FROM #tblLeagueLog AS l
			INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
			INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON l.OWPMatchId = m.OWPMatchId
			INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
			INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
			INNER JOIN dbo.OWPLeague AS nl WITH (NOLOCK) ON nl.OWPLeagueId = l.NewOWPLeagueId
			INNER JOIN dbo.OWPLeague AS ol WITH (NOLOCK) ON ol.OWPLeagueId = l.OldOWPLeagueId
		) AS m
		INNER JOIN (
		SELECT DISTINCT ass.UserId
			,ass.OWPMatchId
		FROM dbo.Assignment AS ass WITH (NOLOCK)
			INNER JOIN #tblLeagueLog AS l ON ass.OWPMatchId = l.OWPMatchId
			INNER JOIN #tblMatchInTimeRange AS mt ON l.OWPMatchId = mt.OWPMatchId
		WHERE ass.UserId IS NOT NULL
		) AS ass ON m.OWPMatchId = ass.OWPMatchId

	-- insert message
	MERGE dbo.[Message] WITH (ROWLOCK) AS ms
	USING (
		SELECT m.UserId
			,m.MessageContent
			,m.MessageTypeId
			,m.IsImportant
		FROM #tblMessage AS m
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = m.UserId
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotificationSettingId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = m.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		) AS msn ON 1 = 0
	WHEN NOT MATCHED THEN
			INSERT (
				MessageContent
				,CreatedBy
				,IsImportant
				,MessageType
				)
			VALUES (
				msn.MessageContent
				,@CreatedBy
				,msn.IsImportant
				,msn.MessageTypeId
				)
	OUTPUT inserted.MessageId
		,msn.UserId
		,@SessionId
	INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);

	IF (
			EXISTS (
				SELECT 1
				FROM #tblMessage
				)
			)
	BEGIN
		INSERT INTO dbo.NotificationQueue (SessionId)
		SELECT @SessionId
	END

	-- sync league name, home name & away name for minor matches
	DECLARE @HomeSingleTeamOU INT = - 92
		,@AwaySingleTeamOU INT = - 93
		,@HomeSingleTeamOUOfCorners INT = - 94
		,@AwaySingleTeamOUOfCorners INT = - 95
		,@HomePenShootOut INT = - 98
		,@AwayPenShootOut INT = - 99

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
				WHEN mm.MinorBettypeId IN (@AwaySingleTeamOU, @AwaySingleTeamOUOfCorners, @AwayPenShootOut) THEN a.OWPTeamName
				ELSE h.OWPTeamName
				END)
		,REPLACE(t.Away, '<name>', CASE 
				WHEN mm.MinorBettypeId IN (@HomeSingleTeamOU, @HomeSingleTeamOUOfCorners, @HomePenShootOut) THEN h.OWPTeamName
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
		INNER JOIN dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK) ON t.MinorBettypeId = mm.MinorBettypeId

	INSERT INTO dbo.OWPLeague (OWPLeagueName)
	SELECT DISTINCT mm.OWPLeagueName
	FROM #tblMinorMatch AS mm
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.OWPLeague AS l WITH (NOLOCK)
			WHERE l.OWPLeagueName = mm.OWPLeagueName
			)

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
			)

	UPDATE m
	SET m.OWPLeagueId = l.OWPLeagueId
		,m.OWPHomeId = h.OWPTeamId
		,m.OWPAwayId = a.OWPTeamId
	FROM dbo.OWPMatch AS m WITH (ROWLOCK)
		INNER JOIN #tblMinorMatch AS mm ON m.OWPMatchId = mm.MinorMatchId
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueName = mm.OWPLeagueName
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamName = mm.OWPHomeName
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamName = mm.OWPAwayName

	DROP TABLE #tblCornerBookingBetTypes

	DROP TABLE #tblInfoSiteMatch

	DROP TABLE #tblMessage

	DROP TABLE #tblLeagueLog

	DROP TABLE #tblHomeTeamLog

	DROP TABLE #tblAwayTeamLog

	DROP TABLE #tblTeamLog

	DROP TABLE #tblMatchInTimeRange

	DROP TABLE #tblMinorMatch

	DROP TABLE #tblRemoveSession

	DROP TABLE #tblMatch

	DROP TABLE #tblSimilarMatchInfo
END