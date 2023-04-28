/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Get] @Date DATE
	,@League NVARCHAR(500) = ''
	,@MatchStatusIds NVARCHAR(20) = ''
	,@IsExcludeSpecialProducts BIT = 0
AS
/*          
 Created: 20170317@Alvin.Nguyen
 Task : get odds compiler
 DB: bodb_OWP
          
 Revisions:
    20170421@Tim.Trinh: refactor code
	20180131@Raymone.Le: show match when match status is Live
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181120@Raymond.Le: Add more info to Odds Compiler - [Redmine: #105043]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
	20190513@Kane.Le: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
	20191024@Kane.Le: Get Provider/Other Provider - [Redmine: #122194]
	20191105@Tyler.Dang: Add OherTime, MatchStatus, MB and Spread CN88, Markets - [Redmine: #123331]
	20191111@Kane.Le: Get All Bettype - [Redmine: #123331]
	20191218@Kane.Le: Get WatchBet - [Redmine: #124448]
	20200609@Tyler.Dang: Get match television - [Redmine: #135526]
	20200713@Carlos.Nguyen: Build HomeName - [Redmine: #137417]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
	20230420@Johnny: Get ParentMatchId - [Feature: #185886]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @Date), '11:59:59')
		,@BettypeHDP INT = 1
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
	
	DECLARE @tblMatchStatus TABLE (Value NVARCHAR(50) NOT NULL)
	INSERT INTO @tblMatchStatus (
		[Value]
		)
	SELECT [Value]
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MatchStatus'
		AND ResourceId IN (
			SELECT val
			FROM dbo.fnc_SplitStrings(@MatchStatusIds, ',')
			)
	
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

	CREATE TABLE #tblMatch (
		OWPMatchId INT
		,OWPLeagueId INT
		,MatchStatus NVARCHAR(15)
		,IsMinorMatch BIT
		,MinorBettypeId INT
		,ParentMatchId INT
		)

	INSERT INTO #tblMatch (
		OWPMatchId
		,OWPLeagueId
		,MatchStatus
		,IsMinorMatch
		,MinorBettypeId
		,ParentMatchId
		)
	SELECT om.OWPMatchId
		,om.OWPLeagueId
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
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
	LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
	WHERE (om.EventDateTime BETWEEN @FromDate AND @ToDate)
		AND (minor.MinorBettypeId IS NULL OR minor.MinorBettypeId NOT IN (
				@Specific15Mins
				,@Specific10Mins
				,@Specific15MinsNoOfCorners
				,@Specific15MinsTotalBooking
				,@FastMarket
				,@AllInOne)
			)
		AND (@IsExcludeSpecialProducts = 0 OR minor.MinorMatchId IS NULL)
	
	CREATE TABLE #tblFilterMatch (
		OWPMatchId INT
	)
	
	INSERT INTO #tblFilterMatch (OWPMatchId)
	SELECT m.OWPMatchId
	FROM #tblMatch AS m
	INNER JOIN dbo.OWPLeague AS l ON l.OWPLeagueId = m.OWPLeagueId
	INNER JOIN @tblMatchStatus AS ms ON m.MatchStatus = ms.Value
	WHERE ISNULL(@League, '') = '' OR l.OWPLeagueName LIKE + '%' + @League + '%'

	-- Return Matches info
	SELECT m.OWPMatchId
		,m.MatchNo
		,m.EventDate
		,m.KickOffTime
		,l.OWPLeagueName AS League
		,(CASE
			WHEN m.IsNeutral=1 THEN h.OWPTeamName+' (N)'
			ELSE h.OWPTeamName
			END) AS Home
		,a.OWPTeamName AS Away
		,mi.Remark
		,mi.[Round]
		,mi.Division
		,mi.Market
		,mi.Channel
		,r.Value AS 'NoOfHDP'
		,STUFF((
				SELECT ', ' + rs.ProviderName
				FROM dbo.[Provider] rs WITH (NOLOCK)
					INNER JOIN dbo.MatchProvider AS f WITH (NOLOCK) ON rs.ProviderId = f.ProviderId
				WHERE m.OWPMatchId = f.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS 'Provider'
		,STUFF((
				SELECT ', ' + rs.OtherProviderName
				FROM dbo.OtherProvider rs WITH (NOLOCK)
					INNER JOIN dbo.MatchOtherProvider AS f WITH (NOLOCK) ON rs.OtherProviderId = f.OtherProviderId
				WHERE m.OWPMatchId = f.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS 'OtherProvider'
		,STUFF((
				SELECT ', ' + rs.TVCode
				FROM dbo.Television rs WITH (NOLOCK)
					INNER JOIN dbo.MatchTelevision AS f WITH (NOLOCK) ON rs.TVId = f.TVId
				WHERE m.OWPMatchId = f.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS 'TVCode'
		,STUFF((
				SELECT ', ' + rs.Value
				FROM dbo.RefResource rs WITH (NOLOCK)
					INNER JOIN dbo.MatchOfferDetail AS f WITH (NOLOCK) ON rs.ResourceId = f.MatchOfferId AND rs.RefName = 'MatchOffer'
				WHERE m.OWPMatchId = f.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS 'MatchOffer'
		,mi.WB AS WatchBet
		,mi.Website1
		,mi.Website2
		,mi.Website3
		,mi.Website4
		,m.OtherTime
		,m1.MatchStatus
		,m.InfoSiteMatchId AS 'InfoSiteID'
		,m1.ParentMatchId
		,(CASE WHEN m.InfoSiteMatchId IS NULL THEN NULL ELSE CASE WHEN im.InfoSiteMatchId IS NULL THEN 0 ELSE 1 END END) AS IsInfoSiteLinked
	FROM dbo.OWPMatch AS m
	INNER JOIN #tblMatch AS m1 ON m.OWPMatchId = m1.OWPMatchId
	INNER JOIN #tblFilterMatch AS m2 ON m1.OWPMatchId = m2.OWPMatchId
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
	LEFT JOIN dbo.RefResource as r WITH(NOLOCK) ON r.ResourceId = mi.NoOfHDPId AND r.RefName = 'NoOfHDP'
	LEFT JOIN dbo.InfoSiteMatch as im WITH (NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
	ORDER BY m.EventDate
		,m.KickOffTime
		,m.MatchNo
		,l.OWPLeagueName
		,h.OWPTeamName
		,m1.ParentMatchId
		,m1.IsMinorMatch

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
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,ms.Bettype
		,m.MinorBettypeId
		,ms.Maxbet
		,ms.Spread
		,1
	FROM #tblMatch AS m
	INNER JOIN #tblFilterMatch AS fm ON m.OWPMatchId = fm.OWPMatchId
	INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
			
	-- league setting
	INSERT INTO #tblMaxBet (
		OWPMatchId
		,ParentMatchId
		,LeagueId
		,Bettype
		,IsMatchSetting
		)
	SELECT m.OWPMatchId
		,m.ParentMatchId
		,m.OWPLeagueId
		,ls.Bettype
		,0
	FROM #tblMatch AS m
	INNER JOIN #tblFilterMatch AS fm ON m.OWPMatchId = fm.OWPMatchId
	INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON m.OWPLeagueId = ls.LeagueId
	WHERE m.OWPMatchId NOT IN (
			SELECT OWPMatchId
			FROM #tblMaxBet WITH (NOLOCK)
			)
		AND m.IsMinorMatch = 0
	GROUP BY m.OWPMatchId
		,m.OWPLeagueId
		,ls.Bettype
		,m.ParentMatchId

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
		SELECT m.OWPMatchId
			,m.ParentMatchId
			,mbt.ParentBettypeId
			,mbt.InheritedBettypeId
			,m.MinorBettypeId
			,CASE 
				WHEN mst.OWPMatchId IS NULL
					THEN dbo.OWP_MaxBetGet(minor.ParentMatchId, m.OWPLeagueId, @BettypeHDP)
				ELSE mst.Maxbet
				END AS MaxBetHDP
		FROM #tblMatch AS m
		INNER JOIN #tblFilterMatch AS fm ON m.OWPMatchId = fm.OWPMatchId
		INNER JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON m.OWPMatchId = minor.MinorMatchId
		INNER JOIN dbo.MinorBettype AS mbt WITH (NOLOCK) ON minor.MinorBettypeId = mbt.ParentBettypeId
		LEFT JOIN dbo.MatchSetting AS mst WITH (NOLOCK) ON minor.ParentMatchId = mst.OWPMatchId
			AND mst.Bettype = @BettypeHDP
		WHERE m.IsMinorMatch = 1
			AND m.OWPMatchId NOT IN (
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

	--get recommend odds
	SELECT mr.MatchRecommendOddsId AS Id
		,mr.OWPMatchId
		,mr.Bettype
		,mr.HDP
		,mr.TeamChoice
		,mrd.Choice
		,mrd.Odds
	FROM #tblFilterMatch AS fm
		INNER JOIN dbo.MatchRecommendOdds AS mr WITH (NOLOCK) ON fm.OWPMatchId = mr.OWPMatchId
		LEFT JOIN dbo.MatchRecommendOddsDetail AS mrd WITH (NOLOCK) ON mr.MatchRecommendOddsId = mrd.MatchRecommendOddsId
	ORDER BY mr.MatchRecommendOddsId
	
	DROP TABLE #tblMatch
	
	DROP TABLE #tblFilterMatch
	
	DROP TABLE #tblMaxBet
END