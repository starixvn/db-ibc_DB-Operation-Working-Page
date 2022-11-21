
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetInfoSiteChildMatch] @Date DATE
AS

/*      
 Created: 20221102@Mira
 Task : Get child match
 DB: bodb_OWP      
 
 Revisions:
    20221102@Mira: Event picking new - [Redmine: #179302]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');

        -- Select InfoSiteMatch
        SELECT m.ParentInfoSiteMatchId 'InfoSiteMatchId', 
               m.AdminSiteMatchId,
               l.OWPLeagueName 'LeagueName', 
               h.OWPTeamName 'HomeName', 
               a.OWPTeamName 'AwayName', 
               m.SubType, 
               EventDateTime,
               CASE
                   WHEN us.Id IS NULL
                   THEN 0
                   ELSE 1
               END AS 'IsNoOffer'
        FROM InfoSiteChildMatch m WITH(NOLOCK)
             INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
             INNER JOIN dbo.OWPTeam a WITH(NOLOCK) ON m.OWPAwayId = a.OWPTeamId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN dbo.EventPickingNoOfferMatch AS us WITH(NOLOCK) ON us.InfoSiteMatchId = m.ParentInfoSiteMatchId
                                                                          AND us.SubType = m.SubType
        WHERE m.EventDateTime BETWEEN @FromDateTime AND @ToDateTime;
    END;