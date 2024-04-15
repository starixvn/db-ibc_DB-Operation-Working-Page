
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_GetMainMatchesByDate] @EventDate DATE
AS

/*
Created: 20240404@Mira
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Mira: Get provider main matches by date - [Redmine: #202819]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, @EventDate));
        DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 36, CONVERT(DATETIME, @EventDate));

        -- Result
        SELECT m.OWPMatchId, 
               i.MatchStatus, 
               ISNULL(STUFF(
        (
            SELECT ', ' + p.ProviderName
            FROM dbo.[Provider] p WITH(NOLOCK)
                 INNER JOIN dbo.MatchProvider mp WITH(NOLOCK) ON p.ProviderId = mp.ProviderId
            WHERE mp.OWPMatchId = m.OWPMatchId FOR XML PATH('')
        ), 1, 2, ''), '') AS [Provider],
               CASE
                   WHEN l.OWPLeagueName LIKE '%SABA %'
                   THEN 1
                   ELSE 0
               END IsSaba
        FROM dbo.OWPMatch m WITH(NOLOCK)
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
             LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
        WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
              AND mm.MinorBettypeId IS NULL
              AND i.IsSelected = 1
              AND l.OWPLeagueName NOT LIKE '%Fantasy%';
    END;