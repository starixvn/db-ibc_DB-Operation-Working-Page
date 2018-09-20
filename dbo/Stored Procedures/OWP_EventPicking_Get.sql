CREATE PROCEDURE [dbo].[OWP_EventPicking_Get] @Date DATE
	,@LeagueIds NVARCHAR(MAX) = NULL
	,@FromTime TIME = NULL
	,@ToTime TIME = NULL
	,@FromMaxBet MONEY = NULL
	,@ToMaxBet MONEY = NULL
	,@FromSpread SMALLMONEY = NULL
	,@ToSpread SMALLMONEY = NULL
	,@PageIndex INT = NULL
	,@ItemsPerPage INT = NULL
	,@TotalItem INT = NULL OUT
AS
/*
Created: 20161220@Tim.Trinh
Task : get event picking
DB: bodb_OWP

Revisions:
    20170411@Alvin.Nguyen: Don't return minor match
    Param's Explanation:
        • @LeageIds: '1,2'
    20171218@Raymond.Le: Show match is live
    20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Tomorrow DATE = DATEADD(DAY, 1, @Date)
	DECLARE @FromDate DATETIME = DATEADD(HOUR, 12, CAST(@Date AS DATETIME))
		,@ToDate DATETIME = DATEADD(HOUR, 12, CAST(@Tomorrow AS DATETIME))
	DECLARE @Handicap TINYINT = 1
		,@OverUnder TINYINT = 3

	CREATE TABLE #tblLeague (
		LeagueId INT
		,[Name] NVARCHAR(2000)
		)

	CREATE TABLE #tblMatchId (
		RowIndex INT
		,OWPMatchId INT
		)

	CREATE TABLE #tblFinalMatchId (OWPMatchId INT)

	CREATE TABLE #tblMatch (
		OWPMatchId INT
		,EventDate DATE
		,KickOffTime TIME
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,OutSide NVARCHAR(2000)
		,[Round] NVARCHAR(2000)
		,ExtraTimeRemark NVARCHAR(100)
		,Venue NVARCHAR(100)
		,LocalTV NVARCHAR(100)
		,LiveTV NVARCHAR(100)
		,Website NVARCHAR(1000)
		,IsSelected BIT
		)

	CREATE TABLE #tblFinalMatch (
		OWPMatchId INT
		,EventDate DATE
		,KickOffTime TIME
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,OutSide NVARCHAR(2000)
		,[Round] NVARCHAR(2000)
		,ExtraTimeRemark NVARCHAR(100)
		,Venue NVARCHAR(100)
		,LocalTV NVARCHAR(100)
		,LiveTV NVARCHAR(100)
		,Website NVARCHAR(1000)
		,IsSelected BIT
		)

	CREATE TABLE #tblMatchSetting (
		OWPMatchId INT
		,LeagueId INT
		,Bettype INT
		,MaxBet MONEY
		,Spread SMALLMONEY
		,IsMatchSetting BIT
		)

	IF ISNULL(@LeagueIds, '') <> ''
	BEGIN
		INSERT INTO #tblLeague (
			LeagueId
			,[Name]
			)
		SELECT DISTINCT league.OWPLeagueId
			,league.OWPLeagueName
		FROM dbo.strSplit(@LeagueIds, ',') AS lid
			INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON CAST(lid.val AS INT) = league.OWPLeagueId
	END

	-- get match
	INSERT INTO #tblMatch (
		OWPMatchId
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,OutSide
		,[Round]
		,ExtraTimeRemark
		,Venue
		,LocalTV
		,LiveTV
		,Website
		,IsSelected
		)
	SELECT DISTINCT m.OWPMatchId
		,m.EventDate
		,m.KickOffTime
		,league.OWPLeagueName
		,home.OWPTeamName
		,away.OWPTeamName
		,info.OutSide
		,info.[Round]
		,info.ExtraTimeRemark
		,info.Venue
		,info.LocalTV
		,info.LiveTV
		,info.Website
		,info.IsSelected
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON info.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = m.OWPHomeId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = m.OWPAwayId
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON league.OWPLeagueId = m.OWPLeagueId
		LEFT JOIN #tblLeague AS owpleague WITH (NOLOCK) ON league.OWPLeagueId = owpleague.LeagueId
		LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON m.OWPMatchId = minor.MinorMatchId
	WHERE (
			(
				m.EventDate = @Date
				AND m.KickOffTime >= '12:00:00'
				)
			OR (
				m.EventDate = @Tomorrow
				AND m.KickOffTime < '12:00:00'
				)
			)
		AND info.MatchStatus = 'Live'
		AND (
			ISNULL(@LeagueIds, '') = ''
			OR owpleague.LeagueId IS NOT NULL
			)
		AND minor.MinorMatchId IS NULL

	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,Bettype
		,MaxBet
		,Spread
		,IsMatchSetting
		)
	SELECT ms.OWPMatchId
		,ms.Bettype
		,ms.Maxbet
		,ms.Spread
		,1
	FROM #tblMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
	WHERE ms.Bettype IN (@Handicap, @OverUnder)

	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,LeagueId
		,Bettype
		,Maxbet
		,Spread
		,IsMatchSetting
		)
	SELECT OWPMatchId
		,OWPLeagueId
		,tb2.Bettype
		,ls.Maxbet
		,ls1.Spread
		,0
	FROM (
		SELECT OWPMatchId
			,OWPLeagueId
			,Bettype
			,POWER(2 * wd, 1) + POWER(2 * wk, 2) + POWER(2 * tv, 3) + POWER(2 * ukrb, 4) AS MaxBetOption
			,POWER(2 * tv, 3) + POWER(2 * ukrb, 4) AS SpreadOption
		FROM (
			SELECT OWPMatchId
				,OWPLeagueId
				,Bettype
				,CASE ISNULL(DATEPART(dw, OnDate), - 1)
					WHEN 1 THEN 0
					WHEN 2 THEN 1
					WHEN 3 THEN 1
					WHEN 4 THEN 1
					WHEN 5 THEN 1
					WHEN 6 THEN 1
					WHEN 7 THEN 0
					END AS wd
				,CASE ISNULL(DATEPART(dw, OnDate), - 1)
					WHEN 1 THEN 1
					WHEN 2 THEN 0
					WHEN 3 THEN 0
					WHEN 4 THEN 0
					WHEN 5 THEN 0
					WHEN 6 THEN 0
					WHEN 7 THEN 1
					END AS wk
				,tv
				,CASE 
					WHEN tv = 1
						AND ukrb = 1 THEN 0
					ELSE ukrb
					END AS ukrb
			FROM (
				SELECT m.OWPMatchId
					,m.OWPLeagueId
					,ls.Bettype
					,DATEADD(dd, DATEDIFF(dd, 0, m.EventDate), CAST(m.KickOffTime AS DATETIME)) AS OnDate
					,(CASE 
						WHEN NULLIF(mif.TVCode, '') IS NOT NULL THEN 1
						ELSE 0 END
						) AS tv
					,(CASE 
						WHEN NULLIF(mif.Channel, '') IS NOT NULL
							OR NULLIF(mif.Provider, '') IS NOT NULL THEN 1
						ELSE 0 END
						) AS ukrb
				FROM dbo.OWPMatch AS m WITH (NOLOCK)
					INNER JOIN #tblMatch AS ma WITH (NOLOCK) ON m.OWPMatchId = ma.OWPMatchId
					INNER JOIN dbo.MatchInfo AS mif WITH (NOLOCK) ON m.OWPMatchId = mif.OWPMatchId
					INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON m.OWPLeagueId = ls.LeagueId
				WHERE m.OWPMatchId NOT IN (
						SELECT OWPMatchId
						FROM #tblMatchSetting WITH (NOLOCK)
						)
					AND ls.Bettype IN (@Handicap, @OverUnder)
				GROUP BY m.OWPMatchId
					,m.OWPleagueid
					,ls.Bettype
					,m.EventDate
					,m.KickOffTime
					,mif.TVCode
					,mif.Channel
					,mif.Provider
				) AS tb
			) AS tb1
		) AS tb2
		LEFT JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON ls.LeagueId = tb2.OWPLeagueId
		AND ls.OptionsId = tb2.MaxBetOption
		AND ls.Bettype = tb2.Bettype
		LEFT JOIN dbo.LeagueSetting AS ls1 WITH (NOLOCK) ON ls1.LeagueId = tb2.OWPLeagueId
		AND ls1.OptionsId = tb2.SpreadOption
		AND ls1.Bettype = tb2.Bettype

	INSERT INTO #tblFinalMatch (
		OWPMatchId
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,OutSide
		,[Round]
		,ExtraTimeRemark
		,Venue
		,LocalTV
		,LiveTV
		,Website
		,IsSelected
		)
	SELECT DISTINCT m.OWPMatchId
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,OutSide
		,[Round]
		,ExtraTimeRemark
		,Venue
		,LocalTV
		,LiveTV
		,Website
		,IsSelected
	FROM #tblMatch AS m WITH (NOLOCK)
		LEFT JOIN #tblMatchSetting AS ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
	WHERE (
			@FromMaxBet IS NULL
			OR @ToMaxBet IS NULL
			OR (
				ms.Bettype IN (@Handicap) -- HDP
				AND ms.Maxbet BETWEEN @FromMaxBet
					AND @ToMaxBet
				)
			)
		AND (
			@FromSpread IS NULL
			OR @ToSpread IS NULL
			OR (
				ms.Bettype IN (@Handicap, @OverUnder)
				AND ms.Spread BETWEEN @FromSpread
					AND @ToSpread
				)
			)
		AND m.KickOffTime BETWEEN ISNULL(@FromTime, m.KickOffTime)
			AND ISNULL(@ToTime, m.KickOffTime)

	INSERT INTO #tblMatchId (
		RowIndex
		,OWPMatchId
		)
	SELECT DISTINCT ROW_NUMBER() OVER (
			ORDER BY EventDate
				,KickOffTime
			)
		,OWPMatchId
	FROM #tblFinalMatch WITH (NOLOCK)

	IF @PageIndex IS NOT NULL
		AND @ItemsPerPage IS NOT NULL
	BEGIN
		INSERT INTO #tblFinalMatchId (OWPMatchId)
		SELECT OWPMatchId
		FROM #tblMatchId WITH (NOLOCK)
		WHERE RowIndex BETWEEN ((@PageIndex - 1) * @ItemsPerPage + 1)
				AND (@PageIndex * @ItemsPerPage)
	END
	ELSE
	BEGIN
		INSERT INTO #tblFinalMatchId (OWPMatchId)
		SELECT OWPMatchId
		FROM #tblMatchId WITH (NOLOCK)
	END

	SELECT m.OWPMatchId
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,OutSide
		,[Round]
		,ExtraTimeRemark
		,Venue
		,LocalTV
		,LiveTV
		,Website
		,IsSelected
	FROM #tblFinalMatch AS m WITH (NOLOCK)
		INNER JOIN #tblFinalMatchId AS mid WITH (NOLOCK) ON m.OWPMatchId = mid.OWPMatchId
	ORDER BY EventDate
		,KickOffTime

	SELECT m.OWPMatchId
		,ms.Bettype
		,ms.Maxbet
		,ms.Spread
	FROM #tblFinalMatch AS m WITH (NOLOCK)
		INNER JOIN #tblFinalMatchId AS mid WITH (NOLOCK) ON m.OWPMatchId = mid.OWPMatchId
		INNER JOIN #tblMatchSetting AS ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
	WHERE ms.Bettype IN (@Handicap, @OverUnder)

	SELECT m.OWPMatchId
		,mn.Note
	FROM #tblFinalMatch AS m WITH (NOLOCK)
		INNER JOIN #tblFinalMatchId AS mid WITH (NOLOCK) ON m.OWPMatchId = mid.OWPMatchId
		INNER JOIN dbo.MatchNote AS mn WITH (NOLOCK) ON m.OWPMatchId = mn.OWPMatchId

	-- total item
	SELECT @TotalItem = COUNT(1)
	FROM #tblMatchId

	DROP TABLE #tblLeague

	DROP TABLE #tblMatch

	DROP TABLE #tblMatchId

	DROP TABLE #tblFinalMatchId

	DROP TABLE #tblFinalMatch

	DROP TABLE #tblMatchSetting
END