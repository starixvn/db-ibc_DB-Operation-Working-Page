
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_GetInfoSiteMatchForLST] @Date DATE
AS

/*      
 Created: 20242304@Liam
 Task : Get main match
 DB: bodb_OWP      
 
 Revisions:
    20242304@Liam: Get main match for LST - [Redmine: #203309]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');

        -- Select InfoSiteMatch
        SELECT DISTINCT 
               im.EventDateTime, 
               im.OtherProvider,
               CASE
                   WHEN im.IsNeutral = 1
                   THEN im.HomeName + ' (N)'
                   ELSE im.HomeName
               END AS HomeName, 
               im.AwayName, 
               im.LeagueName, 
               im.Division, 
               im.Remark2, 
               im.WB, 
               im.Round, 
               im.ETPK, 
               im.TV, 
               im.Channel, 
               im.Website1, 
               im.Website2, 
               im.InfoSiteMatchId
        FROM dbo.InfoSiteMatch AS im WITH(NOLOCK)
        WHERE(im.EventDateTime BETWEEN @FromDateTime AND @ToDateTime)
             AND im.LeagueName NOT LIKE '%Fantasy%';
    END;