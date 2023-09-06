
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
               m.AdminSiteMatchId, 
               m.InfoSiteMatchId, 
               m.LeagueName, 
               m.HomeName, 
               m.AwayName, 
               m.EventDateTime, 
               m.TV AS LocalTv, 
               m.IPTV, 
               m.[Provider]
        FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
        WHERE m.EventDateTime >= @FromDateTime
              AND m.EventDateTime <= @ToDateTime
              AND m.IsDeleted = 0;
    END;