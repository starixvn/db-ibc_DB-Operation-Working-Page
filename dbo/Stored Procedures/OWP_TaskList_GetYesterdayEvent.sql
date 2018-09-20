CREATE PROCEDURE [dbo].[OWP_TaskList_GetYesterdayEvent] @UserId INT
	,@ShowAll BIT = 0
AS
/*
 Created: 20171009@Tim.Trinh
 Task : get task list for yesterday
 DB: bodb_OWP

 Revisions:
	20180614@Leo: Display Round/OutSide/Remark independent
    20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @FromTime DATETIME
		,@ToTime DATETIME
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@NextCornerId INT = - 4
		,@NextBookingId INT = - 7
		,@BettypeHandicap INT = 1
		,@Today DATETIME = GETDATE()
		,@CurrentDateTime DATETIME = DATEADD(HOUR, 12, GETDATE())
	
	SET @FromTime = DATEADD(DAY, DATEDIFF(DAY, 0, @Today) - 1, '12:00:00')
	SET @ToTime = DATEADD(DAY, DATEDIFF(DAY, - 1, @Today) -1, '11:59:59')

	CREATE TABLE #tblTodayMatch (
		OWPMatchId INT
		,ParentMatchId INT
		,EventDateTime DATETIME
		,EventDate DATE
		,KickOffTime TIME
		,LeagueId INT
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,MatchNo VARCHAR(50)
		,OtherTime TIME
		,MatchOffer NVARCHAR(50)
		,Phone NVARCHAR(50)
		,WatchBet NVARCHAR(100)
		,Channel NVARCHAR(100)
		,TVCode NVARCHAR(MAX)
		,Runner NVARCHAR(MAX)
		,Provider NVARCHAR(MAX)
		,[Round] NVARCHAR(2000)
		,Division NVARCHAR(2000)
		,Remark NVARCHAR(2000)
		,NoOfHDP NVARCHAR(20)
		,MinorBettypeId INT
		,MatchStatus NVARCHAR(15)
		,IsMinorMatch BIT
		,IsAllowedToViewDetail BIT
		)

	CREATE TABLE #tblAssignment (
		OWPMatchId INT
		,ParentMatchId INT
		,BettypeId INT
		,MinorBettypeId INT
		,UserId INT
		,IsCurrentUser BIT
		,Username NVARCHAR(50)
		,Skype VARCHAR(50)
		,Extension VARCHAR(30)
		,Phone VARCHAR(30)
		,AssignmentType SMALLINT
		,IsCancelled BIT
		)

	CREATE TABLE #tblMatchNote (
		OWPMatchId INT
		,NewNotes INT
		,Notes INT
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
		)

	CREATE TABLE #tblParentMatchSetting (
		OWPMatchId INT
		,LeagueId INT
		,BettypeId INT
		,Maxbet MONEY
		,Spread SMALLMONEY
		,IsMatchSetting BIT
		)

	-- get events
	INSERT INTO #tblTodayMatch (
		OWPMatchId
		,ParentMatchId
		,EventDateTime
		,EventDate
		,KickOffTime
		,LeagueId
		,League
		,Home
		,Away
		,MatchNo
		,OtherTime
		,MatchOffer
		,[Round]
		,Division
		,Remark
		,Phone
		,WatchBet
		,Channel
		,TVCode
		,Provider
		,Runner
		,NoOfHDP
		,MatchStatus
		,IsMinorMatch
		,IsAllowedToViewDetail
		)
	SELECT om.OWPMatchId
		,om.OWPMatchId
		,om.EventDateTime
		,om.EventDate
		,om.KickOffTime
		,league.OWPLeagueId
		,league.OWPLeagueName
		,home.OWPTeamName
		,away.OWPTeamName
		,om.MatchNo
		,om.OtherTime
		,info.KOTimeRemark
		,info.[Round]
		,info.OutSide
		,info.Remark
		,info.Phone
		,info.WatchBet
		,info.Channel
		,info.TVCode
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.Value AS VARCHAR), '')
				FROM dbo.RefResource AS rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(info.Provider, ',') AS f
				WHERE f.val = rs.ResourceId
					AND rs.RefName = 'Provider'
				FOR XML PATH('')
				), 1, 2, '') AS Provider
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.Value AS VARCHAR), '')
				FROM dbo.RefResource AS rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(info.Runner, ',') AS f
				WHERE f.val = rs.ResourceId
					AND rs.RefName = 'Runner'
				FOR XML PATH('')
				), 1, 2, '') AS Runner
		,info.NoOfHDP
		,info.MatchStatus
		,0
		,1
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
		AND info.IsSelected = 1
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON om.OWPMatchId = mm.MinorMatchId
	WHERE mm.MinorMatchId IS NULL
		AND om.EventDateTime BETWEEN @FromTime
			AND @ToTime
		AND (
			@ShowAll = 1
			OR (
				@ShowAll = 0
				AND (
					EXISTS (
						SELECT 1
						FROM dbo.Assignment AS ass WITH (NOLOCK)
							INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON ass.Bettype = bt.BettypeId
						WHERE ass.OWPMatchId = om.OWPMatchId
							AND ass.UserId = @UserId
							AND ass.IsLive = 1
						)
					OR EXISTS (
						SELECT 1
						FROM dbo.Assignment AS ass WITH (NOLOCK)
							INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON ass.Bettype = bt.BettypeId
							INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON ass.OWPMatchId = minor.MinorMatchId
							INNER JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON minor.MinorBettypeId = mib.MinorBettypeId
							INNER JOIN dbo.MinorBettype AS mib1 WITH (NOLOCK) ON mib.MinorBettypeId = mib1.ParentBettypeId
							AND mib1.InheritedBettypeId = ass.Bettype
						WHERE minor.ParentMatchId = om.OWPMatchId
							AND minor.IsRepresented = 1
							AND minor.MinorBettypeId IN (@Specific15Mins, @Specific10Mins)
							AND ass.UserId = @UserId
							AND ass.IsLive = 1
							AND mib1.MinorBettypeId NOT IN (- 17, - 19)
						)
					)
				)
			)

	INSERT INTO #tblTodayMatch (
		OWPMatchId
		,ParentMatchId
		,EventDateTime
		,EventDate
		,KickOffTime
		,LeagueId
		,League
		,Home
		,Away
		,MatchNo
		,OtherTime
		,MatchOffer
		,[Round]
		,Division
		,Remark
		,Phone
		,WatchBet
		,Channel
		,TVCode
		,Provider
		,Runner
		,MinorBettypeId
		,MatchStatus
		,IsMinorMatch
		,IsAllowedToViewDetail
		)
	SELECT DISTINCT mm.MinorMatchId
		,parent.OWPMatchId
		,om.EventDateTime
		,om.EventDate
		,om.KickOffTime
		,league.OWPLeagueId
		,league.OWPLeagueName
		,home.OWPTeamName
		,away.OWPTeamName
		,om.MatchNo
		,parent.OtherTime
		,info.KOTimeRemark
		,info.[Round]
		,info.OutSide
		,info.Remark
		,pinfo.Phone
		,pinfo.WatchBet
		,pinfo.Channel
		,pinfo.TVCode
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.Value AS VARCHAR), '')
				FROM dbo.RefResource AS rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(pinfo.Provider, ',') AS f
				WHERE f.val = rs.ResourceId
					AND rs.RefName = 'Provider'
				FOR XML PATH('')
				), 1, 2, '') AS Provider
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.Value AS VARCHAR), '')
				FROM dbo.RefResource AS rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(pinfo.Runner, ',') AS f
				WHERE f.val = rs.ResourceId
					AND rs.RefName = 'Runner'
				FOR XML PATH('')
				), 1, 2, '') AS Runner
		,mm.MinorBettypeId
		,info.MatchStatus
		,1
		,1
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
		AND info.IsSelected = 1
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		INNER JOIN dbo.OWPMatch AS parent WITH (NOLOCK) ON mm.ParentMatchId = parent.OWPMatchId
		INNER JOIN dbo.MatchInfo AS pinfo WITH (NOLOCK) ON parent.OWPMatchId = pinfo.OWPMatchId
	WHERE mm.IsRepresented = 1
		AND om.EventDateTime BETWEEN @FromTime
			AND @ToTime
		AND (
			@ShowAll = 1
			OR (
				@ShowAll = 0
				AND (
					EXISTS (
						SELECT 1
						FROM dbo.Assignment AS ass WITH (NOLOCK)
							INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON ass.Bettype = bt.BettypeId
						WHERE ass.OWPMatchId = om.OWPMatchId
							AND ass.UserId = @UserId
							AND ass.IsLive = 1
						)
					)
				)
			)

	INSERT INTO #tblTodayMatch (
		OWPMatchId
		,ParentMatchId
		,EventDateTime
		,EventDate
		,KickOffTime
		,LeagueId
		,League
		,Home
		,Away
		,MatchNo
		,OtherTime
		,MatchOffer
		,[Round]
		,Division
		,Remark
		,Phone
		,WatchBet
		,Channel
		,TVCode
		,Provider
		,Runner
		,MinorBettypeId
		,MatchStatus
		,IsMinorMatch
		,IsAllowedToViewDetail
		)
	SELECT om.OWPMatchId
		,parent.OWPMatchId
		,om.EventDateTime
		,parent.EventDate
		,parent.KickOffTime
		,league.OWPLeagueId
		,league.OWPLeagueName
		,home.OWPTeamName
		,away.OWPTeamName
		,om.MatchNo
		,parent.OtherTime
		,info.KOTimeRemark
		,info.[Round]
		,info.OutSide
		,info.Remark
		,pinfo.Phone
		,pinfo.WatchBet
		,pinfo.Channel
		,pinfo.TVCode
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.Value AS VARCHAR), '')
				FROM dbo.RefResource AS rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(pinfo.Provider, ',') AS f
				WHERE f.val = rs.ResourceId
					AND rs.RefName = 'Provider'
				FOR XML PATH('')
				), 1, 2, '') AS Provider
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.Value AS VARCHAR), '')
				FROM dbo.RefResource AS rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(pinfo.Runner, ',') AS f
				WHERE f.val = rs.ResourceId
					AND rs.RefName = 'Runner'
				FOR XML PATH('')
				), 1, 2, '') AS Runner
		,mm.MinorBettypeId
		,info.MatchStatus
		,1
		,1
	FROM (
		SELECT mim.MinorMatchId AS OWPMatchId
		FROM dbo.MinorMatch AS mim WITH (NOLOCK)
			INNER JOIN #tblTodayMatch AS tod ON mim.ParentMatchId = tod.OWPMatchId
		WHERE mim.MinorBettypeId IN (@Specific15Mins, @Specific10Mins)
			AND mim.MinorMatchId NOT IN (
				SELECT OWPMatchId
				FROM #tblTodayMatch WITH (NOLOCK)
				)
		
		UNION
		SELECT mim.ParentMatchId AS OWPMatchId
		FROM dbo.MinorMatch AS mim WITH (NOLOCK)
			INNER JOIN #tblTodayMatch AS tod ON mim.MinorMatchId = tod.OWPMatchId
		WHERE mim.MinorBettypeId IN (@Specific15Mins, @Specific10Mins)
			AND mim.ParentMatchId NOT IN (
				SELECT OWPMatchId
				FROM #tblTodayMatch WITH (NOLOCK)
				)
		
		UNION
		SELECT mim1.MinorMatchId AS OWPMatchId
		FROM dbo.MinorMatch AS mim WITH (NOLOCK)
			INNER JOIN #tblTodayMatch AS tod ON mim.MinorMatchId = tod.OWPMatchId
			INNER JOIN dbo.MinorMatch AS mim1 WITH (NOLOCK) ON mim1.ParentMatchId = mim.ParentMatchId
		WHERE mim1.MinorMatchId NOT IN (
				SELECT OWPMatchId
				FROM #tblTodayMatch WITH (NOLOCK)
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
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
		AND info.IsSelected = 1
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		INNER JOIN dbo.OWPMatch AS parent WITH (NOLOCK) ON mm.ParentMatchId = parent.OWPMatchId
		INNER JOIN dbo.MatchInfo AS pinfo WITH (NOLOCK) ON parent.OWPMatchId = pinfo.OWPMatchId
		LEFT JOIN #tblTodayMatch AS ml WITH (NOLOCK) ON om.OWPMatchId = ml.OWPMatchId
	WHERE ml.OWPMatchId IS NULL
		AND om.EventDateTime BETWEEN @FromTime
			AND @ToTime

	-- get assignment
	INSERT INTO #tblAssignment (
		OWPMatchId
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
		)
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
		,ml.LeagueId
		,ls.Bettype
		,ml.MinorBettypeId
		,0
	FROM #tblTodayMatch AS ml WITH (NOLOCK)
		INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON ml.LeagueId = ls.LeagueId
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

	-- get match note
	INSERT INTO #tblMatchNote (
		OWPMatchId
		,NewNotes
		,Notes
		)
	SELECT mn.OWPMatchId
		,SUM(1 - CONVERT(INT, CASE 
					WHEN ISNULL(mnu.IsViewed, 0) = 0 THEN 0
					ELSE 1
					END)) NewNotes
		,COUNT(mn.MatchNoteId) Notes
	FROM dbo.MatchNote AS mn WITH (NOLOCK)
		INNER JOIN #tblTodayMatch AS ml WITH (NOLOCK) ON mn.OWPMatchId = ml.OWPMatchId
		LEFT JOIN dbo.MatchNoteUser AS mnu WITH (NOLOCK) ON mn.MatchNoteId = mnu.MatchNoteId
		AND mnu.UserId = @UserId
	WHERE ml.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
		OR ml.MinorBettypeId IS NULL
	GROUP BY mn.OWPMatchId

	--
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,m.EventDate
		,m.KickOffTime
		,m.League
		,m.Home
		,m.Away
		,m.MatchNo
		,m.OtherTime
		,m.NoOfHDP
		,m.MatchOffer
		,m.[Round]
		,m.Division
		,m.Remark
		,m.Phone
		,m.WatchBet
		,m.Channel
		,m.Provider
		,m.Runner
		,(CASE 
			WHEN DATEDIFF(MINUTE, @CurrentDateTime, m.EventDateTime) <= 60 THEN 1
			ELSE 0 END
			) AS IsOneHourToKickOffTime
		,[dbo].[OWP_GetCurrentMatchStatus] (m.EventDate, m.KickOffTime, m.MatchStatus) AS MatchStatus
		,m.MinorBettypeId
		,(CASE 
			WHEN notes.NewNotes > 0 THEN 1
			ELSE 0 END
			) AS HasNewNote
		,notes.Notes
		,m.IsAllowedToViewDetail
		,1 AS IsTodayEvent
	FROM #tblTodayMatch AS m WITH (NOLOCK)
		LEFT JOIN #tblMatchNote AS notes WITH (NOLOCK) ON notes.OWPMatchId = m.OWPMatchId
	WHERE m.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
		OR m.MinorBettypeId IS NULL
	ORDER BY m.EventDate
		,m.KickOffTime
		,CASE 
			WHEN ISNULL(m.MatchNo, '') = '' THEN 1
			ELSE 0
			END
		,m.MatchNo

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
	FROM #tblAssignment AS am WITH (NOLOCK)
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

	SELECT OWPMatchId
		,ParentMatchId
		,BettypeId
		,MinorBettypeId
		,Maxbet
		,Spread
	FROM #tblMatchSetting WITH (NOLOCK)

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

	SELECT ml.OWPMatchId
		,tv.TVCode
		,tv.Color
	FROM #tblTodayMatch AS ml WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(ml.TVCode, ',') AS data
		INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON RTRIM(LTRIM(data.val)) = tv.TVCode

	DROP TABLE #tblAssignment

	DROP TABLE #tblTodayMatch

	DROP TABLE #tblMatchNote

	DROP TABLE #tblMatchSetting

	DROP TABLE #tblParentMatchSetting
END