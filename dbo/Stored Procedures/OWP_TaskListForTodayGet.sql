CREATE PROCEDURE [dbo].[OWP_TaskListForTodayGet] @UserId INT
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
*/
BEGIN
	DECLARE @FromTime DATETIME
		,@ToTime DATETIME
		,@FromTimeForSpecialBettype DATETIME
		,@ToTimeViewDetailForSpecialBettype DATETIME
		,@ToTimeForSpecialBettype DATETIME
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsHDP INT = - 16
		,@Specific10MinsHDP INT = - 18
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@NextCornerId INT = - 4
		,@NextBookingId INT = - 7
		,@BettypeHandicap INT = 1
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

	CREATE TABLE #tblTodayMatch(
		OWPMatchId INT
		,ParentMatchId INT
		,MinorBettypeId INT
		,IsMinorMatch BIT
		,IsAllowedToViewDetail BIT
	)

	SELECT @FromTime = FromTime
		,@ToTime = ToTime
		,@FromTimeForSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeForSpecialBettype = ToTimeForSpecialBettype
		,@ToTimeViewDetailForSpecialBettype = ToTimeViewDetailForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

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
	WHERE 
		om.EventDateTime BETWEEN @FromTime
					AND @ToTime
		AND ass.UserId = @UserId
		AND ass.IsLive = 1
		AND NOT EXISTS 
		(
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
			INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON ass.OWPMatchId = minor.MinorMatchId
			INNER JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON minor.MinorBettypeId = mib.MinorBettypeId
		WHERE om.EventDateTime BETWEEN @FromTime AND @ToTime
			AND minor.IsRepresented = 1
			AND ass.UserId = @UserId
			AND ass.IsLive = 1
	
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
		INNER JOIN dbo.Assignment AS ass WITH (NOLOCK) ON ass.OWPMatchId = om.OWPMatchId
	WHERE ass.UserId = @UserId 
		AND ass.IsLive = 1
		AND mm.MinorBettypeId IN (@NextCornerId, @NextBookingId, @NoOfCorners, @TotalBooking)
		AND om.EventDateTime > @ToTimeViewDetailForSpecialBettype
		AND om.EventDateTime <= @ToTimeForSpecialBettype
		AND NOT EXISTS 
		(
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
	WHERE mim.MinorBettypeId IN (@Specific15Mins, @Specific10Mins)
		AND NOT EXISTS 
		(
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
		WHERE mim.MinorBettypeId IN (@Specific15Mins, @Specific10Mins)
			AND NOT EXISTS 
			(
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
		WHERE NOT EXISTS 
			(
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
	WHERE ml.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
		OR ml.MinorBettypeId IS NULL

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
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON ml.OWPMatchId = om.OWPLeagueId
		INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON om.OWPLeagueId = ls.LeagueId
	WHERE ml.OWPMatchId NOT IN (
			SELECT OWPMatchId
			FROM #tblMatchSetting WITH (NOLOCK)
			)
		AND ml.IsMinorMatch = 0

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
		AND parent.OWPMatchId NOT IN (
			SELECT OWPMatchId
			FROM #tblParentMatchSetting WITH (NOLOCK)
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
		WHERE ml.OWPMatchId NOT IN (
				SELECT OWPMatchId
				FROM #tblMatchSetting WITH (NOLOCK)
				)
			AND ml.IsMinorMatch = 1
		) AS tbl
		INNER JOIN dbo.MinorSetting AS minors WITH (NOLOCK) ON tbl.Maxbet BETWEEN ISNULL(minors.FromMaxBet, 0)
			AND ISNULL(minors.ToMaxBet, 99999999999)
		INNER JOIN dbo.MinorSettingDetail AS msdt WITH (NOLOCK) ON minors.MinorSettingId = msdt.MinorSettingId
		AND msdt.MinorBettypeId = tbl.ParentBettypeId

	-- Return Match Info
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,pa.EventDate
		,pa.KickOffTime
		,league.OWPLeagueName AS League
		,home.OWPTeamName AS Home
		,away.OWPTeamName AS Away
		,om.MatchNo
		,pa.OtherTime
		,inf.NoOfHDP
		,inf.KOTimeRemark AS MatchOffer
		,inf.[Round]
		,inf.OutSide AS Division
		,inf.Remark
		,inf.Phone
		,painf.WatchBet
		,painf.Channel
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.Value AS VARCHAR), '')
				FROM dbo.RefResource AS rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(painf.Provider, ',') AS f
				WHERE f.val = rs.ResourceId
					AND rs.RefName = 'Provider'
				FOR XML PATH('')
				), 1, 2, '') AS Provider
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.Value AS VARCHAR), '')
				FROM dbo.RefResource AS rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(painf.Runner, ',') AS f
				WHERE f.val = rs.ResourceId
					AND rs.RefName = 'Runner'
				FOR XML PATH('')
				), 1, 2, '') AS Runner
		,(CASE 
			WHEN DATEDIFF(MINUTE, @CurrentDateTime, pa.EventDateTime) <= 60 THEN 1
			ELSE 0 END
			) AS IsOneHourToKickOffTime
		,[dbo].[OWP_GetCurrentMatchStatus] (pa.EventDate, pa.KickOffTime, inf.MatchStatus) AS MatchStatus
		,m.MinorBettypeId
		,m.IsAllowedToViewDetail
		,(CASE WHEN pa.EventDateTime BETWEEN DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00')
				AND DATEADD(DAY, DATEDIFF(DAY, - 1, @Today), '11:59:59') THEN 1
			ELSE 0 END) AS IsTodayEvent
	FROM #tblTodayMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.OWPMatchId = om.OWPMatchId
		INNER JOIN dbo.OWPMatch AS pa WITH (NOLOCK) ON m.ParentMatchId = pa.OWPMatchId
		INNER JOIN dbo.MatchInfo AS inf WITH (NOLOCK) ON m.OWPMatchId = inf.OWPMatchId
		INNER JOIN dbo.MatchInfo AS painf WITH (NOLOCK) ON m.ParentMatchId = painf.OWPMatchId
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
	WHERE m.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
		OR m.MinorBettypeId IS NULL
	ORDER BY pa.EventDate
		,pa.KickOffTime
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
		,IsCancelled
	FROM 
	(
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
			,(CASE 
				WHEN btc.OWPMatchId IS NULL THEN 0
				ELSE 1 END
				) IsCancelled
		FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
			INNER JOIN #tblTodayMatch AS ml WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
			LEFT JOIN dbo.MatchBetypeCancel AS btc WITH (NOLOCK) ON btc.OWPMatchId = ml.OWPMatchId
			AND btc.BetType = a.Bettype
			LEFT JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON ml.MinorBettypeId = mbt.ParentBettypeId
			AND a.Bettype = mbt.InheritedBettypeId
		WHERE a.IsLive = 1
			AND (
				ml.IsMinorMatch = 0
				OR (
					ml.IsMinorMatch = 1
					AND mbt.MinorBettypeId IS NOT NULL
					AND ml.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
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
			,(CASE 
				WHEN btc.OWPMatchId IS NULL THEN 0
				ELSE 1 END
				) IsCancelled
		FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
			INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
			INNER JOIN #tblTodayMatch AS ml WITH (NOLOCK) ON minor.ParentMatchId = ml.OWPMatchId
			AND ml.IsMinorMatch = 0
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
			INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
			AND a.Bettype = mbt.InheritedBettypeId
			AND mbt.ParentBettypeId IN (@Specific10Mins, @Specific15Mins)
			LEFT JOIN dbo.MatchBetypeCancel AS btc WITH (NOLOCK) ON btc.OWPMatchId = minor.MinorMatchId
			AND btc.BetType = a.Bettype
		WHERE a.IsLive = 1
			AND a.Bettype IN (@BettypeHandicap, - 1001, - 1002)
	
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
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
			INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
			AND a.Bettype = mbt.InheritedBettypeId
			AND mbt.ParentBettypeId IN (@Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
			LEFT JOIN dbo.MatchBetypeCancel AS btc WITH (NOLOCK) ON btc.OWPMatchId = minor.MinorMatchId
			AND btc.BetType = a.Bettype
		WHERE a.IsLive = 1
			AND a.Bettype IN (@BettypeHandicap, - 1001, - 1002)
	) AS am
	ORDER BY am.ParentMatchId
		,CASE 
			WHEN am.BettypeId > 0 THEN 0
			ELSE 1
			END
		,CASE 
			WHEN am.AssignmentType = 1 THEN 0
			WHEN am.AssignmentType = 4 THEN 1
			WHEN am.AssignmentType = 2 THEN 2
			WHEN am.AssignmentType = 3 THEN 3
			END
		,(CASE WHEN MinorBettypeId IS NULL THEN 0
			ELSE MinorBettypeId END) DESC
		,BettypeId DESC

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
	WHERE ml.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
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
		INNER JOIN dbo.MatchInfo AS painf WITH (NOLOCK) ON ml.ParentMatchId = painf.OWPMatchId
		CROSS APPLY dbo.fnc_SplitStrings(painf.TVCode, ',') AS data
		INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON RTRIM(LTRIM(data.val)) = tv.TVCode

	DROP TABLE #tblTodayMatch

	DROP TABLE #tblMatchSetting

	DROP TABLE #tblParentMatchSetting
END