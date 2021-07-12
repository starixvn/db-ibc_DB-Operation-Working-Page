
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PrematchAssignment_GetLinkedOWPMatch] @InfositeMatchIds NVARCHAR(MAX)
AS

/*
Created: 20210607@Mira
Task : Pre-Match Enhancement - Link Match Status
DB: bodb_OWP

Revisions:
	20210607@Mira: Initial - [Redmine: #156336]
	20210712@Tyler: enhance looping - [Redmine: #156321]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempInfositeId TABLE(InfositeMatchId INT);
        INSERT INTO @tempInfositeId
               SELECT val
               FROM fnc_SplitStrings(@InfositeMatchIds, ',') u OPTION(MAXRECURSION 0);

        -- select owpmatch info
        WITH matchInfo
             AS (SELECT o.OWPMatchId, 
                        o.InfoSiteMatchId, 
                        ROW_NUMBER() OVER(PARTITION BY o.InfoSiteMatchId
                        ORDER BY o.EventDate DESC) AS ranking
                 FROM dbo.OWPMatch o WITH(NOLOCK)
                      INNER JOIN @tempInfositeId t ON o.InfoSiteMatchId = t.InfositeMatchId)
             SELECT matchInfo.OWPMatchId, 
                    matchInfo.InfoSiteMatchId, 
                    mi.MatchStatus
             FROM matchInfo
                  LEFT JOIN dbo.[MatchInfo] mi WITH(NOLOCK) ON mi.OWPMatchId = matchInfo.OWPMatchId
             WHERE ranking = 1;
    END;