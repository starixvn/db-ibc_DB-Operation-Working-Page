
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_SyncIsLiveSel] @FromTime DATETIME, 
                                          @ToTime   DATETIME
AS

/*
Created: 20200913@Jacob
Task : Sync Live Status to InfoSite
DB: bodb_OWP

Revisions:
	20200913@Jacob: Sync Live Status to InfoSite - [Redmine: #134336]
	20200913@Jacob: Sync Live Status to InfoSite - Ignore deleted match - [Redmine: #134336]
	20200913@Jacob: Sync Live Status to InfoSite - Ignore SABA match - [Redmine: #134336]
	20201004@Jacob: Sync Live Status to InfoSite - Fix bug FromDate - [Redmine: #134336]
	20201105@Jacob: Only sync today match - [Redmine: #144570]
	20210810@Tyler: Sync special products - [Redmine: #153498]
*/

    BEGIN
        SET NOCOUNT ON;

        -- @tempOWPMatch
        DECLARE @tempOWPMatch TABLE
        (InfoSiteMatchId INT, 
         OWPMatchId      INT, 
         IsLive          BIT
        );
        INSERT INTO @tempOWPMatch
        (InfoSiteMatchId, 
         OWPMatchId, 
         IsLive
        )
               SELECT DISTINCT 
                      m.InfoSiteMatchId, 
                      m.OWPMatchId,
                      CASE
                          WHEN mi.MatchStatus IN('Live', 'Postponed')
                          THEN 1
                          ELSE 0
                      END IsLive
               FROM dbo.OWPMatch m WITH(NOLOCK)
                    INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
                    INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
               WHERE m.EventDateTime BETWEEN @FromTime AND @ToTime
                     AND m.InfoSiteMatchId IS NOT NULL
                     AND l.OWPLeagueName NOT LIKE '%SABA %';

        --@tempInfoSiteMatch
        DECLARE @tempInfoSiteMatch TABLE
        (InfoSiteMatchId INT, 
         IsLive          BIT
        );
        INSERT INTO @tempInfoSiteMatch
        (InfoSiteMatchId, 
         IsLive
        )
               SELECT DISTINCT 
                      m.InfoSiteMatchId, 
                      i.IsLive
               FROM @tempOWPMatch m
                    INNER JOIN dbo.InfoSiteMatch i WITH(NOLOCK) ON m.InfoSiteMatchId = i.InfoSiteMatchId
                                                                   AND i.IsDeleted = 0;

        -- Duplicated InfoSiteId
        DECLARE @tempDuplicatedInfoSiteMatch TABLE(InfoSiteMatchId INT);
        INSERT INTO @tempDuplicatedInfoSiteMatch(InfoSiteMatchId)
               SELECT [@tempOWPMatch].InfoSiteMatchId
               FROM @tempOWPMatch
               GROUP BY [@tempOWPMatch].InfoSiteMatchId
               HAVING COUNT([@tempOWPMatch].IsLive) > 1;

        -- Non Duplicated InfoSiteId
        DECLARE @tempNonDuplicatedInfoSiteMatch TABLE(InfoSiteMatchId INT);
        INSERT INTO @tempNonDuplicatedInfoSiteMatch(InfoSiteMatchId)
               SELECT [@tempOWPMatch].InfoSiteMatchId
               FROM @tempOWPMatch
               GROUP BY [@tempOWPMatch].InfoSiteMatchId
               HAVING COUNT([@tempOWPMatch].IsLive) = 1;

        -- Result
        (
            SELECT t.InfoSiteMatchId, 
                   m.IsLive, 
                   NULL 'MinorBettypeId'
            FROM @tempNonDuplicatedInfoSiteMatch t
                 INNER JOIN @tempOWPMatch m ON t.InfoSiteMatchId = m.InfoSiteMatchId
                 INNER JOIN @tempInfoSiteMatch i ON t.InfoSiteMatchId = i.InfoSiteMatchId
            WHERE m.IsLive <> i.IsLive
            UNION
            SELECT t.InfoSiteMatchId, 
                   m.IsLive, 
                   NULL 'MinorBettypeId'
            FROM @tempDuplicatedInfoSiteMatch t
                 INNER JOIN @tempOWPMatch m ON m.InfoSiteMatchId = t.InfoSiteMatchId
        )
        UNION ALL
        SELECT DISTINCT 
               pm.InfoSiteMatchId,
               CASE
                   WHEN mi.MatchStatus IN('Live', 'Postponed')
                   THEN 1
                   ELSE 0
               END IsLive, 
               m.MinorBettypeId
        FROM dbo.MinorMatch m WITH(NOLOCK)
             INNER JOIN @tempOWPMatch pm ON pm.OWPMatchId = m.ParentMatchId
             INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON m.MinorMatchId = mi.OWPMatchId;
    END;