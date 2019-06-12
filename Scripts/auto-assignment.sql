DECLARE @EventDate DATETIME = '2019-06-11'
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
		WHEN 1 THEN CAST(u.UserId AS NVARCHAR(200))
		ELSE (CASE 
				WHEN a.UserId IS NULL THEN ''
				ELSE REPLACE(a.AssignmentNote, '<user>', u.UserId) END
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
		WHEN 1 THEN CAST(u.UserId AS NVARCHAR(200))
		ELSE (CASE 
				WHEN a.UserId IS NULL THEN ''
				ELSE REPLACE(a.AssignmentNote, '<user>', u.UserId) END
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
	,ISNULL(abt.MinorBettypeId, 0) AS SchedulingBettypeId
	,(
		SELECT ISNULL(a.AssignmentContent, '')
		FROM #tblAssignment AS a
		WHERE a.OWPMatchId = ml.OWPMatchId
			AND a.Bettype = - 1002
			AND a.AssignmentType = 1
		) AS LA
	,STUFF((
			SELECT ', ' + ISNULL(a.AssignmentContent, '')
			FROM #tblAssignment AS a
			WHERE a.OWPMatchId = ml.OWPMatchId
				AND a.Bettype = - 1002
				AND a.AssignmentType = 2
			ORDER BY a.AssignmentId
			FOR XML PATH('')
			), 1, 2, '') AS OtherLA
FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
	INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId
	LEFT JOIN @tblNoOfHDPResource ref ON ml.NoOfHDPId = ref.Id
	LEFT JOIN dbo.AutoAssignmentBettype AS abt WITH (NOLOCK) ON ml.MinorBettypeId = abt.MinorBettypeId
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

DROP TABLE #tblAssignment
