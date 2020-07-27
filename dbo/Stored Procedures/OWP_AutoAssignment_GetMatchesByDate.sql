
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
	20200407@Carlos.Nguyen: Update Id provider IPSD, RB2, RTS, Other, BET [Redmine: #133428]
	20200421@Lita.Tang: Remove Other Provider  [Redmine: #133428]
	20200421@Lita.Tang: Remove Matches do not have Provider [Redmine: #133428]
	20200427@Carlos.Nguyen: Order Provider [Redmine: #133428]
	20200520@Tyler.Dang: Update RequireChinese rule [Redmine: #133428]
	20200716@Carlos.Nguyen: Auto re-assign for LA - [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON
	
	/* Declare variable*/
	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@BettypeHDP INT = 1

	CREATE TABLE #tblMatch (
		OWPMatchId INT
		,ParentMatchId INT
		,MinorBettypeId INT
		,LeagueId INT
		,IsMajorLeague BIT
		,HasTV BIT
		,Maxbet MONEY
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
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId AND mi.MatchStatus= 'Live'
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

	-- Addition HasReporter/HasChannel
	SELECT m.ParentMatchId AS MatchId
		,om.EventDateTime AS KOTime
		,om.OtherTime
		,ISNULL(m.MinorBettypeId, 0) AS SchedulingBettypeId
		,m.HasTV
		,m.Maxbet
		,mi.IsSoloMatch
		,m.IsMajorLeague		
		,p.ProviderName AS Provider
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
		,CASE
			WHEN CHARINDEX('Chinese', mi.Phone) > 0 OR CHARINDEX('C Only', mi.Phone) > 0 THEN 1
			ELSE 0
		END AS RequireChinese
	FROM #tblMatch AS m
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.ParentMatchId = om.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.ParentMatchId = mi.OWPMatchId
		INNER JOIN dbo.MatchProvider AS mp WITH (NOLOCK) ON m.OWPMatchId = mp.OWPMatchId
		INNER JOIN dbo.Provider AS p WITH (NOLOCK) ON p.ProviderId=mp.ProviderId
		LEFT JOIN OWPLeague AS owpl WITH(NOLOCK) ON om.OWPLeagueId=owpl.OWPLeagueId AND owpl.OWPLeagueName LIKE '%FANTASY%'
	WHERE m.Maxbet IS NOT NULL
		AND mi.MatchStatus = 'Live'
	DROP TABLE #tblMatch
END
