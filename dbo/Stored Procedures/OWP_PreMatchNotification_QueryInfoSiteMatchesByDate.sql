
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchNotification_QueryInfoSiteMatchesByDate] @EventFromDateTime DATE, 
                                                                             @EventToDateTime   DATE
AS

/*    
Created: 20210615@Mira 
Task : Prematch Notification
DB: bodb_OWP    
    
Revisions:     
 20210615@Mira: initial SP - [Redmine: #156321]    
*/

    BEGIN
        SET NOCOUNT ON;

        -- select from infosite match
        SELECT m.InfoSiteMatchId, 
               l.PreMatchLeagueId
        FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] l WITH(NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
        WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime;
    END;