
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchNotification_QueryInfoSiteMatchesByDateRange] @FromDate DATETIME, 
                                                                                 @ToDate   DATETIME
AS

/*    
Created: 20210615@Tyler 
Task : Prematch Notification
DB: bodb_OWP    
    
Revisions:     
 20210615@Tyler: initial SP - [Redmine: #156321]    
*/

    BEGIN
        SET NOCOUNT ON;

        -- select from infosite match
        SELECT DISTINCT 
               m.InfoSiteMatchId, 
               m.OWPLeagueId, 
               m.LeagueName, 
               m.HomeName, 
               m.AwayName, 
               m.EventDateTime
        FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
        WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate;
    END;