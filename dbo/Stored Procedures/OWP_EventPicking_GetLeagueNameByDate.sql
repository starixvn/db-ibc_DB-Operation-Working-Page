
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetLeagueNameByDate] @Date DATE
AS

/*      
 Created: 20230908@Mira
 Task : Get league name
 DB: bodb_OWP      
 
 Revisions:
    20230908@Mira: Get league name - [Redmine: #190039]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');

        -- select league
        SELECT DISTINCT 
               im.OWPLeagueId 'Value', 
               im.LeagueName 'Label'
        FROM dbo.InfoSiteMatch AS im WITH(NOLOCK)
        WHERE im.EventDateTime BETWEEN @FromDateTime AND @ToDateTime and im.IsTest = 0;
    END;