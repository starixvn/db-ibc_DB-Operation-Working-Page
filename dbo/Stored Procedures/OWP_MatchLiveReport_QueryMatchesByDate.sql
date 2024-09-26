
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MatchLiveReport_QueryMatchesByDate] @EventDate DATE
AS

/*
Created: 20220401@Tyler
Task : Match live report
DB: bodb_OWP	

Revisions:
	20220401@Tyler: Init SP - [Redmine: #170737]
     20220422@Tyler: Fix ToDate - [Redmine: #171867]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00'), @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:00');
        DECLARE @FM INT= -88, @AIO INT= -89;
        DECLARE @HDP INT= 1, @LA INT= -1002;
        SELECT DISTINCT 
               m.OWPMatchId, 
               mm.MinorBettypeId, 
               mm.ParentMatchId, 
               l.OWPLeagueName, 
               m.EventDateTime,
               CASE
                   WHEN l.CategoryId IS NOT NULL
                        AND l.CategoryId > 0
                   THEN rr.[Value]
                   ELSE 'Unknown'
               END AS LeagueCategory,
               CASE
                   WHEN CHARINDEX('SABA', l.OWPLeagueName) > 0
                   THEN 1
                   ELSE 0
               END AS IsSaba
        FROM dbo.OWPMatch m WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN dbo.RefResource rr WITH(NOLOCK) ON rr.ResourceId = l.CategoryId
                                                          AND rr.RefName = 'LeagueCategory'
             INNER JOIN dbo.Assignment a WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
             INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
        WHERE mi.MatchStatus = 'Live'
              AND (mm.MinorBettypeId NOT IN(@FM, @AIO)
        OR mm.MinorBettypeId IS NULL)
             AND m.EventDateTime BETWEEN @FromDate AND @ToDate
             AND a.Bettype IN(@HDP, @LA);
        SELECT DISTINCT 
               m.OWPMatchId,
               CASE
                   WHEN l.CategoryId IS NOT NULL
                        AND l.CategoryId > 0
                   THEN rr.[Value]
                   ELSE 'Unknown'
               END AS LeagueCategory
        FROM dbo.OWPMatch m WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN dbo.RefResource rr WITH(NOLOCK) ON rr.ResourceId = l.CategoryId
                                                          AND rr.RefName = 'LeagueCategory'
             INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
        WHERE mi.MatchStatus = 'Live'
              AND mm.MinorBettypeId IS NULL
              AND m.EventDateTime BETWEEN @FromDate AND @ToDate;
    END;