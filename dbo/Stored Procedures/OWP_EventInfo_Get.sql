/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EventInfo_Get] @EventDate DATE
	,@HomeName NVARCHAR(500) = NULL
	,@AwayName NVARCHAR(500) = NULL
	,@WatchBet NVARCHAR(500) = NULL
	,@Phone NVARCHAR(50) = NULL
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
	,@ProviderIds NVARCHAR(MAX) = NULL
	,@RunnerIds NVARCHAR(MAX) = NULL
	,@TVCodes NVARCHAR(MAX) = NULL
	,@PageIndex INT = NULL
	,@ItemsPerPage INT = NULL
	,@IsSelected INT = 1
	,@MatchNumber NVARCHAR(50) = NULL
	,@Remark NVARCHAR(500) = NULL
	,@AssigneeLocation INT = - 1
	,@MatchStatusIds NVARCHAR(20) = NULL
	,@ShowAll BIT = 0
	,@TotalItem INT = NULL OUTPUT

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
	20180706@Raymond.Le: Modify follow new structure of event assignment
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

	----------
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
		,MatchNo NVARCHAR(50)
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
		,IsSelected BIT
		)

	CREATE TABLE #tblPreFilterMatch (
		OWPMatchId INT
		,ParentMatchId INT
		,EventDateTime DATETIME
		,EventDate DATE
		,KickOffTime TIME
		,LeagueId INT
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,MatchNo NVARCHAR(50)
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
		,IsSelected BIT
		)

	CREATE TABLE #tblAssignment (
		OWPMatchId INT
		,ParentMatchId INT
		,BettypeId INT
		,MinorBettypeId INT
		,UserId INT
		,IsCurrentUser BIT
		,Username NVARCHAR(50)
		,Nickname NVARCHAR(30)
		,Skype VARCHAR(50)
		,Extension VARCHAR(30)
		,Phone VARCHAR(30)
		,AssignmentType SMALLINT
		,LocationCode VARCHAR(20)
		,AssignmentNote NVARCHAR(200)
		,AssignmentId INT
		)

	CREATE TABLE #tblMatchNote (
		OWPMatchId INT
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

	-- filter Table
	CREATE TABLE #tblLeague (
		LeagueId INT
		,[Name] NVARCHAR(500)
		)

	CREATE TABLE #tblAssignee (UserId INT)

	CREATE TABLE #tblAgent (Id INT)

	CREATE TABLE #tblProvider (Id INT)

	CREATE TABLE #tblRunner (Id INT)

	CREATE TABLE #tblTelevision (TVCode NVARCHAR(100))

	CREATE TABLE #tblLocationCode (LCode VARCHAR(20))

	CREATE TABLE #tblMatchStatus (MatchStatus NVARCHAR(15))

	CREATE TABLE #tblMatchFiltered (
		OWPMatchId INT
		,ParentMatchId INT
		,MinorBettypeId INT
		)

	CREATE TABLE #tblMatchFilteredDistinct (
		OWPMatchId INT
		,ParentMatchId INT
		,MinorBettypeId INT
		)

	--
	CREATE TABLE #tblMatchId (
		RowIndex INT
		,OWPMatchId INT
		,ParentMatchId INT
		)

	CREATE TABLE #tblFinalMatchIdIncludeMinorMatch (
		---Minor bettype IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
		OWPMatchId INT
		,ParentMatchId INT
		)

	CREATE TABLE #tblFinalMatchId (
		OWPMatchId INT
		,ParentMatchId INT
		,RowIndex INT
		,PageIndex INT
		,IsDisplay BIT
		)

	IF @LeagueIds IS NOT NULL
	BEGIN
		INSERT INTO #tblLeague (
			LeagueId
			,[Name]
			)
		SELECT league.OWPLeagueId
			,league.OWPLeagueName
		FROM dbo.strSplit(@LeagueIds, ',') AS lid
			INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON CAST(lid.[val] AS INT) = league.OWPLeagueId
	END

	IF @AssigneeIds IS NOT NULL
	BEGIN
		INSERT INTO #tblAssignee (UserId)
		SELECT CAST([val] AS INT)
		FROM dbo.strSplit(@AssigneeIds, ',')
	END

	IF @AgentIds IS NOT NULL
	BEGIN
		INSERT INTO #tblAgent (Id)
		SELECT CAST([val] AS INT)
		FROM dbo.strSplit(@AgentIds, ',')
	END

	IF @ProviderIds IS NOT NULL
	BEGIN
		INSERT INTO #tblProvider (Id)
		SELECT CAST([val] AS INT)
		FROM dbo.strSplit(@ProviderIds, ',')
	END

	IF @RunnerIds IS NOT NULL
	BEGIN
		INSERT INTO #tblRunner (Id)
		SELECT CAST([val] AS INT)
		FROM dbo.strSplit(@RunnerIds, ',')
	END

	IF @TVCodes IS NOT NULL
	BEGIN
		INSERT INTO #tblTelevision (TVCode)
		SELECT [val]
		FROM dbo.strSplit(@TVCodes, ',')
	END

	IF @AssigneeLocation > - 1
	BEGIN
		INSERT INTO #tblLocationCode (LCode)
		SELECT rr.Value
		FROM dbo.RefResource AS rr WITH (NOLOCK)
		WHERE rr.RefName = 'LocationCode'
			AND rr.ResourceId = @AssigneeLocation
	END

	IF @MatchStatusIds IS NOT NULL
	BEGIN
		INSERT INTO #tblMatchStatus (MatchStatus)
		SELECT ref.Value
		FROM dbo.strSplit(@MatchStatusIds, ',') AS ms
			LEFT JOIN (
			SELECT rr.ResourceId
				,rr.Value
			FROM dbo.RefResource AS rr WITH (NOLOCK)
			WHERE rr.RefName = 'MatchStatus'
			) AS ref ON ref.ResourceId = CAST(ms.[val] AS INT)
	END

	-----------------------------------------------------
	----- get events can view detail
	INSERT INTO #tblPreFilterMatch (
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
		,IsSelected
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
		,info.Division
		,info.Remark
		,info.Phone
		,info.WB
		,info.Channel
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.TVCode AS VARCHAR), '')
				FROM dbo.Television rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(info.TVCode, ',') f
				WHERE f.val = rs.TVId
				FOR XML PATH('')
				), 1, 2, '') AS TVCode
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.ProviderName AS VARCHAR), '')
				FROM dbo.[Provider] rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(info.[Provider], ',') f
				WHERE f.val = rs.ProviderId
				FOR XML PATH('')
				), 1, 2, '') AS Provider
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.RunnerName AS VARCHAR), '')
				FROM dbo.Runner rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(info.Runner, ',') f
				WHERE f.val = rs.RunnerId
				FOR XML PATH('')
				), 1, 2, '') AS Runner
		,info.NoOfHDP
		,[dbo].[OWP_GetCurrentMatchStatus](om.EventDate, om.KickOffTime, info.MatchStatus) AS MatchStatus
		,0
		,1
		,info.IsSelected
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
	--AND info.IsSelected = 1
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON om.OWPMatchId = mm.MinorMatchId
	WHERE mm.MinorMatchId IS NULL
		AND (
			(
				(
					@ShowAll = 1
					AND (
						om.EventDateTime BETWEEN @FilterFromDateTime
							AND @FilterToDateTime
						)
					)
				)
			OR (
				@ShowAll = 0
				AND (
					om.EventDateTime BETWEEN @FromTime
						AND @ToTime
					)
				)
			)

	INSERT INTO #tblPreFilterMatch (
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
		,IsSelected
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
		,om.OtherTime
		,info.KOTimeRemark
		,info.[Round]
		,info.Division
		,info.Remark
		,info.Phone
		,info.WB
		,info.Channel
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.TVCode AS VARCHAR), '')
				FROM dbo.Television rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(info.TVCode, ',') f
				WHERE f.val = rs.TVId
				FOR XML PATH('')
				), 1, 2, '') AS TVCode
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.ProviderName AS VARCHAR), '')
				FROM dbo.[Provider] rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(info.[Provider], ',') f
				WHERE f.val = rs.ProviderId
				FOR XML PATH('')
				), 1, 2, '') AS Provider
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.RunnerName AS VARCHAR), '')
				FROM dbo.Runner rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(info.Runner, ',') f
				WHERE f.val = rs.RunnerId
				FOR XML PATH('')
				), 1, 2, '') AS Runner
		,mm.MinorBettypeId
		,[dbo].[OWP_GetCurrentMatchStatus](om.EventDate, om.KickOffTime, info.MatchStatus) AS MatchStatus
		,1
		,1
		,info.IsSelected
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
	--AND info.IsSelected = 1
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		INNER JOIN dbo.OWPMatch AS parent WITH (NOLOCK) ON mm.ParentMatchId = parent.OWPMatchId
		INNER JOIN dbo.MatchInfo AS pinfo WITH (NOLOCK) ON parent.OWPMatchId = pinfo.OWPMatchId
	WHERE  (
				(
					@ShowAll = 1
					AND (
						om.EventDateTime BETWEEN @FilterFromDateTime
							AND @FilterToDateTime
						)
					)
				)
			OR (
				@ShowAll = 0
				AND (
					om.EventDateTime BETWEEN @FromTime
						AND @ToTime
					)
				)

	-- get events can not view detail
	IF (@ShowAll = 0)
	BEGIN
		INSERT INTO #tblPreFilterMatch (
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
			,IsSelected
			)
		SELECT om.OWPMatchId
			,parent.OWPMatchId
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
			,info.Division
			,info.Remark
			,info.Phone
			,info.WB
			,info.Channel
			,STUFF((
					SELECT ', ' + ISNULL(CAST(rs.TVCode AS VARCHAR), '')
					FROM dbo.Television rs WITH (NOLOCK)
						CROSS APPLY dbo.fnc_SplitStrings(info.TVCode, ',') f
					WHERE f.val = rs.TVId
					FOR XML PATH('')
					), 1, 2, '') AS TVCode
			,STUFF((
					SELECT ', ' + ISNULL(CAST(rs.ProviderName AS VARCHAR), '')
					FROM dbo.[Provider] rs WITH (NOLOCK)
						CROSS APPLY dbo.fnc_SplitStrings(info.[Provider], ',') f
					WHERE f.val = rs.ProviderId
					FOR XML PATH('')
					), 1, 2, '') AS Provider
			,STUFF((
					SELECT ', ' + ISNULL(CAST(rs.RunnerName AS VARCHAR), '')
					FROM dbo.Runner rs WITH (NOLOCK)
						CROSS APPLY dbo.fnc_SplitStrings(info.Runner, ',') f
					WHERE f.val = rs.RunnerId
					FOR XML PATH('')
					), 1, 2, '') AS Runner
			,mm.MinorBettypeId
			,[dbo].[OWP_GetCurrentMatchStatus](om.EventDate, om.KickOffTime, info.MatchStatus) AS MatchStatus
			,1
			,CASE @ShowAll
				WHEN 0 THEN 0
				ELSE 1
				END
			,info.IsSelected
		FROM dbo.MinorMatch AS mm WITH (NOLOCK)
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON mm.MinorMatchId = om.OWPMatchId
			INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
		--AND info.IsSelected = 1
			INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			INNER JOIN dbo.OWPMatch AS parent WITH (NOLOCK) ON mm.ParentMatchId = parent.OWPMatchId
			INNER JOIN dbo.MatchInfo AS pinfo WITH (NOLOCK) ON parent.OWPMatchId = pinfo.OWPMatchId
			LEFT JOIN #tblPreFilterMatch AS ml WITH (NOLOCK) ON om.OWPMatchId = ml.OWPMatchId
		WHERE mm.MinorBettypeId IN (@NextCorners, @NoOfCorners, @LastCorners, @HomeSingleTeamCorners, @AwaySingleTeamCorners, @NextBooking, @TotalBooking, @LastBooking)
			AND ml.OWPMatchId IS NULL
			AND om.EventDateTime > @ToTimeViewDetailForSpecialBettype
			AND om.EventDateTime <= @ToTimeForSpecialBettype

		INSERT INTO #tblPreFilterMatch (
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
			,IsSelected
			)
		SELECT om.OWPMatchId
			,parent.OWPMatchId
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
			,info.Division
			,info.Remark
			,info.Phone
			,info.WB
			,info.Channel
			,STUFF((
					SELECT ', ' + ISNULL(CAST(rs.TVCode AS VARCHAR), '')
					FROM dbo.Television rs WITH (NOLOCK)
						CROSS APPLY dbo.fnc_SplitStrings(info.TVCode, ',') f
					WHERE f.val = rs.TVId
					FOR XML PATH('')
					), 1, 2, '') AS TVCode
			,STUFF((
					SELECT ', ' + ISNULL(CAST(rs.ProviderName AS VARCHAR), '')
					FROM dbo.[Provider] rs WITH (NOLOCK)
						CROSS APPLY dbo.fnc_SplitStrings(info.[Provider], ',') f
					WHERE f.val = rs.ProviderId
					FOR XML PATH('')
					), 1, 2, '') AS Provider
			,STUFF((
					SELECT ', ' + ISNULL(CAST(rs.RunnerName AS VARCHAR), '')
					FROM dbo.Runner rs WITH (NOLOCK)
						CROSS APPLY dbo.fnc_SplitStrings(info.Runner, ',') f
					WHERE f.val = rs.RunnerId
					FOR XML PATH('')
					), 1, 2, '') AS Runner
			,mm.MinorBettypeId
			,[dbo].[OWP_GetCurrentMatchStatus](om.EventDate, om.KickOffTime, info.MatchStatus) AS MatchStatus
			,1
			,CASE @ShowAll
				WHEN 0 THEN 0
				ELSE 1
				END
			,info.IsSelected
		FROM (
			SELECT mim.MinorMatchId AS OWPMatchId
			FROM dbo.MinorMatch AS mim WITH (NOLOCK)
				INNER JOIN #tblPreFilterMatch AS tod ON mim.ParentMatchId = tod.OWPMatchId
			WHERE mim.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)
				AND mim.MinorMatchId NOT IN (
					SELECT OWPMatchId
					FROM #tblPreFilterMatch WITH (NOLOCK)
					)
			
			UNION
			SELECT mim.ParentMatchId AS OWPMatchId
			FROM dbo.MinorMatch AS mim WITH (NOLOCK)
				INNER JOIN #tblPreFilterMatch AS tod ON mim.MinorMatchId = tod.OWPMatchId
			WHERE mim.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)
				AND mim.ParentMatchId NOT IN (
					SELECT OWPMatchId
					FROM #tblPreFilterMatch WITH (NOLOCK)
					)
			
			UNION
			SELECT mim1.MinorMatchId AS OWPMatchId
			FROM dbo.MinorMatch AS mim WITH (NOLOCK)
				INNER JOIN #tblPreFilterMatch AS tod ON mim.MinorMatchId = tod.OWPMatchId
				INNER JOIN dbo.MinorMatch AS mim1 WITH (NOLOCK) ON mim1.ParentMatchId = mim.ParentMatchId
			WHERE mim1.MinorMatchId NOT IN (
					SELECT OWPMatchId
					FROM #tblPreFilterMatch WITH (NOLOCK)
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
		--AND info.IsSelected = 1
			INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON om.OWPLeagueId = league.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			INNER JOIN dbo.OWPMatch AS parent WITH (NOLOCK) ON mm.ParentMatchId = parent.OWPMatchId
			INNER JOIN dbo.MatchInfo AS pinfo WITH (NOLOCK) ON parent.OWPMatchId = pinfo.OWPMatchId
			LEFT JOIN #tblPreFilterMatch AS ml WITH (NOLOCK) ON om.OWPMatchId = ml.OWPMatchId
		WHERE ml.OWPMatchId IS NULL
	END

	---------------------------
	-- get assignment
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
		,AssignmentType
		,LocationCode
		,AssignmentNote
		,AssignmentId
		)
	SELECT a.OWPMatchId
		,ml.ParentMatchId
		,a.Bettype AS BettypeId
		,ml.MinorBettypeId
		,a.UserId
		,0
		,u.Username
		,(CASE 
			WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
			ELSE u.Username END
			) AS Nickname
		,u.Skype
		,u.Extension
		,u.Phone
		,a.AssignmentType
		,u.LocationCode
		,a.AssignmentNote
		,a.AssignmentId
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
		INNER JOIN #tblPreFilterMatch AS ml WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
		LEFT JOIN dbo.MatchBetypeCancel AS btc WITH (NOLOCK) ON btc.OWPMatchId = ml.OWPMatchId
		AND btc.BetType = a.Bettype
		LEFT JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON ml.MinorBettypeId = mbt.ParentBettypeId
		AND a.Bettype = mbt.InheritedBettypeId
	WHERE ml.IsMinorMatch = 0
		OR (
			ml.IsMinorMatch = 1
			AND mbt.MinorBettypeId IS NOT NULL
			AND ml.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
			)
	
	UNION
	SELECT a.OWPMatchId
		,ml.ParentMatchId
		,a.Bettype AS BettypeId
		,mbt.ParentBettypeId
		,a.UserId
		,0
		,u.Username
		,(CASE 
			WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
			ELSE u.Username END
			) AS Nickname
		,u.Skype
		,u.Extension
		,u.Phone
		,a.AssignmentType
		,u.LocationCode
		,a.AssignmentNote
		,a.AssignmentId
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
		INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
		INNER JOIN #tblPreFilterMatch AS ml WITH (NOLOCK) ON minor.ParentMatchId = ml.OWPMatchId
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
		,0
		,u.Username
		,(CASE 
			WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
			ELSE u.Username END
			) AS Nickname
		,u.Skype
		,u.Extension
		,u.Phone
		,a.AssignmentType
		,u.LocationCode
		,a.AssignmentNote
		,a.AssignmentId
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
		INNER JOIN dbo.MajorBettype AS bt WITH (NOLOCK) ON a.Bettype = bt.BettypeId
		INNER JOIN #tblPreFilterMatch AS ml WITH (NOLOCK) ON minor.ParentMatchId = ml.ParentMatchId
		AND ml.IsMinorMatch = 1
		AND ml.MinorBettypeId IN (@NoOfCorners, @TotalBooking)
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
		INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
		AND a.Bettype = mbt.InheritedBettypeId
		AND mbt.ParentBettypeId IN (@Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
		LEFT JOIN dbo.MatchBetypeCancel AS btc WITH (NOLOCK) ON btc.OWPMatchId = minor.MinorMatchId
		AND btc.BetType = a.Bettype
	WHERE a.Bettype IN (@BettypeHandicap, @BettypeLA)

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
	FROM #tblPreFilterMatch AS ml WITH (NOLOCK)
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
		,ml.LeagueId
		,ls.Bettype
		,ml.MinorBettypeId
		,0
	FROM #tblPreFilterMatch AS ml WITH (NOLOCK)
		INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON ml.LeagueId = ls.LeagueId
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
	FROM #tblPreFilterMatch AS ml WITH (NOLOCK)
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
	FROM #tblPreFilterMatch AS ml WITH (NOLOCK)
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
		FROM #tblPreFilterMatch AS ml WITH (NOLOCK)
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

	-- get match note
	INSERT INTO #tblMatchNote (
		OWPMatchId
		,Notes
		)
	SELECT mn.OWPMatchId
		,COUNT(mn.MatchNoteId) Notes
	FROM dbo.MatchNote AS mn WITH (NOLOCK)
		INNER JOIN #tblPreFilterMatch AS ml WITH (NOLOCK) ON mn.OWPMatchId = ml.OWPMatchId
	WHERE ml.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
		OR ml.MinorBettypeId IS NULL
	GROUP BY mn.OWPMatchId

	-----------------------------------------------
	------
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
		,MinorBettypeId
		,MatchStatus
		,IsMinorMatch
		,IsAllowedToViewDetail
		,IsSelected
		)
	SELECT DISTINCT pf.OWPMatchId
		,pf.ParentMatchId
		,pf.EventDateTime
		,pf.EventDate
		,pf.KickOffTime
		,pf.LeagueId
		,pf.League
		,pf.Home
		,pf.Away
		,pf.MatchNo
		,pf.OtherTime
		,pf.MatchOffer
		,pf.[Round]
		,pf.Division
		,pf.Remark
		,pf.Phone
		,pf.WatchBet
		,pf.Channel
		,pf.TVCode
		,pf.Provider
		,pf.Runner
		,pf.NoOfHDP
		,pf.MinorBettypeId
		,pf.MatchStatus
		,pf.IsMinorMatch
		,pf.IsAllowedToViewDetail
		,pf.IsSelected
	FROM #tblPreFilterMatch AS pf WITH (NOLOCK)
		LEFT JOIN #tblLeague AS league1 WITH (NOLOCK) ON pf.League = league1.[Name]
		LEFT JOIN (
		SELECT minfo.OWPMatchId
		FROM dbo.MatchInfo AS minfo WITH (NOLOCK)
			CROSS APPLY dbo.strSplit(minfo.TVCode, ',') AS f
			INNER JOIN #tblTelevision AS tv WITH (NOLOCK) ON f.[val] = REPLACE(tv.TVCode, '&', '&amp;')
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON minfo.OWPMatchId = om.OWPMatchId
		WHERE (
				om.EventDateTime BETWEEN @FilterFromDateTime
					AND @FilterToDateTime
				)
		) AS tv ON pf.OWPMatchId = tv.OWPMatchId
		LEFT JOIN (
		SELECT minfo.OWPMatchId
		FROM dbo.MatchInfo AS minfo WITH (NOLOCK)
			CROSS APPLY dbo.strSplit(minfo.Agent, ',') AS f
			INNER JOIN #tblAgent AS agent WITH (NOLOCK) ON CAST(f.[val] AS INT) = agent.Id
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON minfo.OWPMatchId = om.OWPMatchId
		WHERE (
				om.EventDateTime BETWEEN @FilterFromDateTime
					AND @FilterToDateTime
				)
		) AS agent ON pf.OWPMatchId = agent.OWPMatchId
		LEFT JOIN (
		SELECT minfo.OWPMatchId
		FROM dbo.MatchInfo AS minfo WITH (NOLOCK)
			CROSS APPLY dbo.strSplit(minfo.Provider, ',') AS f
			INNER JOIN #tblProvider AS provider WITH (NOLOCK) ON CAST(f.[val] AS INT) = provider.Id
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON minfo.OWPMatchId = om.OWPMatchId
		WHERE (
				om.EventDateTime BETWEEN @FilterFromDateTime
					AND @FilterToDateTime
				)
		) AS provider ON pf.OWPMatchId = provider.OWPMatchId
		LEFT JOIN (
		SELECT minfo.OWPMatchId
		FROM dbo.MatchInfo AS minfo WITH (NOLOCK)
			CROSS APPLY dbo.strSplit(minfo.Runner, ',') AS f
			INNER JOIN #tblRunner AS runner WITH (NOLOCK) ON CAST(f.[val] AS INT) = runner.Id
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON minfo.OWPMatchId = om.OWPMatchId
		WHERE (
				om.EventDateTime BETWEEN @FilterFromDateTime
					AND @FilterToDateTime
				)
		) AS runner ON pf.OWPMatchId = runner.OWPMatchId
		LEFT JOIN #tblMatchSetting AS setting WITH (NOLOCK) ON setting.OWPMatchId = pf.OWPMatchId
		LEFT JOIN #tblAssignment AS am WITH (NOLOCK) ON am.OWPMatchId = pf.OWPMatchId
		LEFT JOIN #tblAssignee AS assignee WITH (NOLOCK) ON am.UserId = assignee.UserId
	WHERE (
			(
				pf.EventDateTime BETWEEN @FilterFromDateTime
					AND @FilterToDateTime
				)
			AND (
				pf.KickOffTime BETWEEN ISNULL(@FilterFromTime, pf.KickOffTime)
					AND ISNULL(@FilterToTime, pf.KickOffTime)
				)
			)
		AND pf.Home LIKE '%' + ISNULL(@HomeName, '') + '%'
		AND pf.Away LIKE '%' + ISNULL(@AwayName, '') + '%'
		AND ISNULL(pf.Channel, '') LIKE '%' + ISNULL(@Channel, '') + '%'
		AND ISNULL(pf.WatchBet, '') LIKE '%' + ISNULL(@WatchBet, '') + '%'
		AND ISNULL(pf.Phone, '') LIKE '%' + ISNULL(@Phone, '') + '%'
		AND ISNULL(pf.MatchNo, '') LIKE '%' + ISNULL(@MatchNumber, '') + '%'
		AND (
			ISNULL(pf.[Round], '') LIKE '%' + ISNULL(@Remark, '') + '%'
			OR ISNULL(pf.Division, '') LIKE '%' + ISNULL(@Remark, '') + '%'
			OR ISNULL(pf.Remark, '') LIKE '%' + ISNULL(@Remark, '') + '%'
			)
		AND (
			@LeagueIds IS NULL
			OR league1.LeagueId IS NOT NULL
			)
		AND (
			@TVCodes IS NULL
			OR tv.OWPMatchId IS NOT NULL
			)
		AND (
			@AgentIds IS NULL
			OR agent.OWPMatchId IS NOT NULL
			)
		AND (
			@ProviderIds IS NULL
			OR provider.OWPMatchId IS NOT NULL
			)
		AND (
			@RunnerIds IS NULL
			OR runner.OWPMatchId IS NOT NULL
			)
		AND (
			@AssigneeIds IS NULL
			OR assignee.UserId IS NOT NULL
			)
		AND ISNULL(setting.MaxBet, 0) BETWEEN ISNULL(@FromMaxBet, ISNULL(setting.MaxBet, 0))
			AND ISNULL(@ToMaxBet, ISNULL(setting.MaxBet, 0))
		AND ISNULL(setting.Spread, 0) BETWEEN ISNULL(@FromSpread, ISNULL(setting.Spread, 0))
			AND ISNULL(@ToSpread, ISNULL(setting.Spread, 0))
		AND (
			@AssigneeLocation = - 1
			OR (
				@AssigneeLocation > - 1
				AND am.LocationCode IN (
					SELECT LCode
					FROM #tblLocationCode
					)
				)
			)
		AND (
			(
				(@IsSelected = 1)
				AND (pf.IsSelected = 1)
				)
			OR (
				(@IsSelected = 0)
				AND (pf.IsSelected = 0)
				)
			OR (
				(@IsSelected = - 1)
				AND (pf.IsSelected IN (1, 0))
				)
			)
		AND (
			@MatchStatusIds IS NULL
			OR (
				@MatchStatusIds IS NOT NULL
				AND pf.MatchStatus IN (
					SELECT MatchStatus
					FROM #tblMatchStatus
					)
				)
			)

	---------------------------------------------------------------
	--Filter full table 
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT DISTINCT m.OWPMatchId
		,m.ParentMatchId
		,m.MinorBettypeId
	FROM #tblTodayMatch AS m WITH (NOLOCK)

	--- insert parent if exist minor @Specific10Mins, @Specific15Mins
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT DISTINCT mf.ParentMatchId
		,mf.ParentMatchId
		,NULL
	FROM #tblMatchFiltered AS mf
	WHERE mf.MinorBettypeId IN (@Specific10Mins, @Specific15Mins, @FastMarket, @AllInOne)

	--- insert parent @NoOfCorners if exist minor @Specific15MinsNoOfCorners
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,m.MinorBettypeId
	FROM #tblPreFilterMatch AS m WITH (NOLOCK)
	WHERE m.MinorBettypeId = @NoOfCorners
		AND m.ParentMatchId IN (
			SELECT DISTINCT mf.ParentMatchId
			FROM #tblMatchFiltered AS mf
			WHERE mf.MinorBettypeId = @Specific15MinsNoOfCorners
			)

	--- insert parent @TotalBooking if exist minor @Specific15MinsTotalBooking
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,m.MinorBettypeId
	FROM #tblPreFilterMatch AS m WITH (NOLOCK)
	WHERE m.MinorBettypeId = @TotalBooking
		AND m.ParentMatchId IN (
			SELECT DISTINCT mf.ParentMatchId
			FROM #tblMatchFiltered AS mf
			WHERE mf.MinorBettypeId = @Specific15MinsTotalBooking
			)

	-- insert minor match @Specific10Mins, @Specific15Mins if exist parent match filtered
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,m.MinorBettypeId
	FROM #tblPreFilterMatch AS m WITH (NOLOCK)
	WHERE m.MinorBettypeId IN (@Specific10Mins, @Specific15Mins, @FastMarket, @AllInOne)
		AND m.ParentMatchId IN (
			SELECT DISTINCT mf.ParentMatchId
			FROM #tblMatchFiltered AS mf
			WHERE mf.MinorBettypeId IS NULL
			)

	-- insert minor match @Specific15MinsNoOfCorners if exist @NoOfCorners filtered
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,m.MinorBettypeId
	FROM #tblPreFilterMatch AS m WITH (NOLOCK)
	WHERE m.MinorBettypeId = @Specific15MinsNoOfCorners
		AND m.ParentMatchId IN (
			SELECT DISTINCT mf.ParentMatchId
			FROM #tblMatchFiltered AS mf
			WHERE mf.MinorBettypeId = @NoOfCorners
			)

	-- insert minor match @Specific15MinsTotalBooking if exist @TotalBooking filtered
	INSERT INTO #tblMatchFiltered (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,m.MinorBettypeId
	FROM #tblPreFilterMatch AS m WITH (NOLOCK)
	WHERE m.MinorBettypeId = @Specific15MinsTotalBooking
		AND m.ParentMatchId IN (
			SELECT DISTINCT mf.ParentMatchId
			FROM #tblMatchFiltered AS mf
			WHERE mf.MinorBettypeId = @TotalBooking
			)

	-- Distinct data from #tblMatchFiltered
	INSERT INTO #tblMatchFilteredDistinct (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT DISTINCT mf.OWPMatchId
		,mf.ParentMatchId
		,mf.MinorBettypeId
	FROM #tblMatchFiltered AS mf WITH (NOLOCK)

	-- get match id
	INSERT INTO #tblMatchId (
		RowIndex
		,OWPMatchId
		,ParentMatchId
		)
	SELECT ROW_NUMBER() OVER (
			ORDER BY m.EventDate
				,m.KickOffTime
				,CASE 
					WHEN ISNULL(m.MatchNo, '') = '' THEN 1
					ELSE 0
					END
				,m.MatchNo
			)
		,m.OWPMatchId
		,m.ParentMatchId
	FROM #tblPreFilterMatch AS m WITH (NOLOCK)
		LEFT JOIN #tblMatchFilteredDistinct AS mf WITH (NOLOCK) ON m.OWPMatchId = mf.OWPMatchId
	WHERE (
			m.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
			OR m.MinorBettypeId IS NULL
			)
		AND mf.OWPMatchId IS NOT NULL

	-- Final Id for paging
	IF @PageIndex IS NOT NULL
		AND @ItemsPerPage IS NOT NULL
	BEGIN
		INSERT INTO #tblFinalMatchId (
			OWPMatchId
			,ParentMatchId
			,RowIndex
			,PageIndex
			,IsDisplay
			)
		SELECT OWPMatchId
			,ParentMatchId
			,RowIndex
			,CAST((RowIndex - 1) / @ItemsPerPage AS INT) + 1
			,CASE 
				WHEN (
						RowIndex BETWEEN ((@PageIndex - 1) * @ItemsPerPage + 1)
							AND (@PageIndex * @ItemsPerPage)
						) THEN 1
				ELSE 0
				END
		FROM #tblMatchId WITH (NOLOCK)
			--WHERE RowIndex BETWEEN ((@PageIndex - 1) * @ItemsPerPage + 1)
			--		AND (@PageIndex * @ItemsPerPage)
	END
	ELSE
	BEGIN
		INSERT INTO #tblFinalMatchId (
			OWPMatchId
			,ParentMatchId
			,RowIndex
			,PageIndex
			,IsDisplay
			)
		SELECT OWPMatchId
			,ParentMatchId
			,RowIndex
			,1
			,1
		FROM #tblMatchId WITH (NOLOCK)
	END

	-- Final Id include MinorMatch to get full data of assignment, maxbet, spread....
	INSERT INTO #tblFinalMatchIdIncludeMinorMatch (
		OWPMatchId
		,ParentMatchId
		)
	SELECT mf.OWPMatchId
		,mf.ParentMatchId
	FROM #tblMatchFilteredDistinct AS mf WITH (NOLOCK)
	WHERE EXISTS (
			SELECT 1
			FROM #tblFinalMatchId AS fmi WITH (NOLOCK)
			WHERE fmi.ParentMatchId = mf.ParentMatchId
			)

	-- SELECT match info
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
		,m.MatchStatus
		,m.MinorBettypeId
		,0 AS HasNewNote
		,notes.Notes
		,m.IsAllowedToViewDetail
		,mid.RowIndex
		,mid.PageIndex
		,mid.IsDisplay
	FROM #tblPreFilterMatch AS m WITH (NOLOCK)
		INNER JOIN #tblFinalMatchId AS mid WITH (NOLOCK) ON mid.OWPMatchId = m.OWPMatchId
		LEFT JOIN #tblMatchNote AS notes WITH (NOLOCK) ON notes.OWPMatchId = m.OWPMatchId
	ORDER BY m.EventDate
		,m.KickOffTime
		,CASE 
			WHEN ISNULL(m.MatchNo, '') = '' THEN 1
			ELSE 0
			END
		,m.MatchNo

	-- select assignment 
	SELECT am.OWPMatchId
		,am.ParentMatchId
		,BettypeId
		,am.MinorBettypeId
		,UserId
		,IsCurrentUser
		,Username
		,Nickname
		,Skype
		,Extension
		,Phone
		,AssignmentType
		,AssignmentNote
	FROM #tblAssignment AS am WITH (NOLOCK)
		INNER JOIN #tblFinalMatchIdIncludeMinorMatch AS mid WITH (NOLOCK) ON am.OWPMatchId = mid.OWPMatchId
	ORDER BY am.AssignmentId ASC

	--am.ParentMatchId ASC
	--	,am.AssignmentId ASC
	-- select maxbet, spread
	SELECT ms.OWPMatchId
		,ms.ParentMatchId
		,BettypeId
		,ms.MinorBettypeId
		,Maxbet
		,Spread
	FROM #tblMatchSetting AS ms WITH (NOLOCK)
		INNER JOIN #tblFinalMatchIdIncludeMinorMatch AS mid WITH (NOLOCK) ON ms.OWPMatchId = mid.OWPMatchId

	-- select match note
	SELECT mn.OWPMatchId
		,mn.Note
	--,1 AS IsViewed
	FROM dbo.MatchNote AS mn WITH (NOLOCK)
		INNER JOIN #tblPreFilterMatch AS ml WITH (NOLOCK) ON mn.OWPMatchId = ml.OWPMatchId
		INNER JOIN #tblFinalMatchIdIncludeMinorMatch AS mid WITH (NOLOCK) ON mn.OWPMatchId = mid.OWPMatchId
	WHERE ml.MinorBettypeId NOT IN (@Specific10Mins, @Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
		OR ml.MinorBettypeId IS NULL
	ORDER BY mn.CreatedDate DESC

	-- select TV code & color
	SELECT ml.OWPMatchId
		,tv.TVCode
		,tv.Color
	FROM #tblPreFilterMatch AS ml WITH (NOLOCK)
		INNER JOIN #tblFinalMatchIdIncludeMinorMatch AS mid WITH (NOLOCK) ON ml.OWPMatchId = mid.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON ml.OWPMatchId = mi.OWPMatchId
		CROSS APPLY dbo.fnc_SplitStrings(mi.TVCode, ',') AS data
		INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON RTRIM(LTRIM(data.val)) = tv.TVId
	ORDER BY tv.TVId

	-- total item
	SELECT @TotalItem = COUNT(1)
	FROM #tblMatchId

	DROP TABLE #tblLeague

	DROP TABLE #tblAssignee

	DROP TABLE #tblAgent

	DROP TABLE #tblProvider

	DROP TABLE #tblRunner

	DROP TABLE #tblTelevision

	DROP TABLE #tblLocationCode

	DROP TABLE #tblMatchNote

	DROP TABLE #tblMatchId

	DROP TABLE #tblFinalMatchId

	DROP TABLE #tblAssignment

	DROP TABLE #tblMatchSetting

	DROP TABLE #tblParentMatchSetting

	DROP TABLE #tblMatchStatus

	DROP TABLE #tblMatchFiltered

	DROP TABLE #tblMatchFilteredDistinct

	DROP TABLE #tblPreFilterMatch

	DROP TABLE #tblTodayMatch

	DROP TABLE #tblFinalMatchIdIncludeMinorMatch
END