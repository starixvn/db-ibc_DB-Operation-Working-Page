
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderStatistic_SumByLeague] @FromDate DATETIME,
@ToDate DATETIME
AS

/*
Created:20250516@Lilac.Nguyen
Task : Provider statistics
DB: bodb_OWP

Revisions:
	:20250516@Lilac.Nguyen: Sum provider statistic by league - [Redmine: #225395]
	
*/

    BEGIN
        SET NOCOUNT ON;
		SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
        SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');

		WITH CombinedMatch AS (
		SELECT OWPMatchId, OWPLeagueId 
		FROM OWPMatch
		WHERE EventDateTime BETWEEN @FromDate AND @ToDate

		UNION

		SELECT OWPMatchId, OWPLeagueId 
		FROM OWPMatch_OLD
		WHERE EventDateTime BETWEEN @FromDate AND @ToDate
		),

	    CombinedMatchInfo AS (
        SELECT DISTINCT OWPMatchId
        FROM MatchInfo

        UNION

        SELECT DISTINCT OWPMatchId
        FROM MatchInfo_Old
		)

		SELECT DISTINCT
			l.OWPLeagueId,
			l.OWPLeagueName AS LeagueName,
			ma.AgentId,
			o.OWPMatchId,
			COUNT(CASE WHEN ma.AgentId IS NOT NULL THEN 1 END) AS [Count]
		FROM CombinedMatch AS o
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) 
			ON o.OWPLeagueId = l.OWPLeagueId
		INNER JOIN CombinedMatchInfo AS mi WITH (NOLOCK) 
			ON o.OWPMatchId = mi.OWPMatchId
		INNER JOIN dbo.MatchAgentConfirm AS ma WITH (NOLOCK) 
			ON ma.OWPMatchId = o.OWPMatchId
		LEFT JOIN dbo.AgentOption AS ao WITH (NOLOCK) 
			ON ao.AgentId = ma.AgentId
		
		GROUP BY 
			l.OWPLeagueId,
			l.OWPLeagueName,
			ma.AgentId,
			o.OWPMatchId,
			ao.AgentName
		ORDER BY 
			[Count] DESC;
        
    END;
