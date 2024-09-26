/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_LiveDetail_MatchInfo_Get] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get Match Detail Info
 DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190110@Leo.Vo: New structure of Match offer - [Redmine: #107257]
	20190116@Kane.Le: Get Column NoOfHDPId - [Redmine: #107257]
	20190813@Tyler.Dang: Add more info to edit Event - [Redmine: #118562]
	20191217@Leo.Vo: Change Market column - [Redmine: #124448]
	20200723@Esther.Nguyen: Build Home name (N) - [Redmind: #137417]
	20200729@Carlos.Nguyen: Update data Streaming sync from InfoSite - [Redmind: #137755]
	20231026@los: sync round - [Redmine: #193810]
*/
BEGIN
	SET NOCOUNT ON

	SELECT l.OWPLeagueName AS LeagueName
		,(CASE WHEN om.IsNeutral = 1 THEN home.OWPTeamName + ' (N)' ELSE home.OWPTeamName END) AS HomeName 
		,away.OWPTeamName AS AwayName
		,om.MatchNo
		,om.EventDate
		,(om.EventDate + CAST(om.KickOffTime AS DATETIME)) AS KickOffTime
		,mi.Channel
		,mi.IPTV AS IpTv
		,mi.WB
		,mi.Phone
		,mi.Remark
		,mi.IsSelected		
		,mi.NoOfHDPId
		,mi.[Round]
		,mi.IsSoloMatch
		,mi.Division
		,mi.Venue
		,om.OtherTime
		,r.Value AS LeagueCategoryName
		,om.InfoSiteMatchId
		,mi.MatchStatus
		,mi.Website1
		,mi.Website2
		,mi.Website3
		,mi.Website4
		,mi.Market
		,minor.MinorBettypeId
		,minor.ParentMatchId
		,main.MatchStatus AS ParentMatchStatus
		,@OWPMatchId AS OWPMatchId
		,om.TeamRound
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON minor.MinorMatchId = om.OWPMatchId
		LEFT JOIN dbo.MatchInfo AS main WITH (NOLOCK) ON main.OWPMatchId = minor.ParentMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = om.OWPMatchId
		LEFT JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueId = om.OWPLeagueId
		LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = om.OWPHomeId
		LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = om.OWPAwayId
		LEFT JOIN dbo.RefResource AS r WITH (NOLOCK) ON l.CategoryId = r.ResourceId
		AND r.RefName = 'LeagueCategory'
	WHERE om.OWPMatchId = @OWPMatchId
END