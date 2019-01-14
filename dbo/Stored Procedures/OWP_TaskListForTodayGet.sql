/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_TaskListForTodayGet] @UserId INT,
	@IsGetYesterdayEvent BIT = 0
AS
/*
 Created: 20161101@Simon.Huynh
 Task : get task list for today
 DB: bodb_OWP

 Revisions:
    20170419@Tim.Trinh: modify trader view time
    20170814@Tim.Trinh: get more info
    20171011@Tim.Trinh: add @ShowAll
	20171213@Quinn.Vo: remove @ShowAll & enhance performance
	20180614@Leo: Display Round/OutSide/Remark independent
	20180723@Raymond.Le: Fix show matchStatus for minorBettype
	20180805@Raymond.Le: Modify follow new structure of event assignment, add params IsGetYesterdayEvent - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider, new structure of MatchOffer - [Redmine: #107257]
*/
BEGIN
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
		,@Today DATETIME = GETDATE()
		,@CurrentDateTime DATETIME = DATEADD(HOUR, 12, GETDATE())

	CREATE TABLE #tblMatchSetting (
		OWPMatchId INT
		,LeagueId INT
		,BettypeId INT
		,MinorBettypeId INT
		,ParentMatchId INT
		,Maxbet MONEY
		,Spread SMALLMONEY
		,IsMatchSetting BIT
		)

	CREATE TABLE #tblParentMatchSetting (
		OWPMatchId INT
		,LeagueId INT
		,BettypeId INT
		,Maxbet MONEY
		,Spread SMALLMONEY
		,IsMatchSetting BIT
		)

	CREATE TABLE #tblTodayMatch (
		OWPMatchId INT
		,ParentMatchId INT
		,MinorBettypeId INT
		,IsMinorMatch BIT
		,IsAllowedToViewDetail BIT
		)

	IF (@IsGetYesterdayEvent = 1)
	BEGIN
		SET @FromTime = DATEADD(DAY, DATEDIFF(DAY, 0, @Today) - 1, '12:00:00')
		SET @ToTime = DATEADD(DAY, DATEDIFF(DAY, - 1, @Today) - 1, '11:59:59')
		SET @FromTimeForSpecialBettype = @FromTime
		SET @ToTimeForSpecialBettype = @ToTime
		SET @ToTimeViewDetailForSpecialBettype = @ToTime
	END
	ELSE -- If not get yesterday event, set FromTime-ToTime in Time Range
	BEGIN
		SELECT @FromTime = FromTime
			,@ToTime = ToTime
			,@FromTimeForSpecialBettype = FromTimeForSpecialBettype
			,@ToTimeForSpecialBettype = ToTimeForSpecialBettype
			,@ToTimeViewDetailForSpecialBettype = ToTimeViewDetailForSpecialBettype
		FROM dbo.fnc_GetDateTimeForTraderViewTime()
	END

	-- get events can view detail
	INSERT INTO #tblTodayMatch (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		,IsMinorMatch
		,IsAllowedToViewDetail
		)
	SELECT DISTINCT om.OWPMatchId
		,om.OWPMatchId
		,NULL
		,0
		,1
	FROM dbo.Assignment AS ass WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON ass.OWPMatchId = om.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
	WHERE om.EventDateTime BETWEEN @FromTime
			AND @ToTime
		AND mi.IsSelected = 1
		AND ass.UserId = @UserId
		AND NOT EXISTS (
			SELECT 1
			FROM dbo.MinorMatch AS mm WITH (NOLOCK)
			WHERE om.OWPMatchId = mm.MinorMatchId
			)
	
	UNION
	SELECT DISTINCT minor.MinorMatchId
		,minor.ParentMatchId
		,minor.MinorBettypeId
		,1
		,1
	FROM dbo.Assignment AS ass WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON ass.OWPMatchId = om.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
		INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON ass.OWPMatchId = minor.MinorMatchId
		INNER JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON minor.MinorBettypeId = mib.MinorBettypeId
	WHERE om.EventDateTime BETWEEN @FromTime
			AND @ToTime
		AND mi.IsSelected = 1
		AND minor.IsRepresented = 1
		AND ass.UserId = @UserId

	-- get events can not view detail
	INSERT INTO #tblTodayMatch (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		,IsMinorMatch
		,IsAllowedToViewDetail
		)
	SELECT DISTINCT om.OWPMatchId
		,mm.ParentMatchId
		,mm.MinorBettypeId
		,1
		,0
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
		INNER JOIN dbo.Assignment AS ass WITH (NOLOCK) ON ass.OWPMatchId = om.OWPMatchId
	WHERE ass.UserId = @UserId
		AND mi.IsSelected = 1
		AND mm.MinorBettypeId IN (@NextCorners, @NoOfCorners, @LastCorners, @HomeSingleTeamCorners, @AwaySingleTeamCorners, @NextBooking, @TotalBooking, @LastBooking)
		AND om.EventDateTime > @ToTimeViewDetailForSpecialBettype
		AND om.EventDateTime <= @ToTimeForSpecialBettype
		AND NOT EXISTS (
			SELECT 1
			FROM #tblTodayMatch
			WHERE OWPMatchId = mm.MinorMatchId
			)

	-- insert parent Match of match 10, 15 mins
	INSERT INTO #tblTodayMatch (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		,IsMinorMatch
		,IsAllowedToViewDetail
		)
	SELECT DISTINCT mim.ParentMatchId AS OWPMatchId
		,mim.ParentMatchId
		,NULL
		,0
		,1 AS IsAllowedToViewDetail
	FROM dbo.MinorMatch AS mim WITH (NOLOCK)
		INNER JOIN #tblTodayMatch AS tod ON mim.MinorMatchId = tod.OWPMatchId
	WHERE mim.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)
		AND NOT EXISTS (
			SELECT 1
			FROM #tblTodayMatch
			WHERE OWPMatchId = mim.ParentMatchId
			)

	-- insert child Match of minor match
	INSERT INTO #tblTodayMatch (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		,IsMinorMatch
		,IsAllowedToViewDetail
		)
	SELECT om.OWPMatchId
		,parent.OWPMatchId
		,mm.MinorBettypeId
		,1
		,mnm.IsAllowedToViewDetail
	FROM (
		SELECT DISTINCT mim.MinorMatchId AS OWPMatchId
			,1 AS IsAllowedToViewDetail
		FROM dbo.MinorMatch AS mim WITH (NOLOCK)
			INNER JOIN #tblTodayMatch AS tod ON mim.ParentMatchId = tod.OWPMatchId
		WHERE mim.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)
			AND NOT EXISTS (
				SELECT 1
				FROM #tblTodayMatch
				WHERE OWPMatchId = mim.MinorMatchId
				)
		
		UNION
		SELECT DISTINCT mim1.MinorMatchId AS OWPMatchId
			,tod.IsAllowedToViewDetail
		FROM dbo.MinorMatch AS mim WITH (NOLOCK)
			INNER JOIN #tblTodayMatch AS tod ON mim.MinorMatchId = tod.OWPMatchId
			INNER JOIN dbo.MinorMatch AS mim1 WITH (NOLOCK) ON mim1.ParentMatchId = mim.ParentMatchId
		WHERE NOT EXISTS (
				SELECT 1
				FROM #tblTodayMatch
				WHERE OWPMatchId = mim1.MinorMatchId
				)
			AND (
				(
					mim.MinorBettypeId = @NoOfCorners
					AND mim1.MinorBettypeId = @Specific15MinsNoOfCorners
					)
				OR (
					mim.MinorBettypeId = @Specific15MinsNoOfCorners
					AND mim1.MinorBettypeId = @NoOfCorners
					)
				OR (
					mim.MinorBettypeId IN (@TotalBooking)
					AND mim1.MinorBettypeId = @Specific15MinsTotalBooking
					)
				OR (
					mim.MinorBettypeId = @Specific15MinsTotalBooking
					AND mim1.MinorBettypeId = @TotalBooking
					)
				)
		) AS mnm
		INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mnm.OWPMatchId = mm.MinorMatchId
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
		INNER JOIN dbo.OWPMatch AS parent WITH (NOLOCK) ON mm.ParentMatchId = parent.OWPMatchId

	-- get match setting
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,ParentMatchId
		,BettypeId
		,MinorBettypeId
		,Maxbet
		,Spread
		,IsMatchSetting
		)
	SELECT DISTINCT ml.OWPMatchId
		,ml.ParentMatchId
		,ms.Bettype
		,ml.MinorBettypeId
		,ms.Maxbet
		,ms.Spread
		,1
	FROM #tblTodayMatch AS ml WITH (NOLOCK)
		INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON ml.OWPMatchId = ms.OWPMatchId
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
	SELECT DISTINCT ml.OWPMatchId
		,ml.ParentMatchId
		,om.OWPLeagueId AS LeagueId
		,ls.Bettype
		,ml.MinorBettypeId
		,0
	FROM #tblTodayMatch AS ml WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON ml.OWPMatchId = om.OWPMatchId
		INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON om.OWPLeagueId = ls.LeagueId
	WHERE ml.IsMinorMatch = 0
		AND NOT EXISTS (
			SELECT 1
			FROM #tblMatchSetting AS cms WITH (NOLOCK)
			WHERE cms.OWPMatchId = ml.OWPMatchId
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
	FROM #tblTodayMatch AS ml WITH (NOLOCK)
		INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON ml.ParentMatchId = ms.OWPMatchId
		AND (
			ms.Maxbet IS NOT NULL
			OR ms.Spread IS NOT NULL
			)
	WHERE ml.IsMinorMatch = 1

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
	FROM #tblTodayMatch AS ml WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS parent WITH (NOLOCK) ON ml.ParentMatchId = parent.OWPMatchId
		INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON parent.OWPLeagueId = ls.LeagueId
	WHERE ml.IsMinorMatch = 1
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
		SELECT ml.OWPMatchId
			,ml.ParentMatchId
			,ml.MinorBettypeId
			,mbt.ParentBettypeId
			,mbt.InheritedBettypeId
			,ms.Maxbet
		FROM #tblTodayMatch AS ml WITH (NOLOCK)
			INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON ml.MinorBettypeId = mbt.ParentBettypeId
			INNER JOIN #tblParentMatchSetting AS ms WITH (NOLOCK) ON ml.ParentMatchId = ms.OWPMatchId
			AND ms.BettypeId = @BettypeHandicap
		WHERE ml.IsMinorMatch = 1
			AND mbt.InheritedBettypeId <> @BettypeLA
			AND NOT EXISTS (
				SELECT 1
				FROM #tblMatchSetting AS cms WITH (NOLOCK)
				WHERE cms.OWPMatchId = ml.OWPMatchId
					AND cms.BettypeId = mbt.InheritedBettypeId
				)
		) AS tbl
		INNER JOIN dbo.MinorSetting AS minors WITH (NOLOCK) ON tbl.Maxbet BETWEEN ISNULL(minors.FromMaxBet, 0)
			AND ISNULL(minors.ToMaxBet, 99999999999)
		INNER JOIN dbo.MinorSettingDetail AS msdt WITH (NOLOCK) ON minors.MinorSettingId = msdt.MinorSettingId
		AND msdt.MinorBettypeId = tbl.ParentBettypeId

	-- Return Match Info
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,om.EventDate
		,om.KickOffTime
		,league.OWPLeagueName AS League
		,home.OWPTeamName AS Home
		,away.OWPTeamName AS Away
		,om.MatchNo
		,om.OtherTime
		,inf.NoOfHDP
		,inf.[Round]
		,inf.Division
		,inf.Remark
		,inf.Phone
		,inf.WB AS WatchBet
		,inf.Channel
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.OtherProviderName AS VARCHAR), '')
				FROM dbo.[OtherProvider] rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(inf.[OtherProvider], ',') f
				WHERE f.val = rs.OtherProviderId
				FOR XML PATH('')
				), 1, 2, '') AS OtherProvider
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.[ProviderName] AS VARCHAR), '')
				FROM dbo.[Provider] rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(inf.[Provider], ',') f
				WHERE f.val = rs.[ProviderId]
				FOR XML PATH('')
				), 1, 2, '') AS [Provider]
		,(CASE 
			WHEN DATEDIFF(MINUTE, @CurrentDateTime, om.EventDateTime) <= 60 THEN 1
			WHEN @IsGetYesterdayEvent = 1 THEN 1
			ELSE 0 END
			) AS IsOneHourToKickOffTime
		,[dbo].[OWP_GetCurrentMatchStatus](om.EventDate, om.KickOffTime, inf.MatchStatus) AS MatchStatus
		,m.MinorBettypeId
		,m.IsAllowedToViewDetail
		,(CASE 
			WHEN om.EventDateTime BETWEEN DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00')
					AND DATEADD(DAY, DATEDIFF(DAY, - 1, @Today), '11:59:59') THEN 1
			ELSE 0 END
			) AS IsTodayEvent
	FROM #tblTodayMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.OWPMatchId = om.OWPMatchId
		INNER JOIN dbo.OWPMatch AS pa WITH (NOLOCK) ON m.ParentMatchId = pa.OWPMatchId
		INNER JOIN dbo.MatchInfo AS inf WITH (NOLOCK) ON m.OWPMatchId = inf.OWPMatchId
		INNER JOIN dbo.MatchInfo AS painf WITH (NOLOCK) ON m.ParentMatchId = painf.OWPMatchId
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
	WHERE m.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
		OR m.MinorBettypeId IS NULL
	ORDER BY om.EventDate
		,om.KickOffTime
		,CASE 
			WHEN ISNULL(om.MatchNo, '') = '' THEN 1
			ELSE 0
			END
		,om.MatchNo

	-- Return Assignment
	SELECT OWPMatchId
		,ParentMatchId
		,BettypeId
		,MinorBettypeId
		,UserId
		,IsCurrentUser
		,Username
		,Skype
		,Extension
		,Phone
		,AssignmentType
		,AssignmentNote
		,IsCancelled
	FROM (
		SELECT a.OWPMatchId
			,ml.ParentMatchId
			,a.Bettype AS BettypeId
			,ml.MinorBettypeId
			,a.UserId
			,(CASE 
				WHEN a.UserId = @UserId THEN 1
				ELSE 0 END
				) AS IsCurrentUser
			,(CASE 
				WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
				ELSE u.Username END
				) AS Username
			,u.Skype
			,u.Extension
			,u.Phone
			,a.AssignmentType
			,a.AssignmentNote
			,a.AssignmentId
			,(CASE 
				WHEN btc.OWPMatchId IS NULL THEN 0
				ELSE 1 END
				) IsCancelled
		FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
			INNER JOIN #tblTodayMatch AS ml WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
			LEFT JOIN dbo.MatchBetypeCancel AS btc WITH (NOLOCK) ON btc.OWPMatchId = ml.OWPMatchId
			AND btc.BetType = a.Bettype
			LEFT JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON ml.MinorBettypeId = mbt.ParentBettypeId
			AND a.Bettype = mbt.InheritedBettypeId
		WHERE (
				ml.IsMinorMatch = 0
				OR (
					ml.IsMinorMatch = 1
					AND mbt.MinorBettypeId IS NOT NULL
					AND ml.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
					)
				)
		
		UNION
		SELECT a.OWPMatchId
			,ml.ParentMatchId
			,a.Bettype AS BettypeId
			,mbt.ParentBettypeId
			,a.UserId
			,(CASE 
				WHEN a.UserId = @UserId THEN 1
				ELSE 0 END
				) AS IsCurrentUser
			,(CASE 
				WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
				ELSE u.Username END
				) AS Username
			,u.Skype
			,u.Extension
			,u.Phone
			,a.AssignmentType
			,a.AssignmentNote
			,a.AssignmentId
			,(CASE 
				WHEN btc.OWPMatchId IS NULL THEN 0
				ELSE 1 END
				) IsCancelled
		FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
			INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
			INNER JOIN #tblTodayMatch AS ml WITH (NOLOCK) ON minor.ParentMatchId = ml.OWPMatchId
			AND ml.IsMinorMatch = 0
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
			INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
			AND a.Bettype = mbt.InheritedBettypeId
			AND mbt.ParentBettypeId IN (@Specific10Mins, @Specific15Mins, @FastMarket, @AllInOne)
			LEFT JOIN dbo.MatchBetypeCancel AS btc WITH (NOLOCK) ON btc.OWPMatchId = minor.MinorMatchId
			AND btc.BetType = a.Bettype
		WHERE a.Bettype IN (@BettypeHandicap, @BettypeLA)
		
		UNION
		SELECT a.OWPMatchId
			,ml.ParentMatchId
			,a.Bettype AS BettypeId
			,mbt.ParentBettypeId
			,a.UserId
			,(CASE 
				WHEN a.UserId = @UserId THEN 1
				ELSE 0 END
				) AS IsCurrentUser
			,(CASE 
				WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
				ELSE u.Username END
				) AS Username
			,u.Skype
			,u.Extension
			,u.Phone
			,a.AssignmentType
			,a.AssignmentNote
			,a.AssignmentId
			,(CASE 
				WHEN btc.OWPMatchId IS NULL THEN 0
				ELSE 1 END
				) IsCancelled
		FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
			INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
			INNER JOIN #tblTodayMatch AS ml WITH (NOLOCK) ON minor.ParentMatchId = ml.ParentMatchId
			AND ml.IsMinorMatch = 1
			AND ml.MinorBettypeId IN (@NoOfCorners, @TotalBooking)
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
			INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
			AND a.Bettype = mbt.InheritedBettypeId
			AND mbt.ParentBettypeId IN (@Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
			LEFT JOIN dbo.MatchBetypeCancel AS btc WITH (NOLOCK) ON btc.OWPMatchId = minor.MinorMatchId
			AND btc.BetType = a.Bettype
		WHERE a.Bettype IN (@BettypeHandicap, @BettypeLA)
		) AS am
	ORDER BY am.AssignmentId

	-- Return Match Setting
	SELECT OWPMatchId
		,ParentMatchId
		,BettypeId
		,MinorBettypeId
		,Maxbet
		,Spread
	FROM #tblMatchSetting WITH (NOLOCK)

	-- Return Match Notes
	SELECT mn.OWPMatchId
		,mn.Note
		,(CASE 
			WHEN mnu.IsViewed IS NULL
				OR mnu.IsViewed = 0 THEN 0
			ELSE 1 END
			) AS IsViewed
	FROM dbo.MatchNote AS mn WITH (NOLOCK)
		INNER JOIN #tblTodayMatch AS ml WITH (NOLOCK) ON mn.OWPMatchId = ml.OWPMatchId
		LEFT JOIN dbo.MatchNoteUser AS mnu WITH (NOLOCK) ON mn.MatchNoteId = mnu.MatchNoteId
		AND mnu.UserId = @UserId
	WHERE ml.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
		OR ml.MinorBettypeId IS NULL
	ORDER BY (CASE 
			WHEN mnu.IsViewed IS NULL
				OR mnu.IsViewed = 0 THEN 0
			ELSE 1 END
			) ASC
		,mn.CreatedDate DESC

	-- Return TV color
	SELECT ml.OWPMatchId
		,tv.TVCode
		,tv.Color
	FROM #tblTodayMatch AS ml WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON ml.OWPMatchId = info.OWPMatchId
		CROSS APPLY dbo.fnc_SplitStrings(info.TVCode, ',') AS data
		INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON RTRIM(LTRIM(data.val)) = tv.TVId
	ORDER BY tv.TVId

	-- Retunr Match Offer
	SELECT tm.OWPMatchId
		,rr.[Value] AS MatchOfferValue
	FROM #tblTodayMatch AS tm WITH (NOLOCK)
	INNER JOIN dbo.MatchOfferDetail AS mo WITH (NOLOCK) ON tm.OWPMatchId = mo.OWPMatchId
	LEFT JOIN dbo.RefResource AS rr WITH (NOLOCK) ON mo.MatchOfferId = rr.ResourceId
	WHERE rr.RefName = 'MatchOffer'

	DROP TABLE #tblTodayMatch

	DROP TABLE #tblMatchSetting

	DROP TABLE #tblParentMatchSetting
END