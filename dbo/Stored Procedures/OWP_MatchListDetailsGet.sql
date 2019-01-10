/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MatchListDetailsGet] @EventDate DATE
AS
/*
 Created: 20161018@Julien
 Task : get match list
 DB: bodb_OWP

 Revisions:
    20161226@Julien: Modify timezone of GlobalShowTime
    20170725@Tim.Trinh: get IsCanceled, Round, OutSite, Remark, NoHDP, MatchOffer
    20171012@Tim.Trinh: get OtherTime, Website, Website2, Website3, Website4
    20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
	20180618@Leo: New structure of event assignment - [Redmine: #92868]
	20181031@Raymond.Le: Replace column MatchId by InfoSiteMatchId - [Redmine: #104052]
	20181205@Raymond.Le: Implement page Event Assignment - [Redmine: #105667]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')
		,@BettypeHDP INT = 1
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = -89

	-- Match ID List by Date
	CREATE TABLE #owpMatchListByDate (
		OWPMatchId INT
		,MatchNo NVARCHAR(50)
		,EventDate DATE
		,KickOffTime TIME(7)
		,OtherTime TIME(7)
		,OWPLeagueId INT
		,OWPHomeId INT
		,OWPAwayId INT
		,MatchId INT
		,NoOfHDP NVARCHAR(20)
		,TVCode NVARCHAR(MAX)
		,Channel NVARCHAR(200)
		,WatchBet NVARCHAR(200)
		,Agent NVARCHAR(200)
		,OtherProvider NVARCHAR(200)
		,[Provider] NVARCHAR(200)
		,Phone NVARCHAR(100)
		,[Round] NVARCHAR(2000)
		,OutSide NVARCHAR(2000)
		,Remark NVARCHAR(2000)
		,MatchOffer NVARCHAR(50)
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
		,KickOffTime
		,OtherTime
		,OWPLeagueId
		,OWPHomeId
		,OWPAwayId
		,MatchId
		,NoOfHDP
		,TVCode
		,Channel
		,WatchBet
		,Agent
		,OtherProvider
		,[Provider]
		,Phone
		,[Round]
		,OutSide
		,Remark
		,MatchOffer
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
		,om.KickOffTime
		,om.OtherTime
		,om.OWPLeagueId
		,om.OWPHomeId
		,om.OWPAwayId
		,om.MatchId
		,mi.NoOfHDP
		,mi.TVCode
		,mi.Channel
		,mi.WB
		,mi.Agent
		,mi.OtherProvider
		,mi.[Provider]
		,mi.Phone
		,mi.[Round]
		,mi.Division
		,mi.Remark
		,mi.KOTimeRemark
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
	WHERE om.EventDateTime BETWEEN @FromDate
			AND @ToDate
		AND mi.IsSelected = 1
		AND (
			minor.IsRepresented = 1
			OR minor.IsRepresented IS NULL
			)

	-- Return Matches info
	SELECT ml.OWPMatchId
		,ml.MatchNo
		,ml.KickOffTime
		,ml.OtherTime
		,l.OWPLeagueName AS League
		,h.OWPTeamName AS Home
		,a.OWPTeamName AS Away
		,ml.NoOfHDP
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.TVCode AS VARCHAR), '')
				FROM dbo.Television rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(ml.TVCode, ',') f
				WHERE f.val = rs.TVId
				FOR XML PATH('')
				), 1, 2, '') AS TV
		,ml.Channel
		,ml.WatchBet
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.AgentName AS VARCHAR), '')
				FROM dbo.Agent rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(ml.Agent, ',') f
				WHERE f.val = rs.AgentId
				FOR XML PATH('')
				), 1, 2, '') AS Agent
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.OtherProviderName AS VARCHAR), '')
				FROM dbo.OtherProvider rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(ml.OtherProvider, ',') f
				WHERE f.val = rs.OtherProviderId
				FOR XML PATH('')
				), 1, 2, '') AS OtherProvider
		,STUFF((
				SELECT ', ' + ISNULL(CAST(rs.ProviderName AS VARCHAR), '')
				FROM dbo.[Provider] rs WITH (NOLOCK)
					CROSS APPLY dbo.fnc_SplitStrings(ml.[Provider], ',') f
				WHERE f.val = rs.ProviderId
				FOR XML PATH('')
				), 1, 2, '') AS [Provider]
		,ml.Phone
		,ml.[Round]
		,ml.OutSide
		,ml.Remark
		,ml.MatchOffer
		,ml.Website
		,ml.Website2
		,ml.Website3
		,ml.Website4
		,ml.MatchStatus
		,ml.IsMinorMatch
		,ml.MinorBettypeId
		,ml.ParentMatchId
		,ml.InfoSiteMatchId
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
		INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId
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

	-- Return assignment for LIVE assignment uploading
	SELECT a.OWPMatchId
		,a.Bettype
		,ml.MinorBettypeId
		,a.UserId
		,(CASE 
			WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
			ELSE u.Username END
			) AS Username
		,a.AssignmentType
		,a.AssignmentNote
		,ml.ParentMatchId
		,a.AssignmentId
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN #owpMatchListByDate AS ml WITH (NOLOCK) ON a.OWPMatchId = ml.owpmatchid
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	WHERE ml.IsMinorMatch = 0

	UNION 
	SELECT ml.OWPMatchId
		,mb.InheritedBettypeId AS Bettype
		,ml.MinorBettypeId
		,a.UserId
		,(CASE 
			WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
			ELSE u.Username END
			) AS Username
		,a.AssignmentType
		,a.AssignmentNote
		,ml.ParentMatchId
		,a.AssignmentId
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
	INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.IsActive = 1 AND mb.ParentBettypeId = ml.MinorBettypeId
	LEFT JOIN dbo.Assignment AS a WITH (NOLOCK)	ON a.OWPMatchId = ml.OWPMatchId AND a.Bettype = mb.InheritedBettypeId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	WHERE ml.IsMinorMatch = 1


	-- Return notes
	SELECT mn.OWPMatchId
		,mn.Note AS Note
	FROM dbo.MatchNote AS mn WITH (NOLOCK)
		INNER JOIN #owpMatchListByDate AS ml WITH (NOLOCK) ON mn.OWPMatchId = ml.owpmatchid

	-- Get maxbet
	CREATE TABLE #tblMaxBet (
		OWPMatchId INT
		,ParentMatchId INT
		,Bettype INT
		,MinorBettypeId INT
		,MaxBet MONEY
		,Spread MONEY
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
				FROM #tblMaxBet WITH (NOLOCK)
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
	FROM #tblMaxBet AS mb WITH (NOLOCK)

	-- Return TV 
	SELECT m.OWPMatchId
		,tv.TVCode
		,tv.Color
	FROM #owpMatchListByDate AS m
		CROSS APPLY dbo.fnc_SplitStrings(m.TVCode, ',') AS f
		INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON tv.TVId = f.val
	ORDER BY tv.TVId

	DROP TABLE #owpMatchListByDate

	DROP TABLE #tblMaxBet
END