/*<info serverAlias="DBOWP-bodb_OWP" selecters="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetMatchInfo] (@OWPMatchId INT)
RETURNS TABLE

/*
Created: 20161228@Quinn.Vo
Task : get info of match.
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
 
*/
AS
RETURN (
		SELECT @OWPMatchId AS OWPMatchId
			,ma.EventDate AS EventDate
			,ma.KickOffTime AS KickOffTime
			,lg.OWPLeagueName AS League
			,ht.OWPTeamName AS HomeTeam
			,[at].OWPTeamName AS AwayTeam
			,ma.matchid AS MatchId
		FROM dbo.OWPMatch AS ma WITH (NOLOCK)
			INNER JOIN dbo.OWPLeague AS lg WITH (NOLOCK) ON ma.OWPLeagueId = lg.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ma.OWPHomeId = ht.OWPTeamId
			INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ma.OWPAwayId = [at].OWPTeamId
		WHERE ma.OWPMatchId = @OWPMatchId
		)