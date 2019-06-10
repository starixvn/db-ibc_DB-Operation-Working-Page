DECLARE @FromDate DATETIME = '2019-06-01'
	,@ToDate DATETIME = '2019-06-08 11:59:59'
DECLARE @BettypeHDP INT = 1
	,@Specific15Mins INT = - 1
	,@Specific10Mins INT = - 2
	,@Specific15MinsNoOfCorners INT = - 5
	,@Specific15MinsTotalBooking INT = - 8
	,@FastMarket INT = - 88
	,@AllInOne INT = - 89
DECLARE @LineBreak NVARCHAR(10) = CHAR(10)
-- NoOfHDP resource
DECLARE @tblNoOfHDPResource TABLE (
	Id INT NOT NULL
	,Value NVARCHAR(50) NOT NULL
	)

INSERT INTO @tblNoOfHDPResource (
	Id
	,Value
	)
SELECT ResourceId
	,Value
FROM dbo.RefResource WITH (NOLOCK)
WHERE RefName = 'NoOfHDP'

-- MatchOffer resource
DECLARE @tblMatchOfferResource TABLE (
	Id INT NOT NULL
	,Value NVARCHAR(50) NOT NULL
	)

INSERT INTO @tblMatchOfferResource (
	Id
	,Value
	)
SELECT ResourceId
	,Value
FROM dbo.RefResource WITH (NOLOCK)
WHERE RefName = 'MatchOffer'

-- Match list
CREATE TABLE #owpMatchListByDate (
	OWPMatchId INT
	,MatchNo NVARCHAR(50)
	,EventDate DATE
	,EventDateTime DATETIME
	,KickOffTime TIME(7)
	,OtherTime TIME(7)
	,OWPLeagueId INT
	,OWPHomeId INT
	,OWPAwayId INT
	,MatchId INT
	,NoOfHDPId INT
	,Channel NVARCHAR(200)
	,WatchBet NVARCHAR(200)
	,Phone NVARCHAR(200)
	,[Round] NVARCHAR(2000)
	,OutSide NVARCHAR(2000)
	,Remark NVARCHAR(2000)
	,Website NVARCHAR(1000)
	,Website2 NVARCHAR(1000)
	,Website3 NVARCHAR(1000)
	,Website4 NVARCHAR(1000)
	,MatchStatus NVARCHAR(15)
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
	,OtherTime
	,OWPLeagueId
	,OWPHomeId
	,OWPAwayId
	,MatchId
	,NoOfHDPId
	,Channel
	,WatchBet
	,Phone
	,[Round]
	,OutSide
	,Remark
	,Website
	,Website2
	,Website3
	,Website4
	,MatchStatus
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
	,om.OtherTime
	,om.OWPLeagueId
	,om.OWPHomeId
	,om.OWPAwayId
	,om.MatchId
	,r.Id
	,mi.Channel
	,mi.WB
	,mi.Phone
	,mi.[Round]
	,mi.Division
	,mi.Remark
	,mi.Website1
	,mi.Website2
	,mi.Website3
	,mi.Website4
	,dbo.OWP_GetCurrentMatchStatus(om.EventDate, om.KickOffTime, mi.MatchStatus)
	,CASE 
		WHEN minor.MinorMatchId IS NULL THEN 0
		ELSE 1
		END AS IsMinorMatch
	,minor.MinorBettypeId
	,CASE 
		WHEN minor.ParentMatchId IS NULL THEN om.OWPMatchId
		ELSE minor.ParentMatchId
		END AS ParentMatchId
	,om.InfoSiteMatchId
FROM dbo.OWPMatch AS om WITH (NOLOCK)
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
	LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
	LEFT JOIN @tblNoOfHDPResource AS r ON mi.NoOfHDPId = r.Id
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
			WHEN mst.OWPMatchId IS NULL THEN dbo.OWP_MaxBetGet(minor.ParentMatchId, ma.OWPLeagueId, @BettypeHDP)
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
	,ParentMatchId INT
	)

INSERT INTO #tblAssignment (
	OWPMatchId
	,Bettype
	,MinorBettypeId
	,AssignmentType
	,AssignmentContent
	,AssignmentId
	,ParentMatchId
	)
SELECT a.OWPMatchId
	,a.Bettype
	,ml.MinorBettypeId
	,a.AssignmentType
	,(CASE a.AssignmentType
		WHEN 1 THEN u.Username
		ELSE (CASE 
				WHEN a.UserId IS NULL THEN a.AssignmentNote
				ELSE REPLACE(a.AssignmentNote, '<user>', u.Username) END
				) END
		)
	,a.AssignmentId
	,ml.ParentMatchId
FROM dbo.Assignment AS a WITH (NOLOCK)
	INNER JOIN #owpMatchListByDate AS ml WITH (NOLOCK) ON a.OWPMatchId = ml.owpmatchid
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
WHERE ml.IsMinorMatch = 0

