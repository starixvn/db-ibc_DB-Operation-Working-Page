
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetInfoSiteMatch] @Date       DATE, 
                                                          @SelectGame NVARCHAR(10) = ''
AS

/*      
 Created: 20221102@Mira
 Task : Get main match
 DB: bodb_OWP      
 
 Revisions:
    20221102@Mira: Event picking new - [Redmine: #179302]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');

        -- Select InfoSiteMatch
        SELECT im.InfoSiteMatchId, 
               im.AdminSiteMatchId, 
               im.EventDateTime, 
               im.OWPLeagueId, 
               im.LeagueName, 
               l.IsBlackList, 
               im.HomeName, 
               im.AwayName, 
               im.TV, 
               im.IPTV, 
               im.Channel, 
               im.WB, 
               im.Provider, 
               im.Agent, 
               im.Venue, 
               im.Round, 
               im.Division, 
               im.ETPK, 
               im.Remark
        FROM dbo.InfoSiteMatch AS im WITH(NOLOCK)
             LEFT JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON l.OWPLeagueId = im.OWPLeagueId
        WHERE im.EventDateTime BETWEEN @FromDateTime AND @ToDateTime;
    END;