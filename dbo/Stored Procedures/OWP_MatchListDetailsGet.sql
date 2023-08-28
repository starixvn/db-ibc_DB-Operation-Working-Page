/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_MatchListDetailsGet] @EventDate DATE, @MatchStatusIds VARCHAR(MAX)
AS;
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
	20190110@Leo.Vo: New structure of Match offer - [Redmine: #107257]
	20190116@Kane.Le: Get NoOfHDP Id - [Redmine: #107257]
	20190506@Leo.Vo: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
	20190510@Kane.Le: Change phone length 200 - [Redmine: #112918]
	20190521@Lita.Tang: Add Username value - [Feature: #113765]
	20190715@Leo.Vo: Add maxbet/spread CN88 - [Redmine: #116688]
	20191022@Leo.Vo: Change Provider, OtherProvider - [Feature: #122194]
	20200610@Jack.Nguyen: add EventDateTime @MatchStatusIds- [Feature: #135525]
	20200713@Tyler.Dang: sort follow MatchNo - [Feature: #137416]
	20200713@Esther.Nguyen: Importing match in Neutral Stadium - [Redmine: #137417]
	20200729@Jack.Nguyen: get IPTV, MatchId  - [Redmine: #137756]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
	20211122@Liam.Pham: add filter sync live status  - [Redmine: #159109]
	20230815@Liam:  Assigned AIO bettype - [Redmine: #191226]
*/
BEGIN
	SET NOCOUNT ON

DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00'), @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59'), @BettypeHDP INT= 1, @Specific15Mins INT= -1, @Specific10Mins INT= -2, @Specific15MinsNoOfCorners INT= -5, @Specific15MinsTotalBooking INT= -8, @FastMarket INT= -88, @AllInOne INT= -89, @AllInOneTotalBookings INT= -189, @AllInOneCorners INT= -289, @FastMarketTotalBookings INT= -188, @FastMarketCorners INT= -288, @MatchStatusText NVARCHAR(100);

	DECLARE @tblRefResourceMatchStatus TABLE
	(Id    INT NOT NULL, 
	 Value NVARCHAR(50) NOT NULL
	);
	INSERT INTO @tblRefResourceMatchStatus
	(Id, 
	 Value
	)
		   SELECT ResourceId, 
				  Value
		   FROM dbo.RefResource WITH(NOLOCK)
		   WHERE RefName = 'MatchStatus'
				 AND (ISNULL(@MatchStatusIds, '') = ''
					  OR ResourceId IN
		   (
			   SELECT val
			   FROM dbo.fnc_SplitStrings(@MatchStatusIds, ',')
		   ));
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
		,IPTV NVARCHAR(200)
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
		,IsNeutral BIT
		,IsLive           BIT
		,ParentInfoSiteId INT 
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
		,IPTV
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
		,IsNeutral
		,IsLive
		,ParentInfoSiteId
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
		,mi.IPTV
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
		,om.IsNeutral
		,CASE
            WHEN mi.MatchStatus IN('Live', 'Postponed')
            THEN 1
            ELSE 0
            END AS IsLive   
		,CASE
            WHEN minor.ParentMatchId IS NULL
            THEN om.InfoSiteMatchId
            ELSE mp.InfoSiteMatchId
            END
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
		LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
		LEFT JOIN dbo.OWPMatch mp WITH(NOLOCK) ON mp.OWPMatchId = minor.ParentMatchId
		LEFT JOIN #tblNoOfHDPResource AS r ON mi.NoOfHDPId = r.Id
	WHERE om.EventDateTime BETWEEN @FromDate
			AND @ToDate
		AND mi.IsSelected = 1
		AND (
			minor.IsRepresented = 1
			OR minor.IsRepresented IS NULL
			)

	DELETE t
	FROM #owpMatchListByDate t
	WHERE NOT EXISTS(SELECT 1 FROM @tblRefResourceMatchStatus ms WHERE t.MatchStatus = ms.[Value])
	
	-- Return Matches info
	SELECT ml.OWPMatchId
		,ml.MatchNo
		,ml.KickOffTime
		,ml.OtherTime
		,ml.MatchId
		,l.OWPLeagueName AS League
		,(CASE WHEN ml.IsNeutral = 1 THEN h.OWPTeamName + ' (N)' ELSE h.OWPTeamName END) AS Home 
		,a.OWPTeamName AS Away
		,ref.[Value] AS NoOfHDP
		,ml.NoOfHDPId
		,STUFF((
				SELECT ', ' + rs.TVCode
				FROM dbo.Television AS rs WITH (NOLOCK)
					INNER JOIN dbo.MatchTelevision AS mtv WITH (NOLOCK) ON rs.TVId = mtv.TVId
				WHERE mtv.OWPMatchId = ml.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS TV
		,ml.Channel
		,ml.IPTV
		,ml.WatchBet
		,STUFF((
				SELECT ', ' + rs.AgentName
				FROM dbo.Agent AS rs WITH (NOLOCK)
					INNER JOIN dbo.MatchAgent AS ma WITH (NOLOCK) ON rs.AgentId = ma.AgentId
				WHERE ma.OWPMatchId = ml.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS Agent
		,STUFF((
				SELECT ', ' + rs.OtherProviderName
				FROM dbo.OtherProvider AS rs WITH (NOLOCK)
					INNER JOIN dbo.MatchOtherProvider AS mot WITH (NOLOCK) ON rs.OtherProviderId = mot.OtherProviderId
				WHERE mot.OWPMatchId = ml.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS OtherProvider
		,STUFF((
				SELECT ', ' + rs.ProviderName
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
		,ml.Website
		,ml.Website2
		,ml.Website3
		,ml.Website4
		,ml.MatchStatus
		,ml.IsMinorMatch
		,ml.MinorBettypeId
		,ml.ParentMatchId
		,ml.InfoSiteMatchId
		,ml.EventDate
		,ml.EventDateTime
		,ml.IsLive 
		,imn.AdminSiteMatchId 'ParentAdminSiteId'
	FROM #owpMatchListByDate AS ml WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
		INNER JOIN dbo.OWPMatch AS ma WITH (NOLOCK) ON ml.ParentMatchId = ma.OWPMatchId
		LEFT JOIN dbo.InfoSiteMatch AS imn WITH(NOLOCK) 
				ON ml.ParentInfoSiteId = imn.InfoSiteMatchId AND imn.IsDeleted = 0
		LEFT JOIN #tblNoOfHDPResource ref ON ml.NoOfHDPId = ref.Id
	WHERE (
			ml.MinorBettypeId NOT IN (@Specific15Mins, @Specific10Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne,@AllInOneTotalBookings, @AllInOneCorners,@FastMarketTotalBookings, @FastMarketCorners )
			OR ml.MinorBettypeId IS NULL
			)
	ORDER BY ml.MatchNo
		,ma.EventDate
		,ma.KickOffTime
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
		,Spread SMALLMONEY
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
		INNER JOIN dbo.MatchTelevision AS mtv WITH (NOLOCK) ON m.OWPMatchId = mtv.OWPMatchId
		INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON tv.TVId = mtv.TVId
	ORDER BY tv.TVId

	-- Return Match Offer
	SELECT mf.OWPMatchId
		,r.[Value] AS MatchOfferValue
	FROM #owpMatchListByDate AS mf
		INNER JOIN dbo.MatchOfferDetail AS mo WITH (NOLOCK) ON mf.OWPMatchId = mo.OWPMatchId
		LEFT JOIN #tblMatchOfferResource AS r ON mo.MatchOfferId = r.Id

	DROP TABLE #owpMatchListByDate

	DROP TABLE #tblMaxBet

	DROP TABLE #tblMatchOfferResource

	DROP TABLE #tblNoOfHDPResource
END
