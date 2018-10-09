/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EventMgt_MatchLinking] 
AS
/*    
 Created: 20161004@Julien
 Task : OWP
 DB: bodb_OWP    
    
 Revisions:
	20180928@Leo: review
*/
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #owpunlinkedmatch (
		owpmatchid INT
		,eventdate DATETIME
		,owpleagueid INT
		,owphomeid INT
		,owpawayid INT
		)

	CREATE TABLE #owpmatchlist (
		owpmatchid INT
		,owpeventdate DATETIME
		,owpleaguename NVARCHAR(2000)
		,owphometeam NVARCHAR(200)
		,owpawayteam NVARCHAR(200)
		,matchid INT
		)

	INSERT INTO #owpunlinkedmatch (
		owpmatchid
		,eventdate
		,owpleagueid
		,owphomeid
		,owpawayid
		)
	SELECT m.OWPMatchId
		,m.EventDate
		,m.OWPLeagueId
		,m.OWPHomeId
		,m.OWPAwayId
	FROM OWPMatch m WITH (NOLOCK)
	WHERE m.MatchId IS NULL

	INSERT INTO #owpmatchlist (
		owpmatchid
		,owpeventdate
		,owpleaguename
		,owphometeam
		,owpawayteam
		)
	SELECT m.OWPMatchId
		,m.EventDate
		,l.OWPLeagueName
		,h.OWPTeamName
		,a.OWPTeamName
	FROM #owpunlinkedmatch m WITH (NOLOCK)
		INNER JOIN OWPLeague l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
		INNER JOIN OWPTeam h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
		INNER JOIN OWPTeam a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId

	UPDATE om
	SET matchid = m.matchid
	FROM #owpmatchlist om WITH (NOLOCK)
		INNER JOIN bodb02.dbo.league l WITH (NOLOCK) ON l.leaguename = om.owpleaguename
		INNER JOIN bodb02.dbo.Team h WITH (NOLOCK) ON h.teamname = om.owphometeam
		INNER JOIN bodb02.dbo.Team a WITH (NOLOCK) ON a.teamname = om.owpawayteam
		INNER JOIN bodb02.dbo.match m WITH (NOLOCK) ON m.eventdate = om.owpeventdate
		AND m.leagueid = l.leagueid
		AND m.homeid = h.teamid
		AND m.awayid = a.teamid
	WHERE m.sporttype = 1
		AND m.matchcode NOT LIKE '%hedge%'
		AND m.matchcode NOT LIKE '%pen%'
		AND m.eventstatus <> 'Completed'
		AND m.sporttype = 1

	UPDATE om WITH (ROWLOCK, UPDLOCK)
	SET om.MatchId = ml.matchid
	FROM owpmatch om
		INNER JOIN #owpmatchlist ml WITH (NOLOCK) ON om.OWPMatchId = ml.owpmatchid
	WHERE ml.matchid IS NOT NULL

	DROP TABLE #owpunlinkedmatch

	DROP TABLE #owpmatchlist
END