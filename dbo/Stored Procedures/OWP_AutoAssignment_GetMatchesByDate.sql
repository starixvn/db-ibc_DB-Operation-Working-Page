
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
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@BettypeHDP INT = 1

	CREATE TABLE #tblMatch (
		ParentMatchId INT
		,MinorBettypeId INT
		,LeagueId INT
		,HasTV BIT
		,Maxbet MONEY
		)

	INSERT INTO #tblMatch (
		ParentMatchId
		,MinorBettypeId
		)
	SELECT CASE 
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
			mm.MinorBettypeId NOT IN (@Specific15Mins, @Specific10Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
			OR mm.MinorBettypeId IS NULL
			)

	-- update info from main match
	UPDATE m
	SET m.LeagueId = om.OWPLeagueId
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
		LEFT JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON m.ParentMatchId = ms.OWPMatchId
		AND ms.Bettype = @BettypeHDP

	-- update maxbet from MaxbetManagement setting
	UPDATE m
	SET m.Maxbet = dbo.OWP_MaxBetGet(m.ParentMatchId, m.LeagueId, @BettypeHDP)
	FROM #tblMatch AS m
	WHERE m.Maxbet IS NULL

	-- return match list
	SELECT m.ParentMatchId AS MatchId
		,om.EventDateTime AS KOTime
		,ISNULL(bt.SchedulingBettypeId, 0) AS SchedulingBettypeId
		,m.HasTV
		,m.Maxbet
		,mi.IsSoloMatch
	FROM #tblMatch AS m
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.ParentMatchId = om.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.ParentMatchId = mi.OWPMatchId
		LEFT JOIN dbo.AutoAssignmentBettype AS bt ON m.MinorBettypeId = bt.MinorBettypeId
	WHERE m.Maxbet IS NOT NULL AND mi.MatchStatus = 'Live'

	DROP TABLE #tblMatch
END