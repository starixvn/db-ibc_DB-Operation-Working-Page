
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_SyncIsLiveSel] @EventDate DATETIME
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
*/

     SET NOCOUNT ON;    
     -- @tempOWPMatch
     DECLARE @tempOWPMatch TABLE
     (InfoSiteMatchId INT, 
      IsLive          BIT
     );
     INSERT INTO @tempOWPMatch
     (InfoSiteMatchId, 
      IsLive
     )
            SELECT DISTINCT 
                   m.InfoSiteMatchId,
                   CASE
                       WHEN mi.MatchStatus IN('Live', 'Postponed')
                       THEN 1
                       ELSE 0
                   END IsLive
            FROM dbo.OWPMatch m WITH(NOLOCK)
                 INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
                 INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
            WHERE m.EventDateTime >= @EventDate
                  AND m.InfoSiteMatchId IS NOT NULL
				  AND l.OWPLeagueName NOT LIKE '%SABA %';

     -- @tempInfoSiteMatch
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
            SELECT InfoSiteMatchId
            FROM @tempOWPMatch
            GROUP BY InfoSiteMatchId
            HAVING COUNT(IsLive) > 1;

     -- Non Duplicated InfoSiteId
     DECLARE @tempNonDuplicatedInfoSiteMatch TABLE(InfoSiteMatchId INT);
     INSERT INTO @tempNonDuplicatedInfoSiteMatch(InfoSiteMatchId)
            SELECT InfoSiteMatchId
            FROM @tempOWPMatch
            GROUP BY InfoSiteMatchId
            HAVING COUNT(IsLive) = 1;

     -- Result
     SELECT t.InfoSiteMatchId, 
            m.IsLive
     FROM @tempNonDuplicatedInfoSiteMatch t
          INNER JOIN @tempOWPMatch m ON t.InfoSiteMatchId = m.InfoSiteMatchId
          INNER JOIN @tempInfoSiteMatch i ON t.InfoSiteMatchId = i.InfoSiteMatchId
     WHERE m.IsLive <> i.IsLive
     UNION
     SELECT t.InfoSiteMatchId, 
            m.IsLive
     FROM @tempDuplicatedInfoSiteMatch t
          INNER JOIN @tempOWPMatch m ON m.InfoSiteMatchId = t.InfoSiteMatchId;