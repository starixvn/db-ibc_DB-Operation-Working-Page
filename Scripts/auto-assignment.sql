DECLARE @EventDate DATETIME = '2019-06-11'
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
	OWPMatchId INT
	,ParentMatchId INT
	,MinorBettypeId INT
	,KOTime DATETIME
	,LeagueId INT
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
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON m.OWPMatchId = om.OWPMatchId
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	LEFT JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
	AND ms.Bettype = @BettypeHDP

-- update maxbet from MaxbetManagement setting
UPDATE m
SET m.Maxbet = dbo.OWP_MaxBetGet(m.OWPMatchId, m.LeagueId, @BettypeHDP)
FROM #tblMatch AS m
WHERE m.Maxbet IS NULL

-- Assignment
CREATE TABLE #tblAssignment (
	OWPMatchId INT
	,UserId INT
	,[Level] INT
	,SpeakChinese BIT
	,InTime DATETIME
	,OutTime DATETIME
	)

INSERT INTO #tblAssignment (
	OWPMatchId
	,UserId
	)
SELECT a.OWPMatchId
	,a.UserId
FROM dbo.Assignment AS a WITH (NOLOCK)
	INNER JOIN #tblMatch AS ml WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
WHERE ml.OWPMatchId = ml.ParentMatchId
	AND a.Bettype = - 1002

UNION
SELECT ml.OWPMatchId
	,a.UserId
FROM #tblMatch AS ml WITH (NOLOCK)
	INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.IsActive = 1
	AND mb.ParentBettypeId = ml.MinorBettypeId
	LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
	AND a.Bettype = mb.InheritedBettypeId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
WHERE ml.OWPMatchId <> ml.ParentMatchId
	AND a.Bettype = - 1002

UPDATE a
SET [Level] = u.[Level]
	,SpeakChinese = (CASE 
		WHEN u.LocationCode = 'CTI' THEN 1
		ELSE 0 END
		)
FROM #tblAssignment AS a
	INNER JOIN dbo.[User] AS u ON a.UserId = u.UserId

UPDATE a
SET a.InTime = ws.ShiftStartTime
	,a.OutTime = ws.ShiftEndTime
FROM #tblAssignment AS a
	INNER JOIN dbo.EmployeeWorkingShift AS ws ON a.UserId = ws.EmployeeId
WHERE (
		ws.ShiftStartTime < @FromDate
		AND ws.ShiftEndTime > @FromDate
		)
	OR (
		ws.ShiftStartTime >= @FromDate
		AND ws.ShiftEndTime <= @ToDate
		)
	OR (
		ws.ShiftEndTime < @ToDate
		AND ws.ShiftEndTime > @ToDate
		)

SELECT m.ParentMatchId
	--,m.OWPMatchId
	,ISNULL(bt.SchedulingBettypeId, 0) AS SchedulingBettypeId
	,m.HasTV
	,m.KOTime
	,m.Maxbet
	,a.[Level]
	,a.SpeakChinese
	,a.InTime
	,a.OutTime
	,a.UserId
FROM #tblMatch AS m
	INNER JOIN #tblAssignment AS a ON m.OWPMatchId = a.OWPMatchId
	LEFT JOIN dbo.AutoAssignmentBettype AS bt ON m.MinorBettypeId = bt.MinorBettypeId
WHERE m.Maxbet IS NOT NULL

DROP TABLE #tblMatch

DROP TABLE #tblAssignment
