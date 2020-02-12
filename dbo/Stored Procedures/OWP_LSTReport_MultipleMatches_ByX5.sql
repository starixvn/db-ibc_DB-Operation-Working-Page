
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LSTReport_MultipleMatches_ByX5] @FromDate DATETIME = '2020-02-10'
	,@ToDate DATETIME = '2020-02-10'
AS
/*    
 Created: 20200205@Kane.Le
 Task : Caculate report MultipleMatches of LST Report
 DB: bodb_OWP    
    
 Revisions:
	20200205@Kane.Le: Initial SP - [Redmine: #124448]	 
*/
BEGIN
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF;
	SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00')
	SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, - 1, @ToDate), '11:59:59')

	DECLARE @HandicapHDP INT = 1
		,@OverUnderOU INT = 3
		,@1H_HandicapHDP INT = 7
		,@1H_OverUnder INT = 8
		,@1X2 INT = 5
		,@1H_1X2 INT = 15
		,@LA_Bettype INT = - 1002
		,@MinorBettype_NextCorner INT = - 4
		,@MinorBettype_NextBooking INT = - 7
		,@MinorBettype_15Mins INT = - 1
		,@MinorBettype_10Mins INT = - 2
		,@LeagueCategoryId_MJ INT = 1
		,@LeagueCategoryId_MIN_1 INT = 2
		,@LeagueCategoryId_MIN_2 INT = 3
		,@LeagueCategoryId_MIN_3 INT = 4

	IF OBJECT_ID('tempdb..#tmpTraders') IS NOT NULL
	BEGIN
		DROP TABLE #tmpTraders;
	END;

	CREATE TABLE #tmpTraders (UserId INT NOT NULL PRIMARY KEY);

	IF OBJECT_ID('tempdb..#tmpMatches') IS NOT NULL
	BEGIN
		DROP TABLE #tmpMatches;
	END;

	CREATE TABLE #tmpMatches (
		CustId INT NOT NULL
		,MatchId INT NOT NULL
		,EventDate DATETIME
		,KickOffTime TIME
		,OrderedIndex INT
		);

	IF OBJECT_ID('tempdb..#tmpMatchesInfoMultiple') IS NOT NULL
	BEGIN
		DROP TABLE #tmpMatchesInfoMultiple;
	END;

	CREATE TABLE #tmpMatchesInfoMultiple (
		UserId INT NOT NULL
		,MatchGroup INT
		,MatchId INT NOT NULL
		,KickOffTime TIME
		);

	IF OBJECT_ID('tempdb..#tmpTempAssignmentReportMainMatch') IS NOT NULL
	BEGIN
		DROP TABLE #tmpTempAssignmentReportMainMatch;
	END;

	CREATE TABLE #tmpTempAssignmentReportMainMatch (
		Id INT IDENTITY
		,UserId INT
		,Username NVARCHAR(50)
		,OWPMatchId INT
		,Bettype INT
		,EventDate DATETIME
		,KickOffTime TIME
		,IsSoloMatch BIT
		,LeagueId INT
		,LeagueName NVARCHAR(500)
		,LeagueCategoryId INT
		,MinorBettypeId INT
		)

	INSERT INTO #tmpTempAssignmentReportMainMatch (
		UserId
		,Username
		,OWPMatchId
		,Bettype
		,EventDate
		,KickOffTime
		,IsSoloMatch
		,LeagueId
		,LeagueName
		,LeagueCategoryId
		,MinorBettypeId
		)
	SELECT u.UserId
		,u.Username
		,ma.OWPMatchId
		,ass.Bettype
		,ma.EventDateTime
		,ma.KickOffTime
		,mi.IsSoloMatch
		,ma.OWPLeagueId
		,la.OWPLeagueName
		,la.CategoryId
		,mn.MinorBettypeId
	FROM dbo.[User] u WITH (NOLOCK)
	LEFT JOIN dbo.Assignment ass WITH (NOLOCK) ON u.UserId = ass.UserId
	LEFT JOIN dbo.OWPMatch ma WITH (NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
	LEFT JOIN dbo.OWPLeague la WITH (NOLOCK) ON la.OWPLeagueId = ma.OWPLeagueId
	LEFT JOIN dbo.MatchInfo mi WITH (NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
	LEFT OUTER JOIN dbo.MinorMatch mn WITH (NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
	WHERE mn.MinorMatchId IS NULL
		AND ass.AssignmentType = 1
		AND ma.EventDateTime BETWEEN @FromDate
			AND @ToDate
		AND ass.Bettype NOT IN (@LA_Bettype)
		AND mi.MatchStatus NOT IN (
			'Cancel'
			,'Postponed'
			,'Suspended'
			)

	INSERT INTO #tmpTraders (UserId)
	SELECT DISTINCT t.UserId
	FROM #tmpTempAssignmentReportMainMatch AS t WITH (NOLOCK);

	DECLARE @CurrentTrader INT;

	WHILE EXISTS (
			SELECT 1
			FROM #tmpTraders
			)
	BEGIN
		SELECT TOP (1) @CurrentTrader = t.UserId
		FROM #tmpTraders AS t WITH (NOLOCK);

		TRUNCATE TABLE #tmpMatches;

		INSERT INTO #tmpMatches (
			CustId
			,MatchId
			,EventDate
			,KickOffTime
			,OrderedIndex
			)
		SELECT m.UserId
			,m.OWPMatchId
			,m.EventDate
			,m.KickOffTime
			,ROW_NUMBER() OVER (
				ORDER BY m.KickOffTime
				)
		FROM #tmpTempAssignmentReportMainMatch AS m WITH (NOLOCK)
		WHERE m.UserId = @CurrentTrader;;

		WITH rs
		AS (
			SELECT t1.CustId
				,t1.MatchId
				,t1.EventDate
				,t1.KickOffTime
				,t1.OrderedIndex
				,1 AS MatchOrder
				,ROW_NUMBER() OVER (
					ORDER BY t1.KickOffTime
					) AS MatchGroup
			FROM #tmpMatches AS t1 WITH (NOLOCK)
			LEFT JOIN #tmpMatches AS t2 WITH (NOLOCK) ON t1.OrderedIndex - 1 = t2.OrderedIndex
			WHERE DATEDIFF(MINUTE, t2.KickOffTime, t1.KickOffTime) > 30
				OR t2.matchid IS NULL
			
			UNION ALL
			
			SELECT t1.CustId
				,t1.MatchId
				,t1.EventDate
				,t1.KickOffTime
				,t1.OrderedIndex
				,rs.MatchOrder + 1
				,rs.MatchGroup
			FROM rs
			INNER JOIN #tmpMatches AS t1 WITH (NOLOCK) ON rs.OrderedIndex + 1 = t1.OrderedIndex
			WHERE DATEDIFF(MINUTE, rs.KickOffTime, t1.KickOffTime) <= 30
			)
		INSERT INTO #tmpMatchesInfoMultiple (
			UserId
			,MatchGroup
			,MatchId
			,KickOffTime
			)
		SELECT CustId
			,MatchGroup
			,MatchId
			,KickOffTime
		FROM rs
		OPTION (MAXRECURSION 0);

		DELETE t
		WITH (ROWLOCK)
		FROM #tmpTraders AS t
		WHERE t.UserId = @CurrentTrader;
	END;

	SELECT UserId
		,MatchGroup
		,COUNT(DISTINCT (MatchId)) AS Robot_X5
	FROM #tmpMatchesInfoMultiple
	GROUP BY UserId
		,MatchGroup
END