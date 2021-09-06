/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_EventPicking_GetLeagueSetting]
AS
/*  
 Created: Jack.Nguyen@20200707
 Task : Get All LeagueSetting
 DB: bodb_OWP

 Revisions:
	20200707@Jack.Nguyen: Initial SP - [Redmine: #134339]
	2020080407@carlos.Nguyen: Export picking priority - [Redmine: #150269]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
*/
   

SELECT ls.LeagueSettingId, 
       l.OWPLeagueName AS LeagueName, 
	   ls.Remark, 
       ls.LSTNote,
       ls.Division, 
       ls.Round, 
       ls.HasTV, 
	   ls.Spread_HDP, 
	   ls.Spread_OU,
	   
       ls.MaxbetWD_MatchOffer, 
       ls.MaxbetWD_HDP, 
       ls.MaxbetWD_OU, 
       ls.MaxbetWD_NoOfHDP,
	   
	    -- new
	   ls.MaxbetWD_1H AS MaxbetWD_1HHDP,
	   ls.MaxbetWD_1H AS MaxbetWD_1HOU,
	   
	   ls.MaxbetWK_1H AS MaxbetWK_1HHDP,
	   ls.MaxbetWK_1H AS MaxbetWK_1HOU,
	   
	   ls.Spread_1HHDP,
	   ls.Spread_1HOU,
	   ls.MaxBet_FT1X2,
	   ls.MaxBet_1X2Spread,
	   ls.MaxBet_1H1X2,
	   --new
	   
	   l.IsBlackList,
       ls.MaxbetWK_MatchOffer, 
       ls.MaxbetWK_HDP, 
       ls.MaxbetWK_OU, 
       ls.MaxbetWK_NoOfHDP,
	   ls.FullConditionDescription
FROM OWPLeague AS l WITH(NOLOCK)
     INNER JOIN dbo.[NewLeagueSetting] AS ls WITH(NOLOCK) ON ls.OWPLeagueId = l.OWPLeagueId
ORDER BY l.OWPLeagueName;