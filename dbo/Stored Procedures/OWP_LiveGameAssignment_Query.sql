
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_Query] @EventDate DATE
	,@Username NVARCHAR(30) = NULL
	,@MatchStatusIds NVARCHAR(100) = NULL
AS
/*
 Created: 20190619@Kane.Le
 Task : query live game assignment
 DB: bodb_OWP

 Revisions:
	20190619@Kane.Le: Initial SP - [Feature: #114614]
	20190712@Tyler.Dang: Add MaxbetCN88 and SpreadCN88 Live Game Assignment - [Feature: #116791]
	20190716@Kane.Le: Filter with MinorBetType - [Feature: #116791]
	20190806@Kane.Le: Filter with MatchStatus - [Feature: #117227]
	20190807@Kane.Le: Return Website1 - [Feature: #117227]
	20190815@Kane.Le: Get LastUpdated note - [Feature: #117960]
	20190910@Leo.Vo: Include EventDateTime - [Feature: #119650]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @UserId INT = NULL

	SELECT @UserId = dbo.OWP_GetUserIdByUsername(@Username)

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')
		,@BettypeHDP INT = 1
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@MatchStatusText NVARCHAR(100)
	DECLARE @tblRefResourceMatchStatus TABLE (
		Id INT NOT NULL
		,Value NVARCHAR(50) NOT NULL
		)

	INSERT INTO @tblRefResourceMatchStatus (
		Id
		,Value
		)
	SELECT ResourceId
		,Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MatchStatus'
		AND ResourceId IN (
			SELECT val
			FROM dbo.fnc_SplitStrings(@MatchStatusIds, ',')
			)

	CREATE TABLE #tblMatchOfferResource (
		Id INT NOT NULL
		,Value NVARCHAR(50) NOT NULL
		)

	INSERT INTO #tblMatchOfferResource (
		Id
		,Value
		)
	SELECT ResourceId
		,Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MatchOffer'

	CREATE TABLE #tblNoOfHDPResource (
		Id INT NOT NULL
		,Value NVARCHAR(50) NOT NULL
		)

	INSERT INTO #tblNoOfHDPResource (
		Id
		,Value
		)
	SELECT ResourceId
		,Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'NoOfHDP'

	-- Match ID List by Date
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
		,NoOfHDP NVARCHAR(20)
		,NoOfHDPId INT
		,Channel NVARCHAR(200)
		,WatchBet NVARCHAR(200)
		,Phone NVARCHAR(200)
		,[Round] NVARCHAR(2000)
		,OutSide NVARCHAR(2000)
		,Remark NVARCHAR(2000)
		,Website1 NVARCHAR(1000)
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
		,NoOfHDP
		,NoOfHDPId
		,Channel
		,WatchBet
		,Phone
		,[Round]
		,OutSide
		,Remark
		,Website1
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
		,r.Value
		,mi.NoOfHDPId
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
	LEFT JOIN #tblNoOfHDPResource AS r ON mi.NoOfHDPId = r.Id
	WHERE om.EventDateTime BETWEEN @FromDate
			AND @ToDate
		AND mi.IsSelected = 1
		AND (
			minor.IsRepresented = 1
			OR minor.IsRepresented IS NULL
			)

	CREATE TABLE #tblMatchIdsFilterByUserId (
		OWPMatchId INT
		,UserId INT
		)

	INSERT INTO #tblMatchIdsFilterByUserId (
		OWPMatchId
		,UserId
		)
	SELECT a.OWPMatchId
		,a.UserId
	FROM dbo.Assignment AS a WITH (NOLOCK)
	INNER JOIN #owpMatchListByDate AS ml WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	WHERE ml.IsMinorMatch = 0
		AND (
			@UserId IS NULL
			OR u.UserId = @UserId
			)
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)
	
	UNION
	
	SELECT ml.OWPMatchId
		,a.UserId
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.IsActive = 1
		AND mb.ParentBettypeId = ml.MinorBettypeId
	LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
		AND a.Bettype = mb.InheritedBettypeId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	WHERE ml.IsMinorMatch = 1
		AND (
			@UserId IS NULL
			OR u.UserId = @UserId
			)
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)

	

	CREATE TABLE #tblOWPMatchFilter (OWPMatchId INT)

	INSERT INTO #tblOWPMatchFilter
	SELECT ml.ParentMatchId
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
	INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId
	LEFT JOIN #tblNoOfHDPResource ref ON ml.NoOfHDPId = ref.Id
	WHERE (
			ml.MinorBettypeId IN (
				@Specific15Mins
				,@Specific10Mins
				,@Specific15MinsNoOfCorners
				,@Specific15MinsTotalBooking
				,@FastMarket
				,@AllInOne
				)
			OR ml.MinorBettypeId IS NOT NULL
			)
		AND (
			@UserId IS NULL
			OR ml.OWPMatchId IN (
				SELECT OWPMatchId
				FROM #tblMatchIdsFilterByUserId
				)
			)
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)
	
	UNION
	
	SELECT ml.OWPMatchId
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
	INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId
	LEFT JOIN #tblNoOfHDPResource ref ON ml.NoOfHDPId = ref.Id
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
		AND (
			@UserId IS NULL
			OR ml.OWPMatchId IN (
				SELECT OWPMatchId
				FROM #tblMatchIdsFilterByUserId
				)
			)
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)

	 

	-- Return Matches info
	SELECT ml.OWPMatchId
		,ml.MatchNo
		,ml.EventDateTime
		,ml.KickOffTime
		,ml.OtherTime
		,l.OWPLeagueName AS League
		,h.OWPTeamName AS Home
		,a.OWPTeamName AS Away
		,ref.[Value] AS NoOfHDP
		,ml.NoOfHDPId
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.TVCode AS NVARCHAR(100)), '')
				FROM dbo.Television AS rs WITH (NOLOCK)
				INNER JOIN dbo.MatchTelevision AS mtv WITH (NOLOCK) ON rs.TVId = mtv.TVId
				WHERE mtv.OWPMatchId = ml.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS TV
		,ml.Channel
		,ml.WatchBet
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.AgentName AS NVARCHAR(100)), '')
				FROM dbo.Agent AS rs WITH (NOLOCK)
				INNER JOIN dbo.MatchAgent AS ma WITH (NOLOCK) ON rs.AgentId = ma.AgentId
				WHERE ma.OWPMatchId = ml.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS Agent
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
		,STUFF((
				SELECT ', ' + r.Value
				FROM dbo.MatchOfferDetail AS mo
				INNER JOIN #tblMatchOfferResource AS r ON mo.MatchOfferId = r.Id
				WHERE mo.OWPMatchId = ml.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS MatchOffer
		,ml.Phone
		,ml.[Round]
		,ml.OutSide
		,ml.Remark
		,ml.Website1
		,ml.Website2
		,ml.Website3
		,ml.Website4
		,ml.MatchStatus
		,ml.IsMinorMatch
		,ml.MinorBettypeId
		,ml.ParentMatchId
		,ml.InfoSiteMatchId
		,(CASE WHEN ml.InfoSiteMatchId IS NULL THEN NULL ELSE CASE WHEN im.InfoSiteMatchId IS NULL THEN 0 ELSE 1 END END) AS IsInfoSiteLinked
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
	INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId
	LEFT JOIN #tblNoOfHDPResource as ref ON ml.NoOfHDPId = ref.Id
	LEFT JOIN dbo.InfoSiteMatch as im WITH (NOLOCK) ON ml.InfoSiteMatchId = im.InfoSiteMatchId
	WHERE ml.OWPMatchId IN (
			SELECT OWPMatchId
			FROM #tblOWPMatchFilter
			)
		AND (
			@UserId IS NULL
			OR ml.OWPMatchId IN (
				SELECT OWPMatchId
				FROM #tblMatchIdsFilterByUserId
				)
			)
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)
	ORDER BY ml.EventDate
		,ml.KickOffTime
		,ml.MatchNo
		,l.OWPLeagueName
		,h.OWPTeamName
		,ml.ParentMatchId
		,ml.IsMinorMatch

	-- Return assignment for LIVE assignment uploading
	SELECT a.OWPMatchId
		,a.Bettype
		,ml.MinorBettypeId
		,a.UserId
		,u.Nickname
		,u.Username
		,a.AssignmentType
		,a.AssignmentNote
		,ml.ParentMatchId
		,a.AssignmentId
	FROM dbo.Assignment AS a WITH (NOLOCK)
	INNER JOIN #owpMatchListByDate AS ml WITH (NOLOCK) ON a.OWPMatchId = ml.owpmatchid
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	WHERE ml.IsMinorMatch = 0
		AND (
			@UserId IS NULL
			OR ml.OWPMatchId IN (
				SELECT OWPMatchId
				FROM #tblMatchIdsFilterByUserId
				)
			)
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)
	
	UNION
	
	SELECT ml.OWPMatchId
		,mb.InheritedBettypeId AS Bettype
		,ml.MinorBettypeId
		,a.UserId
		,u.Nickname
		,u.Username
		,a.AssignmentType
		,a.AssignmentNote
		,ml.ParentMatchId
		,a.AssignmentId
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.IsActive = 1
		AND mb.ParentBettypeId = ml.MinorBettypeId
	LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
		AND a.Bettype = mb.InheritedBettypeId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	WHERE ml.IsMinorMatch = 1
		AND (
			@UserId IS NULL
			OR ml.OWPMatchId IN (
				SELECT OWPMatchId
				FROM #tblMatchIdsFilterByUserId
				)
			)
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)

	-- Return notes
	DECLARE @TimeZoneGMT8 INT = 8;
	SELECT mn.OWPMatchId
		,mn.MatchNoteId
		,mn.Note
		,mn.CreatedBy AS UserId
		,u.Username
		,DATEADD(HH, @TimeZoneGMT8, (DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), mn.CreatedDate))) AS LastUpdated
	FROM dbo.MatchNote AS mn WITH (NOLOCK)
	INNER JOIN #owpMatchListByDate AS ml WITH (NOLOCK) ON mn.OWPMatchId = ml.OWPMatchId
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON mn.CreatedBy = u.UserId
	WHERE (
			@UserId IS NULL
			OR ml.OWPMatchId IN (
				SELECT OWPMatchId
				FROM #tblMatchIdsFilterByUserId
				)
			)
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)
	ORDER BY mn.CreatedDate DESC

	-- Get maxbet
	CREATE TABLE #tblMaxBet (
		OWPMatchId INT
		,ParentMatchId INT
		,Bettype INT
		,MinorBettypeId INT
		,MaxBet MONEY
		,Spread MONEY
		,MaxBetCN88 MONEY
		,SpreadCN88 MONEY
		,IsMatchSetting BIT
		,LeagueId INT
		)

	INSERT INTO #tblMaxBet (
		OWPMatchId
		,ParentMatchId
		,Bettype
		,MinorBettypeId
		,MaxBet
		,Spread
		,MaxBetCN88
		,SpreadCN88
		,IsMatchSetting
		)
	SELECT ml.owpmatchid
		,ml.ParentMatchId
		,ms.Bettype
		,ml.MinorBettypeId
		,ms.Maxbet
		,ms.Spread
		,ms.MaxbetCN88
		,ms.SpreadCN88
		,1
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON ml.owpmatchid = ms.OWPMatchId
	WHERE (
			@UserId IS NULL
			OR ml.OWPMatchId IN (
				SELECT OWPMatchId
				FROM #tblMatchIdsFilterByUserId
				)
			)
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)

	-- league setting
	INSERT INTO #tblMaxBet (
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
			FROM #tblMaxBet WITH (NOLOCK)
			)
		AND ml.IsMinorMatch = 0
		AND (
			@MatchStatusIds IS NULL
			OR ml.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)
	GROUP BY ml.OWPMatchId
		,ml.OWPLeagueId
		,ls.Bettype
		,ml.ParentMatchId

	UPDATE mb
	SET mb.MaxBet = dbo.OWP_MaxBetGet(mb.OWPMatchId, mb.LeagueId, mb.Bettype)
		,mb.Spread = dbo.OWP_SpreadGet(mb.OWPMatchId, mb.LeagueId, mb.Bettype)
	FROM #tblMaxBet AS mb
	WHERE mb.IsMatchSetting = 0

	INSERT INTO #tblMaxBet (
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
				FROM #tblMaxBet WITH (NOLOCK)
				)
			AND (
				@MatchStatusIds IS NULL
				OR ml.MatchStatus IN (
					SELECT [Value]
					FROM @tblRefResourceMatchStatus
					)
				)
		) AS t
	INNER JOIN dbo.MinorSetting AS m WITH (NOLOCK) ON t.MaxBetHDP BETWEEN ISNULL(FromMaxBet, 0)
			AND ISNULL(ToMaxBet, 99999999999)
	INNER JOIN dbo.MinorSettingDetail AS md WITH (NOLOCK) ON m.MinorSettingId = md.MinorSettingId
		AND md.MinorBettypeId = t.ParentBettypeId

	-- Return Match Setting
	SELECT mb.OWPMatchId
		,mb.ParentMatchId
		,mb.Bettype
		,mb.MinorBettypeId
		,mb.MaxBet
		,mb.Spread
		,mb.MaxBetCN88
		,mb.SpreadCN88
	FROM #tblMaxBet AS mb WITH (NOLOCK)

	-- Return TV 
	SELECT m.OWPMatchId
		,tv.TVCode
		,tv.Color
	FROM #owpMatchListByDate AS m
	INNER JOIN dbo.MatchTelevision AS mtv WITH (NOLOCK) ON m.OWPMatchId = mtv.OWPMatchId
	INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON tv.TVId = mtv.TVId
	ORDER BY tv.TVId

	-- Return Match Offer
	SELECT mf.OWPMatchId
		,r.[Value] AS MatchOfferValue
	FROM #owpMatchListByDate AS mf
	INNER JOIN dbo.MatchOfferDetail AS mo WITH (NOLOCK) ON mf.OWPMatchId = mo.OWPMatchId
	LEFT JOIN #tblMatchOfferResource AS r ON mo.MatchOfferId = r.Id
	WHERE (
			@UserId IS NULL
			OR mf.OWPMatchId IN (
				SELECT OWPMatchId
				FROM #tblMatchIdsFilterByUserId
				)
			)
		AND (
			@MatchStatusIds IS NULL
			OR mf.MatchStatus IN (
				SELECT [Value]
				FROM @tblRefResourceMatchStatus
				)
			)

	DROP TABLE #owpMatchListByDate

	DROP TABLE #tblMaxBet

	DROP TABLE #tblMatchOfferResource

	DROP TABLE #tblNoOfHDPResource

	DROP TABLE #tblMatchIdsFilterByUserId

	DROP TABLE #tblOWPMatchFilter
END