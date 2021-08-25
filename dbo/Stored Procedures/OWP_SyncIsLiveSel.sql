
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
        (InfoSiteMatchId  INT, 
         AdminSiteMatchId INT, 
         OWPMatchId       INT, 
         IsLive           BIT
        );
        INSERT INTO @tempOWPMatch
        (InfoSiteMatchId, 
         AdminSiteMatchId, 
         OWPMatchId, 
         IsLive
        )
               SELECT DISTINCT 
                      m.InfoSiteMatchId, 
                      im.AdminSiteMatchId, 
                      m.OWPMatchId,
                      CASE
                          WHEN mi.MatchStatus IN('Live', 'Postponed')
                          THEN 1
                          ELSE 0
                      END IsLive
               FROM dbo.OWPMatch m WITH(NOLOCK)
                    INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
                    INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
                    LEFT JOIN dbo.InfoSiteMatch im WITH(NOLOCK) ON m.InfoSiteMatchId = im.InfoSiteMatchId
               WHERE m.EventDateTime BETWEEN @FromTime AND @ToTime
                     AND m.InfoSiteMatchId IS NOT NULL
                     AND im.AdminSiteMatchId > 0
                     AND l.OWPLeagueName NOT LIKE '%SABA %';

        -- Result
        SELECT m.InfoSiteMatchId, 
               m.AdminSiteMatchId, 
               m.IsLive, 
               NULL 'MinorBettypeId'
        FROM @tempOWPMatch m
        UNION ALL
        SELECT DISTINCT 
               pm.InfoSiteMatchId, 
               pm.AdminSiteMatchId,
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