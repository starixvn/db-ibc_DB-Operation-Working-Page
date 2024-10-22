/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_RecommendOdds_GetByMatchId] @OWPMatchId INT
AS
/*    
 Created: 20180908@Leo
 Task : Get RecommendOdds    
 DB: bodb_OWP    
  
 Revisions:       
 20180310@Kane.Le: Get MatchRecommendOddsDetail - [Redmine: #92868]
 */
BEGIN
	SET NOCOUNT ON

		SELECT mr.MatchRecommendOddsId AS Id
		,mr.OWPMatchId
		,mr.Bettype
		,mr.HDP  
		,mr.TeamChoice
		,mrd.Choice
		,mrd.Odds
	FROM MatchRecommendOdds AS mid WITH (NOLOCK)
		INNER JOIN dbo.MatchRecommendOdds AS mr WITH (NOLOCK) ON mid.OWPMatchId = mr.OWPMatchId
		INNER JOIN dbo.MatchRecommendOddsDetail AS mrd WITH (NOLOCK) ON mr.MatchRecommendOddsId = mrd.MatchRecommendOddsId
	WHERE mr.OWPMatchId = @OWPMatchId
	ORDER BY mr.MatchRecommendOddsId
END