
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MatchLiveReport_QueryOldMatchesByDate] @EventDate DATE
AS

/*
Created: 20220401@Tyler
Task : Match live report
DB: bodb_OWP	

Revisions:
	20220401@Tyler: Init SP - [Redmine: #170737]
	20220422@Tyler: Fix ToDate - [Redmine: #171867]
	20220811@Mira: Get data old and new - [Redmine: #176575]
	20241210@Frankie: Update League Group - [Redmine: #214351]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00'), @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:00');
        DECLARE @FM INT= -88, @AIO INT= -89;
        DECLARE @HDP INT= 1, @LA INT= -1002;

        -- Get old total matches
        SELECT DISTINCT 
               m.OWPMatchId, 
               mm.MinorBettypeId, 
               mm.ParentMatchId, 
               l.OWPLeagueName, 
               m.EventDateTime,
			   ISNULL([dbo].[fnc_GetLeagueGroupByDate] (m.EventDateTime, l.OWPLeagueId), 'Unknown') AS LeagueCategory,
               CASE
                   WHEN CHARINDEX('SABA', l.OWPLeagueName) > 0
                   THEN 1
                   ELSE 0
               END AS IsSaba
        FROM dbo.OWPMatch_Old m WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch_Old mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             INNER JOIN dbo.Assignment_Old a WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
             INNER JOIN dbo.MatchInfo_Old mi WITH(NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
        WHERE mi.MatchStatus = 'Live'
              AND (mm.MinorBettypeId NOT IN(@FM, @AIO)
        OR mm.MinorBettypeId IS NULL)
             AND m.EventDateTime BETWEEN @FromDate AND @ToDate
             AND a.Bettype IN(@HDP, @LA)
        -- Union new data total matches
        UNION
        SELECT DISTINCT 
               m.OWPMatchId, 
               mm.MinorBettypeId, 
               mm.ParentMatchId, 
               l.OWPLeagueName, 
               m.EventDateTime,
			   ISNULL([dbo].[fnc_GetLeagueGroupByDate] (m.EventDateTime, l.OWPLeagueId), 'Unknown') AS LeagueCategory,
               CASE
                   WHEN CHARINDEX('SABA', l.OWPLeagueName) > 0
                   THEN 1
                   ELSE 0
               END AS IsSaba
        FROM dbo.OWPMatch m WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             INNER JOIN dbo.Assignment a WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
             INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
        WHERE mi.MatchStatus = 'Live'
              AND (mm.MinorBettypeId NOT IN(@FM, @AIO)
        OR mm.MinorBettypeId IS NULL)
             AND m.EventDateTime BETWEEN @FromDate AND @ToDate
             AND a.Bettype IN(@HDP, @LA);

        -- Query old main match
        SELECT DISTINCT 
               m.OWPMatchId,
			   ISNULL([dbo].[fnc_GetLeagueGroupByDate] (m.EventDateTime, l.OWPLeagueId), 'Unknown') AS LeagueCategory
        FROM dbo.OWPMatch_Old m WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch_Old mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             INNER JOIN dbo.MatchInfo_Old mi WITH(NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
        WHERE mi.MatchStatus = 'Live'
              AND mm.MinorBettypeId IS NULL
              AND m.EventDateTime BETWEEN @FromDate AND @ToDate
        -- union new main match
        UNION
        SELECT DISTINCT 
               m.OWPMatchId,
			   ISNULL([dbo].[fnc_GetLeagueGroupByDate] (m.EventDateTime, l.OWPLeagueId), 'Unknown') AS LeagueCategory
        FROM dbo.OWPMatch m WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
        WHERE mi.MatchStatus = 'Live'
              AND mm.MinorBettypeId IS NULL
              AND m.EventDateTime BETWEEN @FromDate AND @ToDate;
    END;