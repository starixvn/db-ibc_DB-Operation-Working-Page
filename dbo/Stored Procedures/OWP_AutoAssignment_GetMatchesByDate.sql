
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetMatchesByDate] @EventDate DATE
AS
/*
Created: 20181221@Raymond.Le
Task : Get match list by date for auto assignment
DB: bodb_OWP

Revisions:
	20181221@Raymond.Le: Initial SP - [Redmine: #106196]
	20190531@Leo.Vo: Refactor SP [Redmine: #114442]
	20190618@Leo.Vo: Add MatchSolo & filter only Live match [Redmine: #114614]
	20190819@Leo.Vo: Update rule Auto Assignment [Redmine: #118861]
	20190819@Leo.Vo: Update rule Auto Assignment [Redmine: #118861]
	20190512@Kane.Le: Update ExtraTime, Venue [Redmine: #124940]
	20200704@Carlos.Nguyen: Update Id provider IPSD, RB2, RTS, Other, BET [Redmine: #131928]
	20200421@Lita.Tang: Remove Other Provider  [Redmine: #131928]
	20200421@Lita.Tang: Remove Matches do not have Provider [Redmine: #131928]
*/
BEGIN
	SET NOCOUNT ON
	
	/* Declare variable*/
	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@BettypeHDP INT = 1
		,@Provider_IPSD INT = 1
		,@Provider_RB2 INT = 2
		,@Provider_RTS INT = 3
		,@Provider_Other INT = 0
		,@Provider_BET INT = 4


	CREATE TABLE #tblMatch (
		OWPMatchId INT
		,ParentMatchId INT
		,MinorBettypeId INT
		,LeagueId INT
		,IsMajorLeague BIT
		,HasTV BIT
		,Maxbet MONEY
		)

	CREATE TABLE #tblProvider (
		OWPMatchId INT
		,IsIPSD BIT
		,IsRB2 BIT
		,IsRTS BIT
		,IsBET BIT
		)

	CREATE TABLE #tblMatchProvider (
		OWPMatchId INT
		,Provider INT
		)

	CREATE TABLE #tblSchedulingProvider (
		OWPMatchId INT
		,Provider VARCHAR(10)
		)

	INSERT INTO #tblMatch (
		OWPMatchId
		,ParentMatchId
		,MinorBettypeId
		)
	SELECT om.OWPMatchId
		,CASE 
			WHEN mm.MinorBettypeId IS NULL THEN om.OWPMatchId
			ELSE mm.ParentMatchId
			END AS MatchId
		,mm.MinorBettypeId
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON om.OWPMatchId = mm.MinorMatchId
	WHERE mi.IsSelected = 1
		AND om.EventDateTime BETWEEN @FromDate
			AND @ToDate
		AND (
			mm.MinorBettypeId NOT IN (@FastMarket, @AllInOne)
			OR mm.MinorBettypeId IS NULL
			)

	-- update info from main match
	UPDATE m
	SET m.LeagueId = om.OWPLeagueId
		,m.IsMajorLeague = CASE WHEN l.CategoryId = 1 THEN 1 ELSE 0 END
		,m.HasTV = CASE 
			WHEN EXISTS (
					SELECT 1
					FROM dbo.MatchTelevision WITH (NOLOCK)
					WHERE OWPMatchId = m.ParentMatchId
					) THEN 1
			ELSE 0
			END
		,m.Maxbet = ms.Maxbet
	FROM #tblMatch AS m
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.ParentMatchId = om.OWPMatchId
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON om.OWPLeagueId = l.OWPLeagueId
		LEFT JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON m.ParentMatchId = ms.OWPMatchId
		AND ms.Bettype = @BettypeHDP

	
	-- update maxbet from MaxbetManagement setting
	UPDATE m
	SET m.Maxbet = dbo.OWP_MaxBetGet(m.ParentMatchId, m.LeagueId, @BettypeHDP)
	FROM #tblMatch AS m
	WHERE m.Maxbet IS NULL

	INSERT INTO #tblProvider (
		OWPMatchId
		,IsIPSD
		,IsRB2
		,IsRTS
		,IsBET
		)
	SELECT m.OWPMatchId
		,MAX(CASE 
				WHEN p.ProviderName LIKE '%ipsd%' THEN 1
				ELSE 0
				END)
		,MAX(CASE 
				WHEN p.ProviderName LIKE '%rb2%' THEN 1
				ELSE 0
				END)
		,MAX(CASE 
				WHEN p.ProviderName LIKE '%rts%' THEN 1
				ELSE 0
				END)
		,MAX(CASE 
				WHEN p.ProviderName LIKE '%bet%' THEN 1
				ELSE 0
				END)
	FROM #tblMatch AS m
		INNER JOIN dbo.MatchProvider AS ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
		INNER JOIN dbo.Provider AS p WITH (NOLOCK) ON ms.ProviderId = p.ProviderId
	GROUP BY m.OWPMatchId
	
	
	INSERT INTO #tblMatchProvider (
		OWPMatchId
		,Provider
		)
	SELECT OWPMatchId
		,Provider
	FROM (
		SELECT p.OWPMatchId AS OWPMatchId
			,CASE 
				WHEN p.IsIPSD = 1 THEN @Provider_IPSD
				ELSE NULL
				END AS Provider_IPSD
			,CASE 
				WHEN p.IsRB2 = 1 THEN @Provider_RB2
				ELSE NULL
				END AS Provider_RB2
			,CASE 
				WHEN p.IsRTS = 1 THEN @Provider_RTS
				ELSE NULL
				END AS Provider_RTS
			,CASE 
				WHEN p.IsBET = 1  THEN @Provider_BET
				ELSE NULL
				END AS Provider_BET
		FROM #tblProvider AS p
		) p
	UNPIVOT(Provider FOR ProviderType IN (Provider_IPSD, Provider_RB2, Provider_RTS, Provider_BET)) AS unpvt;

	INSERT INTO #tblSchedulingProvider (
		OWPMatchId
		,Provider
		)
	SELECT t.OWPMatchId
		,STUFF((
				SELECT ',' + CAST(o.Provider AS VARCHAR(10))
				FROM #tblMatchProvider AS o
				WHERE o.OWPMatchId = t.OWPMatchId
				FOR XML PATH('')
				), 1, 1, '') AS Provider
	FROM #tblMatchProvider AS t
	GROUP BY t.OWPMatchId

	-- return match list
	-- Addition HasReporter/HasChannel
	SELECT m.ParentMatchId AS MatchId
		,om.EventDateTime AS KOTime
		,om.OtherTime
		,ISNULL(m.MinorBettypeId, 0) AS SchedulingBettypeId
		,m.HasTV
		,m.Maxbet
		,mi.IsSoloMatch
		,m.IsMajorLeague		
		,ISNULL(p.Provider, CASE 
				WHEN EXISTS (
						SELECT 1
						FROM dbo.MatchProvider AS mp WITH (NOLOCK)
						WHERE mp.OWPMatchId = m.OWPMatchId
						) THEN CAST(@Provider_Other AS VARCHAR(10))
				ELSE ''
				END) AS Provider
		,CASE 
				WHEN LOWER(mi.Remark) LIKE '%et%' OR LOWER(mi.Remark) LIKE '%pk%' THEN 1
				ELSE 0
				END AS ExtraTime				 
		,mi.Venue AS Venue
		,CASE 
			WHEN owpl.OWPLeagueId IS NOT NULL THEN 1
			ELSE 0
		END AS IsFantasy
		,CASE
			WHEN LEN(REPLACE(mi.Phone, ' ', ''))>10 THEN 1
			ELSE 0
		END AS HasReporter
		,CASE
			WHEN LEN(LTRIM(RTRIM(mi.Channel)))>0 THEN 1
			ELSE 0
		END AS HasChannel
	FROM #tblMatch AS m
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.ParentMatchId = om.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.ParentMatchId = mi.OWPMatchId
		INNER JOIN #tblSchedulingProvider AS p ON m.OWPMatchId = p.OWPMatchId
		LEFT JOIN OWPLeague AS owpl WITH(NOLOCK) ON om.OWPLeagueId=owpl.OWPLeagueId AND owpl.OWPLeagueName LIKE '%FANTASY%'
	WHERE m.Maxbet IS NOT NULL
		AND mi.MatchStatus = 'Live'

	DROP TABLE #tblMatch

	DROP TABLE #tblProvider

	DROP TABLE #tblMatchProvider

	DROP TABLE #tblSchedulingProvider
	
END
