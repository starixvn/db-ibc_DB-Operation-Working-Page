/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchInfo_Get] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get Match Detail Info
 DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190110@Leo.Vo: New structure of Match offer - [Redmine: #107257]
*/
BEGIN
	SET NOCOUNT ON

	SELECT l.OWPLeagueName AS LeagueName
		,home.OWPTeamName AS HomeName
		,away.OWPTeamName AS AwayName
		,om.MatchNo
		,om.EventDate
		,(om.EventDate + om.KickOffTime) AS KickOffTime
		,mi.Channel
		,mi.WB
		,mi.Phone
		,mi.Remark
		,mi.IsSelected
		,mi.NoOfHDP
		,mi.[Round]
		,mi.IsSoloMatch
		,mi.[Round]
		,mi.Division
		,mi.Venue
		,(om.EventDate + om.OtherTime) AS OtherTime
		,r.Value AS LeagueCategoryName
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = om.OWPMatchId
		LEFT JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueId = om.OWPLeagueId
		LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = om.OWPHomeId
		LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = om.OWPAwayId
		LEFT JOIN dbo.RefResource AS r WITH (NOLOCK) ON l.CategoryId = r.ResourceId
		AND r.RefName = 'LeagueCategory'
	WHERE om.OWPMatchId = @OWPMatchId


END