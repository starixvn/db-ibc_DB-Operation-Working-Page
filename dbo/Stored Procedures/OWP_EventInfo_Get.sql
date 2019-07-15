
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EventInfo_Get] @EventDate DATE
	,@HomeName NVARCHAR(500) = NULL
	,@AwayName NVARCHAR(500) = NULL
	,@WatchBet NVARCHAR(500) = NULL
	,@Phone NVARCHAR(200) = NULL
	,@Channel NVARCHAR(100) = NULL
	,@FilterFromTime TIME = NULL
	,@FilterToTime TIME = NULL
	,@FromMaxBet MONEY = NULL
	,@ToMaxBet MONEY = NULL
	,@FromSpread SMALLMONEY = NULL
	,@ToSpread SMALLMONEY = NULL
	,@LeagueIds NVARCHAR(MAX) = NULL
	,@AssigneeIds NVARCHAR(MAX) = NULL
	,@AgentIds NVARCHAR(MAX) = NULL
	,@OtherProviderIds NVARCHAR(MAX) = NULL
	,@ProviderIds NVARCHAR(MAX) = NULL
	,@TVIds NVARCHAR(MAX) = NULL
	,@MatchNumber NVARCHAR(50) = NULL
	,@Remark NVARCHAR(500) = NULL
	,@AssigneeLocation INT = - 1
	,@MatchStatusIds NVARCHAR(20) = NULL
	,@ShowAll BIT = 0
