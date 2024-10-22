
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchNotification_QueryInfoSiteMatchesByDate] @EventFromDateTime DATETIME, 
                                                                            @EventToDateTime   DATETIME
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
        DECLARE @EventDate DATE= @EventFromDateTime;

        -- select from infosite match
        SELECT DISTINCT
               m.InfoSiteMatchId, 
               m.LeagueName, 
               m.HomeName, 
               m.AwayName, 
               m.EventDateTime,
               l.PreMatchLeagueId
        FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] l WITH(NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
        WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
              AND l.EventDate = @EventDate;
    END;