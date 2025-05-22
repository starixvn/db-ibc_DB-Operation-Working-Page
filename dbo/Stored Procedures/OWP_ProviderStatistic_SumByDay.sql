
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderStatistic_SumByDay] @FromDate DATETIME, 
                                                       @ToDate   DATETIME
AS

/*
Created:20250516@Los
Task : User Management
DB: bodb_OWP

Revisions:
	:20250516@Los: Sum provider statistic - [Redmine: #225395]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @TimeStart DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
        DECLARE @TimeEnd DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');
        DECLARE @tempProviderStatistic TABLE
        (EventDate DATE NOT NULL, 
         AgentId   INT NOT NULL
        );
        INSERT INTO @tempProviderStatistic
        (EventDate, 
         AgentId
        )
               SELECT CASE
                          WHEN CAST(om.EventDateTime AS TIME) < '12:00:00'
                          THEN CAST(DATEADD(DAY, -1, om.EventDateTime) AS DATE)
                          ELSE CAST(om.EventDateTime AS DATE)
                      END, 
                      ao.AgentId
               FROM dbo.OWPMatch AS om WITH(NOLOCK)
                    INNER JOIN dbo.MatchAgentConfirm AS ma WITH(NOLOCK) ON ma.OWPMatchId = om.OWPMatchId
                    INNER JOIN AgentOption AS ao WITH(NOLOCK) ON ao.AgentId = ma.AgentId
               WHERE om.EventDateTime BETWEEN @TimeStart AND @TimeEnd
               UNION ALL
               SELECT CASE
                          WHEN CAST(om_old.EventDateTime AS TIME) < '12:00:00'
                          THEN CAST(DATEADD(DAY, -1, om_old.EventDateTime) AS DATE)
                          ELSE CAST(om_old.EventDateTime AS DATE)
                      END, 
                      ao.AgentId
               FROM dbo.OWPMatch_Old AS om_old WITH(NOLOCK)
                    INNER JOIN dbo.MatchAgentConfirm AS ma WITH(NOLOCK) ON ma.OWPMatchId = om_old.OWPMatchId
                    INNER JOIN AgentOption AS ao WITH(NOLOCK) ON ao.AgentId = ma.AgentId
               WHERE om_old.EventDateTime BETWEEN @TimeStart AND @TimeEnd;

        --AgentId=1 => '_365Gv'
        --AgentId=2 => 'Betrada'
        --AgentId=3 => 'Bg'
        --AgentId=4 => 'Fc'
        --AgentId=5 => 'Img'
        --AgentId=6 => 'Rb2'
        --AgentId=8 => 'Rts'
        --AgentId=9 => 'Slr'
        --AgentId=10=>  'Woo'
        --AgentId=11=>  'Streaming'

        SELECT AgentId, 
               EventDate, 
               COUNT(AgentId) 'Count'
        FROM @tempProviderStatistic
        GROUP BY EventDate, 
                 AgentId;
    END;