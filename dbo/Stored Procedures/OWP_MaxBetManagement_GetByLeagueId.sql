/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MaxBetManagement_GetByLeagueId]
	@OWPLeagueId INT
AS
/*
Created: 20200410@Tyler.Dang
Task : Get league setting
DB: bodb_OWP

Revisions:
   20200410@Tyler.Dang: Init Redmine: #132234
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT ls.LeagueSettingId
      ,ls.OWPLeagueId
	  ,ls.Category
      ,ls.TimeDesc
      ,ls.Remark
      ,ls.TV
      ,ls.HasTV
      ,ls.LSTNote
      ,ls.Spread_HDP
      ,ls.Spread_OU
      ,ls.Spread_1HHDP
      ,ls.Spread_1HOU
      ,ls.Speard_1X2
      ,ls.MaxbetWD_HDP
      ,ls.MaxbetWD_OU
      ,ls.MaxbetWD_1H
      ,ls.MaxbetWD_NoOfHDP
      ,ls.MaxbetWD_MatchOffer
      ,ls.MaxbetWK_HDP
      ,ls.MaxbetWK_OU
      ,ls.MaxbetWK_1H
      ,ls.MaxbetWK_NoOfHDP
      ,ls.MaxbetWK_MatchOffer
      ,ls.MaxBet_1X2Spread
      ,ls.MaxBet_FT1X2
      ,ls.MaxBet_1H1X2
      ,ls.MaxBet_1X2_MatchOffer
      ,ls.CN88Spread_HDP
      ,ls.CN88Spread_OU
      ,ls.CN88Spread_1HHDP
      ,ls.CN88Spread_1HOU
      ,ls.CN88MaxbetWD_HDP
      ,ls.CN88MaxbetWD_OU
      ,ls.CN88MaxbetWD_1H
      ,ls.CN88MaxbetWD_NoOfHDP
      ,ls.CN88MaxbetWD_MatchOffer
      ,ls.CN88MaxbetWK_HDP
      ,ls.CN88MaxbetWK_OU
      ,ls.CN88MaxbetWK_1H
      ,ls.CN88MaxbetWK_NoOfHDP
      ,ls.CN88MaxbetWK_MatchOffer
      ,ls.CN88MaxBet_1X2Spread
      ,ls.CN88MaxBet_FT1X2
      ,ls.CN88MaxBet_1H1X2
      ,ls.CN88MaxBet_1X2_MatchOffer
	  ,ls.IsApplied
	FROM dbo.[NewLeagueSetting] AS ls WITH (NOLOCK)
	WHERE @OWPLeagueId = ls.OWPLeagueId 
	
	SELECT ldi.LeagueSettingId
		,ldi.DivisionConditionId
		,ld.OperatorType AS Condition
		,ld.[Value]
	FROM dbo.[LeagueSettingDivisions] AS ldi WITH (NOLOCK)
		LEFT JOIN dbo.[NewLeagueSetting] AS ls WITH (NOLOCK)
			ON ls.LeagueSettingId = ldi.LeagueSettingId
		INNER JOIN dbo.[LeagueSettingDivisionCondition] AS ld WITH (NOLOCK)
			ON ld.DivisionConditionId = ldi.DivisionConditionId
	WHERE ls.OWPLeagueId = @OWPLeagueId

	SELECT lri.LeagueSettingId
		,lri.RoundConditionId
		,lr.OperatorType AS Condition
		,lr.[Value]
	FROM dbo.[LeagueSettingRounds] AS lri WITH (NOLOCK)
		LEFT JOIN dbo.[NewLeagueSetting] AS ls WITH (NOLOCK)
			ON ls.LeagueSettingId = lri.LeagueSettingId
		INNER JOIN dbo.[LeagueSettingRoundCondition] AS lr WITH (NOLOCK)
			ON lr.RoundConditionId = lri.RoundConditionId
	WHERE ls.OWPLeagueId = @OWPLeagueId
END