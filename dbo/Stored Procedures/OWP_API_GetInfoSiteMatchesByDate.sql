
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_GetInfoSiteMatchesByDate] @EventDate DATETIME
AS

/*    
Created: 20230906@Johnny
Task : Get InfoSiteMatch
DB: bodb_OWP    
    
Revisions:     
 20230906@Johnny: initial SP - [Redmine: #156321]    
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00'), @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
        -- select from infosite match
        SELECT DISTINCT 
               m.InfoSiteMatchId, 
               m.LeagueName, 
               m.HomeName, 
               m.AwayName, 
               m.EventDateTime, 
               m.TV, 
               m.IPTV, 
               m.[Provider],
               CASE
                   WHEN ec.InfositeId IS NULL
                   THEN 0
                   ELSE 1
               END AS IsCheck
        FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
             LEFT JOIN dbo.EventPickingConfirmed AS ec ON m.InfoSiteMatchId = ec.InfositeId
        WHERE m.EventDateTime >= @FromDateTime
              AND m.EventDateTime <= @ToDateTime
              AND m.IsDeleted = 0;
    END;