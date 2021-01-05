
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetSpread] @OwpMatchId INT
AS
/*
Created: 20201203@Carlos.Nguyen
Task: Get spread
DB: bodb_OWP

Revisions:
	20201203@Carlos.Nguyen: Get spread - [Redmine: #145096]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @HandicapHDP INT = 1
		,@OverUnderOU INT = 3
		,@1H_HandicapHDP INT = 7
		,@1H_OverUnder INT = 8
	
	SELECT ms.Bettype,
			ms.Spread
	FROM MatchSetting AS ms WITH (NOLOCK)
	WHERE ms.Bettype IN (@HandicapHDP, @OverUnderOU, @1H_HandicapHDP, @1H_OverUnder) AND ms.OWPMatchId=@OwpMatchId
 
	SELECT ol.CategoryId AS LeagueGroupId
	FROM OWPLeague AS ol WITH (NOLOCK)
		INNER JOIN OWPMatch AS om WITH (NOLOCK) ON ol.OWPLeagueId=om.OWPLeagueId
		WHERE om.OWPMatchId=@OwpMatchId
END