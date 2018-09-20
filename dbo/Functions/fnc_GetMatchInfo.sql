CREATE FUNCTION [dbo].[fnc_GetMatchInfo] (@OWPMatchId INT)
RETURNS TABLE

/*
Created: 20161228@Quinn.Vo
Task : get info of match.
DB: bodb_OWP

Param's Explanation:

Revisions:
 
*/
AS
RETURN (
		SELECT @OWPMatchId AS OWPMatchId
			,CASE 
				WHEN m.matchid IS NULL THEN ma.EventDate
				ELSE m.eventdate
				END AS EventDate
			,CASE 
				WHEN m.matchid IS NULL THEN ma.KickOffTime
				ELSE m.kickofftime
				END AS KickOffTime
			,CASE 
				WHEN m.matchid IS NULL THEN lg.OWPLeagueName
				ELSE l.leaguename
				END AS League
			,CASE 
				WHEN m.matchid IS NULL THEN ht.OWPTeamName
				ELSE h.teamname
				END AS HomeTeam
			,CASE 
				WHEN m.matchid IS NULL THEN at.OWPTeamName
				ELSE a.teamname
				END AS AwayTeam
			,ma.matchid AS MatchId
		FROM dbo.OWPMatch AS ma WITH (NOLOCK)
			INNER JOIN dbo.OWPLeague AS lg WITH (NOLOCK) ON ma.OWPLeagueId = lg.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ma.OWPHomeId = ht.OWPTeamId
			INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ma.OWPAwayId = at.OWPTeamId
			LEFT JOIN bodb02.dbo.match AS m WITH (NOLOCK) ON m.MatchId = ma.MatchId
			LEFT JOIN bodb02.dbo.league AS l WITH (NOLOCK) ON m.leagueid = l.leagueid
			LEFT JOIN bodb02.dbo.Team AS h WITH (NOLOCK) ON m.homeid = h.teamid
			LEFT JOIN bodb02.dbo.Team AS a WITH (NOLOCK) ON m.awayid = a.teamid
		WHERE ma.OWPMatchId = @OWPMatchId
		)