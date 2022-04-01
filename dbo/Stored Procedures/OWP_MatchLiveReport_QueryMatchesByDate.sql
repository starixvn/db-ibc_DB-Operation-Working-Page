
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_MatchLiveReport_QueryMatchesByDate] @EventDate DATE
AS

/*
Created: 20220401@Tyler
Task : Match live report
DB: bodb_OWP	

Revisions:
	20220401@Tyler: Init SP - [Redmine: #170737]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00'), @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '12:00:00');
        SELECT m.OWPMatchId, 
               mm.MinorBettypeId, 
               l.OWPLeagueName, 
               rr.[Value],
               CASE
                   WHEN CHARINDEX('SABA', l.OWPLeagueName) > 0
                   THEN 1
                   ELSE 0
               END AS IsSaba
        FROM dbo.OWPMatch m
             LEFT JOIN dbo.MinorMatch mm ON m.OWPMatchId = mm.MinorMatchId
             INNER JOIN dbo.OWPLeague l ON m.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN dbo.RefResource rr ON rr.ResourceId = l.CategoryId
        WHERE rr.RefName = 'LeagueCategory'
              AND m.EventDateTime BETWEEN @FromDate AND @ToDate;
    END;