UNION
SELECT ml.OWPMatchId
	,mb.InheritedBettypeId AS Bettype
	,ml.MinorBettypeId
	,a.AssignmentType
	,(CASE a.AssignmentType
		WHEN 1 THEN u.Username
		ELSE (CASE 
				WHEN a.UserId IS NULL THEN a.AssignmentNote
				ELSE REPLACE(a.AssignmentNote, '<user>', u.Username) END
				) END
		)
	,a.AssignmentId
	,ml.ParentMatchId
FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.IsActive = 1
	AND mb.ParentBettypeId = ml.MinorBettypeId
	LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
	AND a.Bettype = mb.InheritedBettypeId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
WHERE ml.IsMinorMatch = 1

SELECT ml.OWPMatchId
	,CONVERT(VARCHAR, (CASE 
			WHEN DATEPART(HOUR, ml.KickOffTime) >= 0
				AND DATEPART(HOUR, ml.KickOffTime) < 12 THEN DATEADD(DAY, - 1, ml.EventDate)
			ELSE ml.EventDate END
			), 101) AS 'Date'
	,ml.MatchNo AS 'No'
	,ml.MatchStatus AS 'Match Status'
	,ml.InfoSiteMatchId AS 'InfoSite ID'
	,convert(VARCHAR, ml.EventDate, 101) + ' ' + convert(VARCHAR, ml.KickOffTime, 100) AS 'Time'
	,convert(VARCHAR, ml.OtherTime, 100) AS 'Other Time'
	,STUFF((
			SELECT ', ' + r.Value
			FROM dbo.MatchOfferDetail AS mo
				INNER JOIN @tblMatchOfferResource AS r ON mo.MatchOfferId = r.Id
			WHERE mo.OWPMatchId = ml.OWPMatchId
			FOR XML PATH('')
			), 1, 2, '') AS MatchOffer
	,l.OWPLeagueName AS League
	,h.OWPTeamName AS Home
	,a.OWPTeamName AS Away
	,STUFF((
			SELECT @LineBreak + ISNULL(mn.Note, '')
			FROM dbo.MatchNote AS mn WITH (NOLOCK)
			WHERE mn.OWPMatchId = ml.owpmatchid
			FOR XML PATH('')
			), 1, 2, '') AS Note
	,ml.[Round]
	,ml.OutSide AS 'Division'
	,ml.Remark
	,ref.[Value] AS 'No.HDP'
	,(
		SELECT CAST(a.MaxBet / 1000 AS VARCHAR(20)) + 'K'
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 1
		) AS 'Max Bet (HDP)'
	,(
		SELECT CAST(a.Spread * 100 AS INT)
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 1
		) AS 'Spread (HDP)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 1
			AND a.AssignmentType = 1
		) AS 'Trader (HDP)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (HDP)'
	,(
		SELECT CAST(a.MaxBet / 1000 AS VARCHAR(20)) + 'K'
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 7
		) AS 'Max Bet (1H HDP)'
	,(
		SELECT CAST(a.Spread * 100 AS INT)
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 7
		) AS 'Spread (1H HDP)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 7
			AND a.AssignmentType = 1
		) AS 'Trader (1H HDP)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 7
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (1H HDP)'
	,(
		SELECT CAST(a.MaxBet / 1000 AS VARCHAR(20)) + 'K'
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 3
		) AS 'Max Bet (OU)'
	,(
		SELECT CAST(a.Spread * 100 AS INT)
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 3
		) AS 'Spread (OU)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 3
			AND a.AssignmentType = 1
		) AS 'Trader (OU)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 3
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (OU)'
	,(
		SELECT CAST(a.MaxBet / 1000 AS VARCHAR(20)) + 'K'
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 8
		) AS 'Max Bet (1H OU)'
	,(
		SELECT CAST(a.Spread * 100 AS INT)
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 8
		) AS 'Spread (1H OU)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 8
			AND a.AssignmentType = 1
		) AS 'Trader (1H OU)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 8
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (1H OU)'
	,(
		SELECT CAST(a.MaxBet / 1000 AS VARCHAR(20)) + 'K'
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 5
		) AS 'Max Bet (1X2)'
	,(
		SELECT CAST(a.Spread * 100 AS INT)
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 5
		) AS 'Spread (1X2)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 5
			AND a.AssignmentType = 1
		) AS 'Trader (1X2)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 5
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (1X2)'
	,(
		SELECT CAST(a.MaxBet / 1000 AS VARCHAR(20)) + 'K'
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 15
		) AS 'Max Bet (1H 1X2)'
	,(
		SELECT CAST(a.Spread * 100 AS INT)
		FROM #tblMatchSetting AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 15
		) AS 'Spread (1H 1X2)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = 15
			AND a.AssignmentType = 1
		) AS 'Trader (1H 1X2)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = 15
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (1H 1X2)'
	,(
		SELECT CAST(a.MaxBet / 1000 AS VARCHAR(20)) + 'K'
		FROM #tblMatchSetting AS a
		WHERE a.ParentMatchId = ml.OWPMatchId
			AND a.MinorBettypeId = - 1
		) AS 'Max Bet (x mins)'
	,(
		SELECT CAST(a.Spread * 100 AS INT)
		FROM #tblMatchSetting AS a
		WHERE a.ParentMatchId = ml.OWPMatchId
			AND a.MinorBettypeId = - 1
		) AS 'Spread (x mins)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.ParentMatchId = ml.OWPMatchId
			AND a.Bettype = 1
			AND a.MinorBettypeId = - 1
			AND a.AssignmentType = 1
		) AS 'Trader (15 mins)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.ParentMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.MinorBettypeId = - 1
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (15 mins)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.ParentMatchId = ml.OWPMatchId
			AND a.Bettype = 1
			AND a.MinorBettypeId = - 2
			AND a.AssignmentType = 1
		) AS 'Trader (10 mins)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.ParentMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.MinorBettypeId = - 2
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (10 mins)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = - 1002
			AND a.AssignmentType = 1
		) AS 'LA'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = - 1002
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other LA'
	,(
		SELECT CAST(a.MaxBet / 1000 AS VARCHAR(20)) + 'K'
		FROM #tblMatchSetting AS a
		WHERE a.ParentMatchId = ml.OWPMatchId
			AND a.MinorBettypeId = - 88
		) AS 'Max Bet (FM)'
	,(
		SELECT CAST(a.Spread * 100 AS INT)
		FROM #tblMatchSetting AS a
		WHERE a.ParentMatchId = ml.OWPMatchId
			AND a.MinorBettypeId = - 88
		) AS 'Spread (FM)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.ParentMatchId = ml.OWPMatchId
			AND a.Bettype = 1
			AND a.MinorBettypeId = - 88
			AND a.AssignmentType = 1
		) AS 'Trader (FM)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.ParentMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.MinorBettypeId = - 88
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (FM)'
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.ParentMatchId = ml.OWPMatchId
			AND a.Bettype = 1
			AND a.MinorBettypeId = - 89
			AND a.AssignmentType = 1
		) AS 'Trader (AIO)'
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.ParentMatchId = ml.OWPMatchId
				AND a.Bettype = 1
				AND a.MinorBettypeId = - 89
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS 'Other Traders (AIO)'
	,STUFF((
			SELECT ', ' + ISNULL(CAST(rs.AgentName AS NVARCHAR(100)), '')
			FROM dbo.Agent AS rs WITH (NOLOCK)
				INNER JOIN dbo.MatchAgent AS ma WITH (NOLOCK) ON rs.AgentId = ma.AgentId
			WHERE ma.OWPMatchId = ml.OWPMatchId
			FOR XML PATH('')
			), 1, 2, '') AS Agent
	,STUFF((
			SELECT ', ' + ISNULL(CAST(rs.TVCode AS NVARCHAR(100)), '')
			FROM dbo.Television AS rs WITH (NOLOCK)
				INNER JOIN dbo.MatchTelevision AS mtv WITH (NOLOCK) ON rs.TVId = mtv.TVId
			WHERE mtv.OWPMatchId = ml.OWPMatchId
			FOR XML PATH('')
			), 1, 2, '') AS TV
	,ml.Channel
	,ml.WatchBet AS 'WB'
	,STUFF((
			SELECT ', ' + ISNULL(CAST(rs.OtherProviderName AS NVARCHAR(100)), '')
			FROM dbo.OtherProvider AS rs WITH (NOLOCK)
				INNER JOIN dbo.MatchOtherProvider AS mot WITH (NOLOCK) ON rs.OtherProviderId = mot.OtherProviderId
			WHERE mot.OWPMatchId = ml.OWPMatchId
			FOR XML PATH('')
			), 1, 2, '') AS OtherProvider
	,STUFF((
			SELECT ', ' + ISNULL(CAST(rs.ProviderName AS NVARCHAR(100)), '')
			FROM dbo.[Provider] AS rs WITH (NOLOCK)
				INNER JOIN dbo.MatchProvider AS mp WITH (NOLOCK) ON rs.ProviderId = mp.ProviderId
			WHERE mp.OWPMatchId = ml.OWPMatchId
			FOR XML PATH('')
			), 1, 2, '') AS [Provider]
	,ml.Phone
	,ml.Website AS Web1
	,ml.Website2 AS Web2
	,ml.Website3 AS Web3
	,ml.Website4 AS Web4
FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
	INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId
	LEFT JOIN @tblNoOfHDPResource ref ON ml.NoOfHDPId = ref.Id
WHERE (
		ml.MinorBettypeId NOT IN (@Specific15Mins, @Specific10Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne)
		OR ml.MinorBettypeId IS NULL
		)
ORDER BY ma.EventDate
	,ma.KickOffTime
	,ml.ParentMatchId
	,ml.IsMinorMatch
	,l.OWPLeagueName
	,h.OWPTeamName
	,ml.MatchNo

DROP TABLE #owpMatchListByDate

DROP TABLE #tblMatchSetting

DROP TABLE #tblAssignment
