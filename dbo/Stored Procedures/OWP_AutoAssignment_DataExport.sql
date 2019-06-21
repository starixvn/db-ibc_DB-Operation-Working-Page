
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_DataExport] @RequestId NVARCHAR (50)
AS
/*
Created: 20190617@Kane.Le
Task : Get data for report
DB: bodb_OWP

Revisions:
	20190617@Kane.Le: Initial SP - [Redmine: #114749]	 
*/
BEGIN
	DECLARE @EventDate DATE
	SELECT @EventDate = rq.EventDate 
	FROM dbo.AutoAssignmentRequest AS rq WITH (NOLOCK)
	WHERE rq.RequestId = @RequestId
	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')
	DECLARE @BettypeHDP INT = 1
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
	DECLARE @LineBreak NVARCHAR(10) = CHAR(10)		 

	DECLARE @tblRefResource TABLE (
		Id INT
		,[Value] NVARCHAR(50)
		)

	INSERT INTO @tblRefResource (
		Id
		,[Value]
		)
	SELECT rs.ResourceId
		,rs.[Value]
	FROM dbo.RefResource AS rs WITH (NOLOCK)
	WHERE rs.RefName = 'UserLevel'

	-- Match list
	CREATE TABLE #owpMatchListByDate (
		OWPMatchId INT
		,MatchNo NVARCHAR(50)
		,EventDate DATE
		,EventDateTime DATETIME
		,KickOffTime TIME(7)
		,OWPLeagueId INT
		,OWPHomeId INT
		,OWPAwayId INT
		,MatchId INT
		,IsMinorMatch BIT
		,MinorBettypeId INT
		,ParentMatchId INT
		,InfoSiteMatchId INT
		)

	INSERT INTO #owpMatchListByDate (
		OWPMatchId
		,MatchNo
		,EventDate
		,EventDateTime
		,KickOffTime
		,OWPLeagueId
		,OWPHomeId
		,OWPAwayId
		,MatchId
		,IsMinorMatch
		,MinorBettypeId
		,ParentMatchId
		,InfoSiteMatchId
		)
	SELECT om.OWPMatchId
		,om.MatchNo
		,om.EventDate
		,om.EventDateTime
		,om.KickOffTime
		,om.OWPLeagueId
		,om.OWPHomeId
		,om.OWPAwayId
		,om.MatchId
		,CASE 
			WHEN minor.MinorMatchId IS NULL
				THEN 0
			ELSE 1
			END AS IsMinorMatch
		,minor.MinorBettypeId
		,CASE 
			WHEN minor.ParentMatchId IS NULL
				THEN om.OWPMatchId
			ELSE minor.ParentMatchId
			END AS ParentMatchId
		,om.InfoSiteMatchId
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
	LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
	WHERE om.EventDateTime BETWEEN @FromDate
			AND @ToDate
		AND mi.IsSelected = 1
		AND (
			minor.IsRepresented = 1
			OR minor.IsRepresented IS NULL
			)

	-- Get maxbet
	CREATE TABLE #tblMatchSetting (
		OWPMatchId INT
		,ParentMatchId INT
		,Bettype INT
		,MinorBettypeId INT
		,MaxBet MONEY
		,Spread MONEY
		,IsMatchSetting BIT
		,LeagueId INT
		)

	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,ParentMatchId
		,Bettype
		,MinorBettypeId
		,MaxBet
		,Spread
		,IsMatchSetting
		)
	SELECT ml.owpmatchid
		,ml.ParentMatchId
		,ms.Bettype
		,ml.MinorBettypeId
		,ms.Maxbet
		,ms.Spread
		,1
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON ml.owpmatchid = ms.OWPMatchId

	-- league setting
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,ParentMatchId
		,LeagueId
		,Bettype
		,IsMatchSetting
		)
	SELECT ml.OWPMatchId
		,ml.ParentMatchId
		,ml.OWPLeagueId
		,ls.Bettype
		,0
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON ml.OWPLeagueId = ls.LeagueId
	WHERE ml.OWPMatchId NOT IN (
			SELECT OWPMatchId
			FROM #tblMatchSetting WITH (NOLOCK)
			)
		AND ml.IsMinorMatch = 0
	GROUP BY ml.OWPMatchId
		,ml.OWPLeagueId
		,ls.Bettype
		,ml.ParentMatchId

	UPDATE mb
	SET mb.MaxBet = dbo.OWP_MaxBetGet(mb.OWPMatchId, mb.LeagueId, mb.Bettype)
		,mb.Spread = dbo.OWP_SpreadGet(mb.OWPMatchId, mb.LeagueId, mb.Bettype)
	FROM #tblMatchSetting AS mb
	WHERE mb.IsMatchSetting = 0

	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,ParentMatchId
		,Bettype
		,MinorBettypeId
		,MaxBet
		,Spread
		)
	SELECT t.OWPMatchId
		,t.ParentMatchId
		,t.InheritedBettypeId
		,t.MinorBettypeId
		,md.MaxBet
		,md.Spread
	FROM (
		SELECT ml.OWPMatchId
			,ml.ParentMatchId
			,mbt.ParentBettypeId
			,mbt.InheritedBettypeId
			,ml.MinorBettypeId
			,CASE 
				WHEN mst.OWPMatchId IS NULL
					THEN dbo.OWP_MaxBetGet(minor.ParentMatchId, ma.OWPLeagueId, @BettypeHDP)
				ELSE mst.Maxbet
				END AS MaxBetHDP
		FROM #owpMatchListByDate AS ml WITH (NOLOCK)
		INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON ml.OWPMatchId = minor.MinorMatchId
		INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON minor.ParentMatchId = ma.OWPMatchId
		INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
		LEFT JOIN dbo.MatchSetting AS mst WITH (NOLOCK) ON minor.ParentMatchId = mst.OWPMatchId
			AND mst.Bettype = @BettypeHDP
		WHERE ml.IsMinorMatch = 1
			AND ml.OWPMatchId NOT IN (
				SELECT OWPMatchId
				FROM #tblMatchSetting WITH (NOLOCK)
				)
		) AS t
	INNER JOIN dbo.MinorSetting AS m WITH (NOLOCK) ON t.MaxBetHDP BETWEEN ISNULL(FromMaxBet, 0)
			AND ISNULL(ToMaxBet, 99999999999)
	INNER JOIN dbo.MinorSettingDetail AS md WITH (NOLOCK) ON m.MinorSettingId = md.MinorSettingId
		AND md.MinorBettypeId = t.ParentBettypeId

	-- Assignment
	CREATE TABLE #tblAssignment (
		OWPMatchId INT
		,Bettype INT
		,MinorBettypeId INT
		,AssignmentType SMALLINT
		,AssignmentContent NVARCHAR(200)
		,AssignmentId INT
		,UserId INT
		,Username NVARCHAR(50)
		,[Level] NVARCHAR(50)
		,[LocationCode] NVARCHAR(50)
		,ParentMatchId INT
		)

	INSERT INTO #tblAssignment (
		OWPMatchId
		,Bettype
		,MinorBettypeId
		,AssignmentType
		,AssignmentContent
		,UserId
		,Username
		,[Level]
		,LocationCode
		,AssignmentId
		,ParentMatchId
		)
	SELECT a.OWPMatchId
		,a.Bettype
		,ml.MinorBettypeId
		,a.AssignmentType
		,NULL
		,a.UserId
		,u.Username
		,rs.[Value]
		,u.LocationCode
		,a.AssignmentId
		,ml.ParentMatchId
	FROM dbo.Assignment AS a WITH (NOLOCK)
	INNER JOIN #owpMatchListByDate AS ml WITH (NOLOCK) ON a.OWPMatchId = ml.owpmatchid
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	LEFT JOIN @tblRefResource AS rs ON u.[Level] = rs.Id
	WHERE ml.IsMinorMatch = 0
		AND a.AssignmentType = 1
	
	UNION
	
	SELECT ml.OWPMatchId
		,mb.InheritedBettypeId AS Bettype
		,ml.MinorBettypeId
		,a.AssignmentType
		,NULL
		,a.UserId
		,u.Username
		,rs.[Value]
		,u.LocationCode
		,a.AssignmentId
		,ml.ParentMatchId
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.IsActive = 1
		AND mb.ParentBettypeId = ml.MinorBettypeId
	LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
		AND a.Bettype = mb.InheritedBettypeId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	LEFT JOIN @tblRefResource AS rs ON u.[Level] = rs.Id
	WHERE ml.IsMinorMatch = 1
		AND a.AssignmentType = 1

	-- AssignmentAuto
	CREATE TABLE #tblAssignmentAuto (
		OWPMatchId INT
		,Bettype INT
		,MinorBettypeId INT
		,AssignmentType SMALLINT
		,AssignmentContent NVARCHAR(200)
		,AssignmentId INT
		,UserId INT
		,Username NVARCHAR(50)
		,[Level] NVARCHAR(50)
		,LocationCode NVARCHAR(50)
		,ParentMatchId INT
		)

	INSERT INTO #tblAssignmentAuto (
		OWPMatchId
		,Bettype
		,MinorBettypeId
		,AssignmentType
		,AssignmentContent
		,UserId
		,Username
		,[Level]
		,LocationCode
		,AssignmentId
		,ParentMatchId
		)
	SELECT a.OWPMatchId
		,b.Bettype
		,b.MinorBettypeId
		,1
		,NULL
		,a.UserId
		,u.Username
		,rs.[Value]
		,u.LocationCode
		,NULL
		,NULL
	FROM dbo.AutoAssignmentResult AS a
	JOIN #tblAssignment AS b ON a.OWPMatchId = b.OWPMatchId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	LEFT JOIN @tblRefResource AS rs ON u.[Level] = rs.Id
	WHERE a.RequestId = @RequestId
		AND b.Bettype = - 1002
		AND b.AssignmentType = 1

	SELECT 
		ml.OWPMatchId
		,ml.MatchNo
		,CONVERT(VARCHAR, (
				CASE 
					WHEN DATEPART(HOUR, ml.KickOffTime) >= 0
						AND DATEPART(HOUR, ml.KickOffTime) < 12
						THEN DATEADD(DAY, - 1, ml.EventDate)
					ELSE ml.EventDate
					END
				), 101) AS 'Date'
		,convert(VARCHAR, ml.EventDate, 101) + ' ' + convert(VARCHAR, ml.KickOffTime, 100) AS 'Time'
		,l.OWPLeagueName AS League
		,h.OWPTeamName AS Home
		,a.OWPTeamName AS Away
		,(
			SELECT CAST(a.MaxBet / 1000 AS VARCHAR(20)) + 'K'
			FROM #tblMatchSetting AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 1
			) AS MaxBetHDP
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.AssignmentType = 1
			) AS TraderHDP
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 7
				AND a.AssignmentType = 1
			) AS Trader1HHDP
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 3
				AND a.AssignmentType = 1
			) AS TraderOU
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 8
				AND a.AssignmentType = 1
			) AS Trader1HOU
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 5
				AND a.AssignmentType = 1
			) AS Trader1X2
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 15
				AND a.AssignmentType = 1
			) AS Trader1H1X2
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.ParentMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.MinorBettypeId = - 1
				AND a.AssignmentType = 1
			) AS Trader15Mins
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.ParentMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.MinorBettypeId = - 2
				AND a.AssignmentType = 1
			) AS Trader10Mins
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = - 1002
				AND a.AssignmentType = 1
			) AS LA
		,(
			SELECT a.[Level]
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = - 1002
				AND a.AssignmentType = 1
			) AS LALevel
			,(
			SELECT a.LocationCode
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = - 1002
				AND a.AssignmentType = 1
			) AS LALocation
		,(
			SELECT TOP 1 a.Username
			FROM #tblAssignmentAuto AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
			) AS LAAuto
		,(
			SELECT TOP 1 a.[Level]
			FROM #tblAssignmentAuto AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
			) AS LAAutoLevel
		,(
			SELECT TOP 1 a.LocationCode
			FROM #tblAssignmentAuto AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
			) AS LAAutoLocation
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.ParentMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.MinorBettypeId = - 88
				AND a.AssignmentType = 1
			) AS TraderFM
		,(
			SELECT a.Username
			FROM #tblAssignment AS a
			WHERE a.ParentMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.MinorBettypeId = - 89
				AND a.AssignmentType = 1
			) AS TraderAIO
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.TVCode AS NVARCHAR(100)), '')
				FROM dbo.Television AS rs WITH (NOLOCK)
				INNER JOIN dbo.MatchTelevision AS mtv WITH (NOLOCK) ON rs.TVId = mtv.TVId
				WHERE mtv.OWPMatchId = ml.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS TV
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.ProviderName AS NVARCHAR(100)), '')
				FROM dbo.[Provider] AS rs WITH (NOLOCK)
				INNER JOIN dbo.MatchProvider AS mp WITH (NOLOCK) ON rs.ProviderId = mp.ProviderId
				WHERE mp.OWPMatchId = ml.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS [Provider]
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
	INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId	
	WHERE (
			ml.MinorBettypeId NOT IN (
				@Specific15Mins
				,@Specific10Mins
				,@Specific15MinsNoOfCorners
				,@Specific15MinsTotalBooking
				,@FastMarket
				,@AllInOne
				)
			OR ml.MinorBettypeId IS NULL
			)
	ORDER BY ma.EventDate
		,ma.KickOffTime
		,ml.ParentMatchId
		,ml.IsMinorMatch
		,l.OWPLeagueName
		,h.OWPTeamName
 
	DROP TABLE #owpMatchListByDate

	DROP TABLE #tblMatchSetting

	DROP TABLE #tblAssignment

	DROP TABLE #tblAssignmentAuto
END