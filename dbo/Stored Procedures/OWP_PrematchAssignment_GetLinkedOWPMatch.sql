
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PrematchAssignment_GetLinkedOWPMatch] @InfositeMatchIds NVARCHAR(MAX)
AS

/*
Created: 20210607@Mira
Task : Pre-Match Enhancement - Link Match Status
DB: bodb_OWP

Revisions:
	20210607@Mira: Initial - [Redmine: #156336]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempInfositeId TABLE(InfositeMatchId INT);
        INSERT INTO @tempInfositeId
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@InfositeMatchIds, ',') u OPTION(MAXRECURSION 0);

        -- select owpmatch info
        SELECT t.InfositeMatchId, 
               matchInfo.OWPMatchId, 
               mi.MatchStatus
        FROM @tempInfositeId t
             CROSS APPLY
        (
            SELECT TOP 1 o.OWPMatchId
            FROM dbo.OWPMatch o WITH(NOLOCK)
            WHERE o.InfoSiteMatchId = t.InfositeMatchId
            ORDER BY o.EventDate DESC
        ) AS matchInfo
             LEFT JOIN dbo.[MatchInfo] mi WITH(NOLOCK) ON mi.OWPMatchId = matchInfo.OWPMatchId;
    END;