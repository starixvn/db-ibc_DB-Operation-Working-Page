
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetMatchInfoByInfositeIds] @InfoSiteIds NVARCHAR(MAX)
AS

/*
Created: 20210407@Mira
Task : Export picking priority
DB: bodb_OWP

Revisions:
	20210407@Mira: Initial - [Redmine: #150269]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempInfoSiteId TABLE(InfoSiteId INT);
        INSERT INTO @tempInfoSiteId
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@InfoSiteIds, ',') u OPTION(MAXRECURSION 0);
        CREATE TABLE #tblOWPMatchByInfositeId
        (OWPMatchId INT, 
         InfositeId INT
        );
        CREATE TABLE #tblOWPMatch
        (OWPMatchId     INT, 
         InfositeId     INT, 
         MinorBettypeId INT, 
         ParentMatchId  INT
        );

        -- get matchId by InfositeId
        INSERT INTO #tblOWPMatchByInfositeId
        ([OWPMatchId], 
         [InfositeId]
        )
               SELECT matches.OWPMatchId, 
                      t.InfoSiteId
               FROM dbo.InfoSiteMatch i
                    CROSS APPLY
               (
                   SELECT TOP 1 o.OWPMatchId
                   FROM dbo.OWPMatch o
                   WHERE o.InfoSiteMatchId = i.InfoSiteMatchId
               ) matches
                    INNER JOIN @tempInfoSiteId t ON t.InfoSiteId = i.InfoSiteMatchId;

        -- get main match + minor match
        INSERT INTO #tblOWPMatch
               SELECT o.OWPMatchId, 
                      t.InfositeId, 
                      mm.MinorBettypeId, 
                      mm.ParentMatchId
               FROM dbo.OWPMatch o WITH(NOLOCK)
                    LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON o.OWPMatchId = mm.MinorMatchId
                    INNER JOIN #tblOWPMatchByInfositeId t ON t.OWPMatchId = o.OWPMatchId
               UNION ALL
               SELECT o.OWPMatchId, 
                      t.InfositeId, 
                      mm.MinorBettypeId, 
                      mm.ParentMatchId
               FROM dbo.OWPMatch o WITH(NOLOCK)
                    LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON o.OWPMatchId = mm.MinorMatchId
                    INNER JOIN #tblOWPMatchByInfositeId t ON t.OWPMatchId = mm.ParentMatchId;

        -- Add index after insert
        CREATE INDEX index_OWPMatchId ON #tblOWPMatch
        (OWPMatchId
        );

        -- Return match info
        SELECT t.OWPMatchId, 
               t.InfositeId, 
               mm.MinorBettypeId, 
               mm.ParentMatchId, 
               o.MatchNo, 
               mi.MatchStatus, 
               o.OtherTime, 
               mi.Remark, 
               mi.Phone 'ReporterPhone'
        FROM #tblOWPMatchByInfositeId t
             INNER JOIN dbo.OWPMatch o WITH(NOLOCK) ON o.OWPMatchId = t.OWPMatchId
             LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON o.OWPMatchId = mm.MinorMatchId
             LEFT JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = t.OWPMatchId;

        -- Return assignment
        SELECT a.OWPMatchId, 
               a.Bettype, 
               minor.MinorBettypeId, 
               a.UserId, 
               u.Username, 
               a.AssignmentType, 
               a.AssignmentNote, 
               minor.ParentMatchId
        FROM dbo.Assignment AS a WITH(NOLOCK)
             INNER JOIN #tblOWPMatch AS ml WITH(NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
             LEFT JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON ml.OWPMatchId = minor.MinorMatchId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE minor.MinorBettypeId IS NULL
        UNION ALL
        SELECT ml.OWPMatchId, 
               mb.InheritedBettypeId AS Bettype, 
               minor.MinorBettypeId, 
               a.UserId, 
               u.Username, 
               a.AssignmentType, 
               a.AssignmentNote, 
               minor.ParentMatchId
        FROM #tblOWPMatch AS ml WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON ml.OWPMatchId = minor.MinorMatchId
             INNER JOIN dbo.MinorBettype AS mb WITH(NOLOCK) ON mb.IsActive = 1
                                                               AND mb.ParentBettypeId = minor.MinorBettypeId
             LEFT JOIN dbo.Assignment AS a WITH(NOLOCK) ON a.OWPMatchId = ml.OWPMatchId
                                                           AND a.Bettype = mb.InheritedBettypeId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE minor.MinorBettypeId IS NOT NULL;

        -- return match setting 
        SELECT ml.OWPMatchId, 
               ms.Bettype, 
               ml.MinorBettypeId, 
               ml.ParentMatchId, 
               ms.Maxbet, 
               ms.Spread
        FROM #tblOWPMatch AS ml WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON ml.OWPMatchId = minor.MinorMatchId
             INNER JOIN dbo.MinorBettype AS mb WITH(NOLOCK) ON mb.IsActive = 1
                                                               AND mb.ParentBettypeId = minor.MinorBettypeId
             INNER JOIN dbo.MatchSetting AS ms WITH(NOLOCK) ON ml.owpmatchid = ms.OWPMatchId;

        -- drop temp table
        DROP TABLE #tblOWPMatch;
        DROP TABLE #tblOWPMatchByInfositeId;
    END;