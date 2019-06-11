
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
		MatchId INT
		,--id of main match
		MinorBettypeId INT
		,KOTime DATETIME
		,LeagueId INT
		,HasTV BIT
		,Maxbet MONEY
		)

	INSERT INTO #tblMatch (
		MatchId
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
	SET m.KOTime = om.EventDateTime
		,m.LeagueId = om.OWPLeagueId
		,m.HasTV = CASE 
			WHEN EXISTS (
					SELECT 1
					FROM dbo.MatchTelevision WITH (NOLOCK)
					WHERE OWPMatchId = mi.OWPMatchId
					) THEN 1
			ELSE 0
			END
		,m.Maxbet = ms.Maxbet
	FROM #tblMatch AS m
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.MatchId = om.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.MatchId = mi.OWPMatchId
		LEFT JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON m.MatchId = ms.OWPMatchId
		AND ms.Bettype = @BettypeHDP

	-- update maxbet from MaxbetManagement setting
	UPDATE m
	SET m.Maxbet = dbo.OWP_MaxBetGet(m.MatchId, m.LeagueId, @BettypeHDP)
	FROM #tblMatch AS m
	WHERE m.Maxbet IS NULL

	-- return match list
	SELECT m.MatchId
		,m.KOTime
		,ISNULL(bt.SchedulingBettypeId, 0) AS SchedulingBettypeId
		,m.HasTV
		,m.Maxbet
	FROM #tblMatch AS m
		LEFT JOIN dbo.AutoAssignmentBettype AS bt ON m.MinorBettypeId = bt.MinorBettypeId
	WHERE m.Maxbet IS NOT NULL

	DROP TABLE #tblMatch
END