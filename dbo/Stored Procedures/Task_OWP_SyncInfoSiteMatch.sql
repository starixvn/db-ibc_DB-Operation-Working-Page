
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
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Today DATE = CONVERT(DATE, GETDATE())
		,@NumberDayDeleteOldData INT = 1
		,@NotificationSettingId INT = 5
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
		,@SessionId VARCHAR(50)
		,@CreatedBy INT = 0

	-- remove old data
	DELETE dbo.InfoSiteMatch WITH (ROWLOCK)
	WHERE EventDateTime < DATEADD(DAY, - @NumberDayDeleteOldData, @Today)

	SET @SessionId = CAST(NEWID() AS VARCHAR(50))

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

	-- sync League
	MERGE INTO dbo.OWPMatch AS om
	USING (
		SELECT im.InfoSiteMatchId
			,im.OWPLeagueId
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
		) AS im ON om.InfoSiteMatchId = im.InfoSiteMatchId
	WHEN MATCHED
		AND om.OWPLeagueId <> im.OWPLeagueId THEN
			UPDATE
			SET om.OWPLeagueId = im.OWPLeagueId
	OUTPUT INSERTED.OWPMatchId
		,INSERTED.OWPLeagueId
		,DELETED.OWPLeagueId
	INTO #tblLeagueLog(OWPMatchId, NewOWPLeagueId, OldOWPLeagueId);

	-- sync Home
	MERGE INTO dbo.OWPMatch AS om
	USING (
		SELECT im.InfoSiteMatchId
			,im.OWPHomeId
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
		) AS im ON om.InfoSiteMatchId = im.InfoSiteMatchId
	WHEN MATCHED
		AND om.OWPHomeId <> im.OWPHomeId THEN
			UPDATE
			SET om.OWPHomeId = im.OWPHomeId
	OUTPUT INSERTED.OWPMatchId
		,DELETED.OWPHomeId
		,INSERTED.OWPAwayId
	INTO #tblHomeTeamLog(OWPMatchId, OldOWPHomeId, OldOWPAwayId);

	-- sync Away
	MERGE INTO dbo.OWPMatch AS om
	USING (
		SELECT im.InfoSiteMatchId
			,im.OWPAwayId
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
		) AS im ON om.InfoSiteMatchId = im.InfoSiteMatchId
	WHEN MATCHED
		AND om.OWPAwayId <> im.OWPAwayId THEN
			UPDATE
			SET om.OWPAwayId = im.OWPAwayId
	OUTPUT INSERTED.OWPMatchId
		,INSERTED.OWPHomeId
		,DELETED.OWPAwayId
	INTO #tblAwayTeamLog(OWPMatchId, OldOWPHomeId, OldOWPAwayId);

	-- insert data to table TeamLog
	INSERT #tblTeamLog (
		OWPMatchId
		,OldOWPHomeId
		,OldOWPAwayId
		)
	SELECT h.OWPMatchId
		,h.OldOWPHomeId
		,ISNULL(a.OldOWPAwayId, h.OldOWPAwayId)
	FROM #tblHomeTeamLog AS h
		LEFT JOIN #tblAwayTeamLog AS a ON h.OWPMatchId = a.OWPMatchId

	-- sync TVIds
	MERGE INTO dbo.MatchInfo AS om
	USING (
		SELECT om.OWPMatchId
			,im.TVIds
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
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
		,@CreatedBy
		,@SessionId
	INTO dbo.MessageUser([MessageId], [UserId], [CreatedBy], [SessionId]);

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
		,OWPLeagueName
		,OWPHomeName
		,OWPAwayName
		)
	SELECT mm.MinorMatchId
		,REPLACE(t.League, '<name>', l.OWPLeagueName)
		,REPLACE(t.Home, '<name>', CASE WHEN mm.MinorBettypeId IN (@AwaySingleTeamOU, @AwaySingleTeamOUOfCorners, @AwayPenShootOut) THEN a.OWPTeamName ELSE h.OWPTeamName END)
		,REPLACE(t.Away, '<name>', CASE WHEN mm.MinorBettypeId IN (@HomeSingleTeamOU, @HomeSingleTeamOUOfCorners, @HomePenShootOut) THEN h.OWPTeamName ELSE a.OWPTeamName END)
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
END