
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PrematchAssignment_GetLinkedOWPMatch] @InfositeMatchIds NVARCHAR(MAX), 
                                                                 @EventDate        DATE
AS

/*
Created: 20210607@Mira
Task : Pre-Match Enhancement - Link Match Status
DB: bodb_OWP

Revisions:
	20210607@Mira: Initial - [Redmine: #156336]
	20210712@Mira: enhance get by eventDate - [Redmine: #156321]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, @EventDate));
        DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 36, CONVERT(DATETIME, @EventDate));
        DECLARE @tempInfositeId TABLE(InfositeMatchId INT);
        INSERT INTO @tempInfositeId
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@InfositeMatchIds, ',') u OPTION(MAXRECURSION 0);

        -- select owpmatch info
        SELECT DISTINCT t.InfositeMatchId, 
               o.OWPMatchId, 
               mi.MatchStatus
        FROM @tempInfositeId t
             INNER JOIN dbo.OWPMatch o WITH(NOLOCK) ON o.InfoSiteMatchId = t.InfositeMatchId
             LEFT JOIN dbo.[MatchInfo] mi WITH(NOLOCK) ON mi.OWPMatchId = o.OWPMatchId
        WHERE o.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime;
    END;