CREATE PROCEDURE [dbo].[OWP_LiveDetailRecommendOddsGet] @OWPMatchId INT
AS
/*    
 Created: 2016-10-07@John    
 Task : Get new Match Detail RecommendOdds    
 DB: bodb_OWP    
  
 Revisions:       
 */
BEGIN
	SET NOCOUNT ON

	SELECT mr.bettype AS BettypeId
		,h.OWPTeamName AS Homename
		,a.OWPTeamName AS AwayName
		,mr.HDP AS Handicap
		,(
			SELECT STUFF((
						SELECT ',' + CONVERT(VARCHAR(100), a.Choice) + ':' + CONVERT(VARCHAR(100), a.Odds)
						FROM dbo.MatchRecommendOdds AS a WITH (NOLOCK)
						WHERE a.bettype = mr.bettype
							AND a.HDP = mr.HDP
							AND a.OWPMatchId = @OWPMatchId
						FOR XML PATH('')
						), 1, 1, '')
			) AS Odds
	FROM dbo.MatchRecommendOdds AS mr WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON m.OWPMatchId = mr.OWPMatchId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
	WHERE mr.OWPMatchId = @OWPMatchId
		AND mr.HDP IS NOT NULL
	GROUP BY mr.bettype
		,mr.HDP
		,h.OWPTeamName
		,a.OWPTeamName
END