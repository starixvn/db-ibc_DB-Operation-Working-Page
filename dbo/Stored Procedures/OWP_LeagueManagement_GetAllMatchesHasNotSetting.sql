
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LeagueManagement_GetAllMatchesHasNotSetting] @EventDate DATE
AS

/*
Created: 20210405@Mira
Task : League Management - Auto Input Max Bet to New League
DB: bodb_OWP

Revisions:
	20210405@Mira: Initial - [Redmine: #152542]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @EventFromDate DATE= DATEADD(DAY, -7, CAST(@EventDate AS DATETIME));
        DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CAST(@EventFromDate AS DATETIME));
        DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 12, CAST(@EventDate AS DATETIME));
        CREATE TABLE #tblNotSettingLeague(LeagueId INT);
        CREATE TABLE #tblOWPMatchId(OWPMatchId INT);

        -- League that has not had any setting
        INSERT INTO #tblNotSettingLeague([LeagueId])
               SELECT DISTINCT 
                      o.OWPLeagueId
               FROM dbo.OWPMatch o
                    INNER JOIN dbo.OWPLeague ol ON ol.OWPLeagueId = o.OWPLeagueId
                    LEFT JOIN dbo.LeagueSetting l ON l.LeagueId = o.OWPLeagueId
               WHERE l.LeagueId IS NULL
                     AND o.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
                     AND ol.OWPLeagueName NOT LIKE '%Friendly%'
                     AND ol.OWPLeagueName NOT LIKE '%Tournament%';

        -- Get OWPMatchId
        INSERT INTO #tblOWPMatchId([OWPMatchId])
               SELECT DISTINCT 
                      o.OWPMatchId
               FROM dbo.OWPMatch o
                    LEFT JOIN dbo.MatchSetting ol ON ol.OWPMatchId = o.OWPMatchId
                    LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON o.OWPMatchId = mm.MinorMatchId
               WHERE o.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
                     AND mm.ParentMatchId IS NULL;

        -- Select MatchInfo
        SELECT DISTINCT 
               o.OWPMatchId, 
               o.EventDateTime, 
               o.OWPLeagueId, 
               ol.OWPLeagueName, 
               STUFF(
        (
            SELECT ', ' + p.TVCode
            FROM dbo.Television p WITH(NOLOCK)
                 INNER JOIN dbo.MatchTelevision mp WITH(NOLOCK) ON p.TVId = mp.TVId
            WHERE mp.OWPMatchId = o.OWPMatchId FOR XML PATH('')
        ), 1, 2, '') AS 'TV'
        FROM dbo.OWPMatch o
             INNER JOIN dbo.OWPLeague ol ON ol.OWPLeagueId = o.OWPLeagueId
             INNER JOIN #tblOWPMatchId t ON t.OWPMatchId = o.OWPMatchId;

        -- Select Match Setting
        SELECT s.[OWPMatchId], 
               [Bettype], 
               [Spread], 
               [Maxbet]
        FROM [dbo].[MatchSetting] s WITH(NOLOCK)
             INNER JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = s.OWPMatchId
             INNER JOIN #tblOWPMatchId t ON t.OWPMatchId = m.OWPMatchId;

        -- Drop temp table
        DROP TABLE #tblNotSettingLeague;
        DROP TABLE #tblOWPMatchId;
    END;