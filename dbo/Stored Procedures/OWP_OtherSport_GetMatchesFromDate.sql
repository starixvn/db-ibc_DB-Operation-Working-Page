
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OtherSport_GetMatchesFromDate] @EventDate DATETIME
AS

/*    
 Created: 20220112@Tyler
 Task : sync matches from adminsite
 DB: bodb_OWP    
    
 Revisions:
	20220112@Tyler: Initial SP - [Redmine: #167315]
	20220419@Mira: Get offerLive - [Redmine: #171515]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT m.OSMatchId, 
               m.AdminSiteMatchId, 
               l.LeagueName, 
               m.HomeName, 
               m.AwayName, 
               m.Sport, 
               m.EventDate, 
               m.OfferLiveStatus
        FROM dbo.OSMatch m WITH(NOLOCK)
             INNER JOIN OSLeague l WITH(NOLOCK) ON m.LeagueId = l.OSLeagueId
        WHERE m.EventDateTime >= @EventDate;
    END;