AS
/*
Created: 20170103@Tim.Trinh
Task : get event information
DB: bodb_OWP

Param's Explanation:

Revisions:
    20170424@Tim.Trinh: order match - main match should be above its minor matches
	20171027@Raymond.Le: redesign layout Event information
	20171207@Raymond.Le: Change query
	20180613@Jacob: Hotfix - Live Detail - Ignore representated
    20180614@Leo: Display Round/OutSide/Remark independent
    20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181026@Raymond.Le: Enhance performance page Live Game List - [Redmine: #103598]
	20181106@Raymond.Le: Remove paging in SP - [Redmine: #104291]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider, new structure of MatchOffer - [Redmine: #107257]
	20190116@Kane.Le: Get NoOfHDP Id - [Redmine: #107257]
	20190506@Leo.Vo: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
	20190510@Kane.Le: Change phone length 200 - [Redmine: #112918]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20190715@Carlos.Nguyen: Add maxbetCN88, spreadCN88 - [Readmine: #116798]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @FromTime DATETIME
		,@ToTime DATETIME
		,@FromTimeForSpecialBettype DATETIME
		,@ToTimeViewDetailForSpecialBettype DATETIME
		,@ToTimeForSpecialBettype DATETIME
		-----
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@NoOfCorners INT = - 3
		,@NextCorners INT = - 4
		,@LastCorners INT = - 90
		,@HomeSingleTeamCorners INT = - 94
		,@AwaySingleTeamCorners INT = - 95
		,@Specific15MinsTotalBooking INT = - 8
		,@TotalBooking INT = - 6
		,@NextBooking INT = - 7
		,@LastBooking INT = - 91
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@BettypeHandicap INT = 1
		,@BettypeLA INT = - 1002
		,@CurrentDateTime DATETIME = DATEADD(HOUR, 12, GETDATE()) --- notice 
		-- Match Status
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Inplay NVARCHAR(15) = 'In-play'
		,@str_Completed NVARCHAR(15) = 'Completed'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'
		----
		,@FilterFromDateTime DATETIME
		,@FilterToDateTime DATETIME

	SET @FilterFromDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
	SET @FilterToDateTime = DATEADD(DAY, (DATEDIFF(DAY, 0, @EventDate) + 1), '11:59:59')

	SELECT @FromTime = FromTime
		,@ToTime = ToTime
		,@FromTimeForSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeForSpecialBettype = ToTimeForSpecialBettype
		,@ToTimeViewDetailForSpecialBettype = ToTimeViewDetailForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	IF (@FilterToDateTime < @FromTime)
	BEGIN
		SET @ShowAll = 1
	END

	CREATE TABLE #tblNoOfHDPResource (
		Id INT NOT NULL
		,Value NVARCHAR(50) NOT NULL
		)

	INSERT INTO #tblNoOfHDPResource (
		Id
		,Value
		)
	SELECT ResourceId
		,Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'NoOfHDP'

	-----------------------------------
	CREATE TABLE #tblMatch (
		OWPMatchId INT
		,ParentMatchId INT
		,MinorBettypeId INT
		,IsMinorMatch BIT
		,IsAllowedToViewDetail BIT
		,EventDateTime DATETIME
		,EventDate DATE
		,KickOffTime TIME
		,LeagueId INT
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,MatchNo NVARCHAR(50)
		,OtherTime TIME
		,[Round] NVARCHAR(2000)
		,Division NVARCHAR(2000)
		,Remark NVARCHAR(2000)
		,Phone NVARCHAR(200)
		,WatchBet NVARCHAR(100)
		,Channel NVARCHAR(100)
		,MatchStatus NVARCHAR(15)
		,NoOfHDP NVARCHAR(20)
		,NoOfHDPId INT
		,IsSelected BIT
		,IsOneHourToKickOffTime BIT
		,IsFiltered BIT
		)

	CREATE TABLE #tblMatchFiltered (
		OWPMatchId INT
		,ParentMatchId INT
		,MinorBettypeId INT
		)

	CREATE TABLE #tblMatchSetting (
		OWPMatchId INT
		,LeagueId INT
		,BettypeId INT
		,MinorBettypeId INT
		,ParentMatchId INT
		,Maxbet MONEY
		,Spread SMALLMONEY
		,IsMatchSetting BIT
		,MaxbetCN88 MONEY
		,SpreadCN88 SMALLMONEY)

	CREATE TABLE #tblParentMatchSetting (
		OWPMatchId INT
		,LeagueId INT
		,BettypeId INT
		,Maxbet MONEY
		,Spread SMALLMONEY
		,IsMatchSetting BIT
		)

	CREATE TABLE #tblAssignment (
		OWPMatchId INT
		,ParentMatchId INT
		,BettypeId INT
		,MinorBettypeId INT
		,UserId INT
		,IsCurrentUser BIT
		,Username VARCHAR(30)
		,Nickname VARCHAR(30)
		,Skype VARCHAR(50)
		,Extension VARCHAR(30)
		,Phone VARCHAR(200)
		,AssignmentType SMALLINT
		,LocationCode VARCHAR(20)
		,AssignmentNote NVARCHAR(200)
		,AssignmentId INT
		)

	CREATE TABLE #tblLeague (LeagueId INT)

	CREATE TABLE #tblAssignee (UserId INT)

	CREATE TABLE #tblAgent (Id INT)

	CREATE TABLE #tblOtherProvider (Id INT)

	CREATE TABLE #tblProvider (Id INT)

	CREATE TABLE #tblTelevision (Id INT)

	CREATE TABLE #tblLocationCode (LCode VARCHAR(20))

	CREATE TABLE #tblMatchStatus (MatchStatus NVARCHAR(15))

	/***********************/
	-- Case user has permission Live Game List - Full
	IF (@ShowAll = 1)
	BEGIN
		--get all match in selected EventDate
		INSERT INTO #tblMatch (
			OWPMatchId
			,ParentMatchId
			,MinorBettypeId
			,IsMinorMatch
			,IsAllowedToViewDetail
			)
		SELECT om.OWPMatchId
			,ISNULL(mm.ParentMatchId, om.OWPMatchId)
			,mm.MinorBettypeId
			,CASE 
				WHEN mm.MinorBettypeId IS NULL THEN 0
				ELSE 1
				END
			,1
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = om.OWPMatchId
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
		WHERE om.EventDateTime BETWEEN @FilterFromDateTime
				AND @FilterToDateTime
			AND mi.IsSelected = 1
	END
	ELSE
	BEGIN
		INSERT INTO #tblMatch (
			OWPMatchId
			,ParentMatchId
			,MinorBettypeId
			,IsMinorMatch
			,IsAllowedToViewDetail
			) --get match can view Live Detail
		SELECT om.OWPMatchId
			,ISNULL(mm.ParentMatchId, om.OWPMatchId)
			,mm.MinorBettypeId
			,CASE 
				WHEN mm.MinorBettypeId IS NULL THEN 0
				ELSE 1
				END
			,1
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = om.OWPMatchId
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
		WHERE om.EventDateTime BETWEEN @FromTime
				AND @ToTime
			AND mi.IsSelected = 1
		
		UNION
		--get match can NOT view Live Detail
		SELECT DISTINCT om.OWPMatchId
			,mm.ParentMatchId
			,mm.MinorBettypeId
			,1
			,0
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
			INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
		WHERE mi.IsSelected = 1
			AND mm.MinorBettypeId IN (@NextCorners, @NoOfCorners, @LastCorners, @HomeSingleTeamCorners, @AwaySingleTeamCorners, @NextBooking, @TotalBooking, @LastBooking, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
			AND om.EventDateTime > @ToTimeViewDetailForSpecialBettype
			AND om.EventDateTime <= @ToTimeForSpecialBettype
	END

	-- get match setting
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,ParentMatchId
		,BettypeId
		,MinorBettypeId
		,Maxbet
		,Spread
		,IsMatchSetting
		,MaxbetCN88
		,SpreadCN88
		)
	SELECT DISTINCT tm.OWPMatchId
		,tm.ParentMatchId
		,ms.Bettype
		,tm.MinorBettypeId
		,ms.Maxbet
		,ms.Spread
		,1
		,ms.MaxbetCN88
		,ms.SpreadCN88
	FROM #tblMatch AS tm WITH (NOLOCK)
		INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON tm.OWPMatchId = ms.OWPMatchId
		AND (
			ms.Maxbet IS NOT NULL
			OR ms.Spread IS NOT NULL
			)

	
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,ParentMatchId
		,LeagueId
		,BettypeId
		,MinorBettypeId
		,IsMatchSetting
		)
	SELECT DISTINCT tm.OWPMatchId
		,tm.ParentMatchId
		,om.OWPLeagueId AS LeagueId
		,ls.Bettype
		,tm.MinorBettypeId
		,0
	FROM #tblMatch AS tm WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON tm.OWPMatchId = om.OWPMatchId
		INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON om.OWPLeagueId = ls.LeagueId
	WHERE tm.IsMinorMatch = 0
		AND NOT EXISTS (
			SELECT 1
			FROM #tblMatchSetting AS cms WITH (NOLOCK)
			WHERE cms.OWPMatchId = tm.OWPMatchId
				AND cms.BettypeId = ls.Bettype
			)

	UPDATE ms
	SET ms.MaxBet = dbo.OWP_MaxBetGet(ms.OWPMatchId, ms.LeagueId, ms.BettypeId)
		,ms.Spread = dbo.OWP_SpreadGet(ms.OWPMatchId, ms.LeagueId, ms.BettypeId)
	FROM #tblMatchSetting AS ms
	WHERE ms.IsMatchSetting = 0

	-- parent match setting
	INSERT INTO #tblParentMatchSetting (
		OWPMatchId
		,BettypeId
		,Maxbet
		,Spread
		,IsMatchSetting
		)
	SELECT DISTINCT ms.OWPMatchId
		,ms.Bettype
		,ms.Maxbet
		,ms.Spread
		,1
	FROM #tblMatch AS tm WITH (NOLOCK)
		INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON tm.ParentMatchId = ms.OWPMatchId
		AND (
			ms.Maxbet IS NOT NULL
			OR ms.Spread IS NOT NULL
			)
	WHERE tm.IsMinorMatch = 1

	INSERT INTO #tblParentMatchSetting (
		OWPMatchId
		,LeagueId
		,BettypeId
		,IsMatchSetting
		)
	SELECT DISTINCT parent.OWPMatchId
		,parent.OWPLeagueId
		,ls.Bettype
		,0
	FROM #tblMatch AS tm WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS parent WITH (NOLOCK) ON tm.ParentMatchId = parent.OWPMatchId
		INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON parent.OWPLeagueId = ls.LeagueId
	WHERE tm.IsMinorMatch = 1
		AND NOT EXISTS (
			SELECT 1
			FROM #tblParentMatchSetting AS pms WITH (NOLOCK)
			WHERE pms.OWPMatchId = parent.OWPMatchId
				AND pms.BettypeId = ls.Bettype
			)

	UPDATE ms
	SET ms.MaxBet = dbo.OWP_MaxBetGet(ms.OWPMatchId, ms.LeagueId, ms.BettypeId)
		,ms.Spread = dbo.OWP_SpreadGet(ms.OWPMatchId, ms.LeagueId, ms.BettypeId)
	FROM #tblParentMatchSetting AS ms
	WHERE ms.IsMatchSetting = 0

	-- minor setting
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,ParentMatchId
		,BettypeId
		,MinorBettypeId
		,Maxbet
		,Spread
		)
	SELECT tbl.OWPMatchId
		,tbl.ParentMatchId
		,tbl.InheritedBettypeId
		,tbl.MinorBettypeId
		,msdt.MaxBet
		,msdt.Spread
	FROM (
		SELECT tm.OWPMatchId
			,tm.ParentMatchId
			,tm.MinorBettypeId
			,mbt.ParentBettypeId
			,mbt.InheritedBettypeId
			,ms.Maxbet
		FROM #tblMatch AS tm WITH (NOLOCK)
			INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON tm.MinorBettypeId = mbt.ParentBettypeId
			INNER JOIN #tblParentMatchSetting AS ms WITH (NOLOCK) ON tm.ParentMatchId = ms.OWPMatchId
			AND ms.BettypeId = @BettypeHandicap
		WHERE tm.IsMinorMatch = 1
			AND mbt.InheritedBettypeId <> @BettypeLA
			AND NOT EXISTS (
				SELECT 1
				FROM #tblMatchSetting AS cms WITH (NOLOCK)
				WHERE cms.OWPMatchId = tm.OWPMatchId
					AND cms.BettypeId = mbt.InheritedBettypeId
				)
		) AS tbl
		INNER JOIN dbo.MinorSetting AS minors WITH (NOLOCK) ON tbl.Maxbet BETWEEN ISNULL(minors.FromMaxBet, 0)
			AND ISNULL(minors.ToMaxBet, 99999999999)
		INNER JOIN dbo.MinorSettingDetail AS msdt WITH (NOLOCK) ON minors.MinorSettingId = msdt.MinorSettingId
		AND msdt.MinorBettypeId = tbl.ParentBettypeId

	-- Return Assignment
	INSERT INTO #tblAssignment (
		OWPMatchId
		,ParentMatchId
		,BettypeId
		,MinorBettypeId
		,UserId
		,IsCurrentUser
		,Username
		,Nickname
		,Skype
		,Extension
		,Phone
		,LocationCode
		,AssignmentType
		,AssignmentNote
		,AssignmentId
		)
	SELECT OWPMatchId
		,ParentMatchId
		,BettypeId
		,MinorBettypeId
		,UserId
		,IsCurrentUser
		,Username
		,Nickname
		,Skype
		,Extension
		,Phone
		,LocationCode
		,AssignmentType
		,AssignmentNote
		,AssignmentId
	FROM (
		SELECT a.OWPMatchId
			,tm.ParentMatchId
			,a.Bettype AS BettypeId
			,tm.MinorBettypeId
			,a.UserId
			,0 AS IsCurrentUser
			,u.Username
			,u.Nickname
			,u.Skype
			,u.Extension
			,u.Phone
			,u.LocationCode
			,a.AssignmentType
			,a.AssignmentNote
			,a.AssignmentId
		FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
			INNER JOIN #tblMatch AS tm WITH (NOLOCK) ON a.OWPMatchId = tm.OWPMatchId
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
			LEFT JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON tm.MinorBettypeId = mbt.ParentBettypeId
			AND a.Bettype = mbt.InheritedBettypeId
		WHERE (
				tm.IsMinorMatch = 0
				OR (
					tm.IsMinorMatch = 1
					AND mbt.MinorBettypeId IS NOT NULL
					AND tm.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
					)
				)
		
		UNION
		SELECT a.OWPMatchId
			,tm.ParentMatchId
			,a.Bettype AS BettypeId
			,mbt.ParentBettypeId
			,a.UserId
			,0 AS IsCurrentUser
			,u.Username
			,u.Nickname
			,u.Skype
			,u.Extension
			,u.Phone
			,u.LocationCode
			,a.AssignmentType
			,a.AssignmentNote
			,a.AssignmentId
		FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
			INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
			INNER JOIN #tblMatch AS tm WITH (NOLOCK) ON minor.ParentMatchId = tm.OWPMatchId
			AND tm.IsMinorMatch = 0
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
			INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
			AND a.Bettype = mbt.InheritedBettypeId
			AND mbt.ParentBettypeId IN (@Specific10Mins, @Specific15Mins, @FastMarket, @AllInOne)
		WHERE a.Bettype IN (@BettypeHandicap, @BettypeLA)
		
		UNION
		SELECT a.OWPMatchId
			,tm.ParentMatchId
			,a.Bettype AS BettypeId
			,mbt.ParentBettypeId
			,a.UserId
			,0 AS IsCurrentUser
			,u.Username
			,u.Nickname
			,u.Skype
			,u.Extension
			,u.Phone
			,u.LocationCode
			,a.AssignmentType
			,a.AssignmentNote
			,a.AssignmentId
		FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
			INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
			INNER JOIN #tblMatch AS tm WITH (NOLOCK) ON minor.ParentMatchId = tm.ParentMatchId
			AND tm.IsMinorMatch = 1
			AND tm.MinorBettypeId IN (@NoOfCorners, @TotalBooking)
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
			INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
			AND a.Bettype = mbt.InheritedBettypeId
			AND mbt.ParentBettypeId IN (@Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
		WHERE a.Bettype IN (@BettypeHandicap, @BettypeLA)
		) AS am

	-- Update all match info 
	UPDATE tm
	SET tm.EventDate = om.EventDate
		,tm.EventDateTime = om.EventDateTime
		,tm.KickOffTime = om.KickOffTime
		,tm.LeagueId = ol.OWPLeagueId
		,tm.League = ol.OWPLeagueName
		,tm.Home = home.OWPTeamName
		,tm.Away = away.OWPTeamName
		,tm.MatchNo = om.MatchNo
		,tm.OtherTime = om.OtherTime
		,tm.NoOfHDP = ref.[Value]
		,tm.NoOfHDPId = mi.NoOfHDPId
		,tm.[Round] = mi.[Round]
		,tm.Division = mi.Division
		,tm.Remark = mi.Remark
		,tm.Phone = mi.Phone
		,tm.WatchBet = mi.WB
		,tm.Channel = mi.Channel
		,tm.IsOneHourToKickOffTime = (CASE 
			WHEN om.EventDateTime <= DATEADD(MINUTE, 60, @CurrentDateTime) THEN 1
			ELSE 0 END
			)
		,tm.[MatchStatus] = dbo.[OWP_GetCurrentMatchStatus](om.EventDate, om.KickOffTime, mi.MatchStatus)
		,tm.IsFiltered = 1
	FROM #tblMatch AS tm
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = tm.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = tm.OWPMatchId
		INNER JOIN dbo.OWPLeague AS ol WITH (NOLOCK) ON ol.OWPLeagueId = om.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = om.OWPHomeId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = om.OWPAwayId
		LEFT JOIN #tblNoOfHDPResource AS ref WITH (NOLOCK) ON mi.NoOfHDPId = ref.Id

	-- insert field filter to table
	IF @LeagueIds IS NOT NULL
	BEGIN
		INSERT INTO #tblLeague (LeagueId)
		SELECT league.OWPLeagueId
		FROM dbo.fnc_SplitStrings(@LeagueIds, ',') AS lid
			INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON league.OWPLeagueId = lid.[val]

		-- update status match not filtered
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblLeague AS l
				WHERE l.LeagueId = tm.LeagueId
				)
	END

	IF @AssigneeIds IS NOT NULL
	BEGIN
		INSERT INTO #tblAssignee (UserId)
		SELECT [val]
		FROM dbo.fnc_SplitStrings(@AssigneeIds, ',')

		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblAssignment AS am
					INNER JOIN #tblAssignee AS assignee ON am.UserId = assignee.UserId
				WHERE am.OWPMatchId = tm.OWPMatchId
				)
	END

	IF @AgentIds IS NOT NULL
	BEGIN
		INSERT INTO #tblAgent (Id)
		SELECT [val]
		FROM dbo.fnc_SplitStrings(@AgentIds, ',')

		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblAgent AS a
					INNER JOIN dbo.MatchAgent AS ma WITH (NOLOCK) ON a.Id = ma.AgentId
				WHERE ma.OWPMatchId = tm.OWPMatchId
				)
	END

	IF @OtherProviderIds IS NOT NULL
	BEGIN
		INSERT INTO #tblOtherProvider (Id)
		SELECT [val]
		FROM dbo.fnc_SplitStrings(@OtherProviderIds, ',')

		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblOtherProvider AS p
					INNER JOIN dbo.MatchOtherProvider AS mop WITH (NOLOCK) ON p.Id = mop.OtherProviderId
				WHERE ma.OWPMatchId = mop.OWPMatchId
				)
	END

	IF @ProviderIds IS NOT NULL
	BEGIN
		INSERT INTO #tblProvider (Id)
		SELECT [val]
		FROM dbo.fnc_SplitStrings(@ProviderIds, ',')

		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblProvider AS r
					INNER JOIN dbo.MatchProvider AS mp WITH (NOLOCK) ON r.Id = mp.ProviderId
				WHERE ma.OWPMatchId = mp.OWPMatchId
				)
	END

	IF @TVIds IS NOT NULL
	BEGIN
		INSERT INTO #tblTelevision (Id)
		SELECT [val]
		FROM dbo.fnc_SplitStrings(@TVIds, ',')

		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblTelevision AS t
					INNER JOIN dbo.MatchTelevision AS mt WITH (NOLOCK) ON t.Id = mt.TVId
				WHERE ma.OWPMatchId = t.OWPMatchId
				)
	END

	IF @AssigneeLocation > - 1
	BEGIN
		INSERT INTO #tblLocationCode (LCode)
		SELECT rr.Value
		FROM dbo.RefResource AS rr WITH (NOLOCK)
		WHERE rr.RefName = 'LocationCode'
			AND rr.ResourceId = @AssigneeLocation

		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblAssignment AS am
					INNER JOIN #tblLocationCode AS lo ON lo.LCode = am.LocationCode
				WHERE am.OWPMatchId = tm.OWPMatchId
				)
	END

	IF @MatchStatusIds IS NOT NULL
	BEGIN
		INSERT INTO #tblMatchStatus (MatchStatus)
		SELECT ref.Value
		FROM dbo.fnc_SplitStrings(@MatchStatusIds, ',') AS ms
			INNER JOIN dbo.RefResource AS ref WITH (NOLOCK) ON ref.ResourceId = ms.val
		WHERE ref.RefName = 'MatchStatus'

		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblMatchStatus AS ms
				WHERE ms.MatchStatus = tm.MatchStatus
				)
	END

	IF @HomeName IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND tm.Home NOT LIKE '%' + @HomeName + '%'
	END

	IF @AwayName IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND tm.Away NOT LIKE '%' + @AwayName + '%'
	END

	IF @WatchBet IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND ISNULL(tm.WatchBet, '') NOT LIKE '%' + @WatchBet + '%'
	END

	IF @Phone IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND ISNULL(tm.Phone, '') NOT LIKE '%' + @Phone + '%'
	END

	IF @Channel IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND ISNULL(tm.Channel, '') NOT LIKE '%' + @Channel + '%'
	END

	IF @FilterFromTime IS NOT NULL
		AND @FilterToTime IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND (
				(
					tm.EventDateTime < @FilterFromDateTime
					OR tm.EventDateTime > @FilterToDateTime
					)
				OR (
					tm.KickOffTime < @FilterFromTime
					OR tm.KickOffTime > @FilterToTime
					)
				)
	END

	IF @FromMaxBet IS NOT NULL
		AND @ToMaxBet IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblMatchSetting AS ms
				WHERE ms.OWPMatchId = tm.OWPMatchId
					AND ISNULL(ms.MaxBet, 0) BETWEEN @FromMaxBet
						AND @ToMaxBet
				)
	END

	IF @FromSpread IS NOT NULL
		AND @ToSpread IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #tblMatchSetting AS ms
				WHERE ms.OWPMatchId = tm.OWPMatchId
					AND ISNULL(ms.Spread, 0) BETWEEN @FromSpread
						AND @ToSpread
				)
	END

	IF @MatchNumber IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND tm.MatchNo NOT LIKE '%' + @MatchNumber + '%'
	END

	IF @Remark IS NOT NULL
	BEGIN
		UPDATE tm
		SET tm.IsFiltered = 0
		FROM #tblMatch AS tm
		WHERE tm.IsFiltered = 1
			AND ISNULL(tm.Remark, '') NOT LIKE '%' + @Remark + '%'
	END

	-- get Filtered match 
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT tm.OWPMatchId
		,tm.ParentMatchId
		,tm.MinorBettypeId
	FROM #tblMatch AS tm
	WHERE tm.IsFiltered = 1

	-- insert parent match If exist 10, 15 mins, FM, AIO
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT mf.ParentMatchId
		,mf.ParentMatchId
		,NULL
	FROM #tblMatchFiltered AS mf
	WHERE mf.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)
		AND NOT EXISTS (
			SELECT 1
			FROM #tblMatchFiltered AS mf
			WHERE mf.OWPMatchId = mf.ParentMatchId
			)

	-- insert child match of Minor Match
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT tm.OWPMatchId
		,tm.ParentMatchId
		,tm.MinorBettypeId
	FROM #tblMatchFiltered AS mf
		INNER JOIN #tblMatch AS tm ON tm.ParentMatchId = mf.OWPMatchId
		AND tm.IsMinorMatch = 1
	WHERE tm.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)
		AND NOT EXISTS (
			SELECT 1
			FROM #tblMatchFiltered
			WHERE OWPMatchId = tm.OWPMatchId
			)
	
	UNION
	SELECT minor1.OWPMatchId
		,minor1.ParentMatchId
		,minor1.MinorBettypeId
	FROM #tblMatchFiltered AS mf
		INNER JOIN #tblMatch AS minor ON minor.OWPMatchId = mf.OWPMatchId
		AND minor.IsMinorMatch = 1
		INNER JOIN #tblMatch AS minor1 ON minor.ParentMatchId = minor1.ParentMatchId
		AND minor1.IsMinorMatch = 1
	WHERE NOT EXISTS (
			SELECT 1
			FROM #tblMatchFiltered
			WHERE OWPMatchId = minor1.OWPMatchId
			)
		AND (
			(
				minor.MinorBettypeId = @NoOfCorners
				AND minor1.MinorBettypeId = @Specific15MinsNoOfCorners
				)
			OR (
				minor.MinorBettypeId = @Specific15MinsNoOfCorners
				AND minor1.MinorBettypeId = @NoOfCorners
				)
			OR (
				minor.MinorBettypeId IN (@TotalBooking)
				AND minor1.MinorBettypeId = @Specific15MinsTotalBooking
				)
			OR (
				minor.MinorBettypeId = @Specific15MinsTotalBooking
				AND minor1.MinorBettypeId = @TotalBooking
				)
			)

	-- Return Match Info
	SELECT mf.OWPMatchId
		,mf.ParentMatchId
		,tm.IsMinorMatch
		,tm.EventDate
		,tm.KickOffTime
		,tm.League
		,tm.Home
		,tm.Away
		,tm.MatchNo
		,tm.OtherTime
		,ref.[Value] AS NoOfHDP
		,tm.NoOfHDPId
		,tm.[Round]
		,tm.Division
		,tm.Remark
		,tm.Phone
		,tm.WatchBet
		,tm.Channel
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.OtherProviderName AS NVARCHAR(100)), '')
				FROM dbo.[OtherProvider] AS rs WITH (NOLOCK)
					INNER JOIN dbo.MatchOtherProvider AS mop WITH (NOLOCK) ON rs.OtherProviderId = mop.OtherProviderId
				WHERE mop.OWPMatchId = tm.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS [OtherProvider]
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.ProviderName AS NVARCHAR(100)), '')
				FROM dbo.[Provider] AS rs WITH (NOLOCK)
					INNER JOIN dbo.MatchProvider AS mp WITH (NOLOCK) ON rs.ProviderId = mp.ProviderId
				WHERE mp.OWPMatchId = tm.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS [Provider]
		,tm.IsOneHourToKickOffTime
		,tm.MatchStatus
		,tm.MinorBettypeId
		,tm.IsAllowedToViewDetail
	FROM #tblMatchFiltered AS mf
		INNER JOIN #tblMatch AS tm ON mf.OWPMatchId = tm.OWPMatchId
		LEFT JOIN #tblNoOfHDPResource AS ref ON ref.Id = tm.NoOfHDPId
	WHERE mf.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
		OR mf.MinorBettypeId IS NULL
	ORDER BY tm.EventDate
		,tm.KickOffTime
		,tm.MatchNo

	-- Return Assignment
	SELECT mf.OWPMatchId
		,mf.ParentMatchId
		,a.BettypeId
		,a.MinorBettypeId
		,a.UserId
		,a.IsCurrentUser
		,a.Username
		,a.Nickname
		,a.Skype
		,a.Extension
		,a.Phone
		,a.AssignmentType
		,a.AssignmentNote
	FROM #tblMatchFiltered AS mf
		INNER JOIN #tblAssignment AS a ON mf.OWPMatchId = a.OWPMatchId
	ORDER BY a.AssignmentId

	-- Return Match setting
	SELECT mf.OWPMatchId
		,mf.ParentMatchId
		,ms.BettypeId
		,ms.MinorBettypeId
		,ms.Maxbet
		,ms.Spread
		,ms.MaxbetCN88
		,ms.SpreadCN88
	FROM #tblMatchFiltered AS mf
		INNER JOIN #tblMatchSetting AS ms ON mf.OWPMatchId = ms.OWPMatchId

	-- Return Match Notes
	SELECT mn.OWPMatchId
		,mn.Note
	FROM #tblMatchFiltered AS mf
		INNER JOIN dbo.MatchNote AS mn WITH (NOLOCK) ON mf.OWPMatchId = mn.OWPMatchId
	WHERE mf.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
		OR mf.MinorBettypeId IS NULL
	ORDER BY mn.CreatedDate DESC

	-- Return TV 
	SELECT mf.OWPMatchId
		,tv.TVCode
		,tv.Color
	FROM #tblMatchFiltered AS mf
		INNER JOIN #tblMatch AS tm ON mf.OWPMatchId = tm.OWPMatchId
		INNER JOIN dbo.MatchTelevision AS mt WITH (NOLOCK) ON tm.OWPMatchId = mt.OWPMatchId
		INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON tv.TVId = mt.TVId
	ORDER BY tv.TVId

	-- Retunr Match Offer
	SELECT mf.OWPMatchId
		,rr.[Value] AS MatchOfferValue
	FROM #tblMatchFiltered AS mf WITH (NOLOCK)
		INNER JOIN dbo.MatchOfferDetail AS mo WITH (NOLOCK) ON mf.OWPMatchId = mo.OWPMatchId
		LEFT JOIN dbo.RefResource AS rr WITH (NOLOCK) ON mo.MatchOfferId = rr.ResourceId
	WHERE rr.RefName = 'MatchOffer'

	DROP TABLE #tblMatch

	DROP TABLE #tblMatchFiltered

	DROP TABLE #tblMatchSetting

	DROP TABLE #tblParentMatchSetting

	DROP TABLE #tblAssignment

	DROP TABLE #tblLeague

	DROP TABLE #tblAssignee

	DROP TABLE #tblAgent

	DROP TABLE #tblOtherProvider

	DROP TABLE #tblProvider

	DROP TABLE #tblTelevision

	DROP TABLE #tblLocationCode

	DROP TABLE #tblMatchStatus

	DROP TABLE #tblNoOfHDPResource
END