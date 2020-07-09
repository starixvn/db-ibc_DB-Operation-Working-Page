/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EventPicking_GetLeagueSetting]
AS
/*  
 Created: Jack.Nguyen@20200707
 Task : Get All LeagueSetting
 DB: bodb_OWP

 Revisions:
	20200707@Jack.Nguyen: Initial SP - [Redmine: #134339]
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
	   ls.CN88Spread_HDP, 
	   ls.CN88Spread_OU,
	   

       ls.MaxbetWD_MatchOffer, 
       ls.MaxbetWD_HDP, 
       ls.MaxbetWD_OU, 
       ls.MaxbetWD_NoOfHDP, 
       ls.CN88MaxbetWD_MatchOffer, 
       ls.CN88MaxbetWD_HDP, 
       ls.CN88MaxbetWD_OU,
       ls.CN88MaxbetWD_NoOfHDP,
	   
       ls.MaxbetWK_MatchOffer, 
       ls.MaxbetWK_HDP, 
       ls.MaxbetWK_OU, 
       ls.MaxbetWK_NoOfHDP, 
       ls.CN88MaxbetWK_MatchOffer, 
       ls.CN88MaxbetWK_HDP, 
       ls.CN88MaxbetWK_OU, 
       ls.CN88MaxbetWK_NoOfHDP
FROM OWPLeague AS l WITH(NOLOCK)
     INNER JOIN dbo.[NewLeagueSetting] AS ls WITH(NOLOCK) ON ls.OWPLeagueId = l.OWPLeagueId
ORDER BY l.OWPLeagueName;