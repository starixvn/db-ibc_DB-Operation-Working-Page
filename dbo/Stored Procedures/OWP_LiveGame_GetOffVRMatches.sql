
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveGame_GetOffVRMatches] @EventDate DATE, 
                                                     @SyncTime  DATETIME
AS

/*
Created: 20231117@Mira
Task : Sync off VR
DB: bodb_OWP

Revisions:
	20231117@Mira: get matches to sync off vr - [Redmine: #195697]
	20231226@Mira: get matches by new condition - [Redmine: #197659]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, @EventDate));
        DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 36, CONVERT(DATETIME, @EventDate));

        -- select distinct OWPMatchId with more information where count = 1
        SELECT m.OWPMatchId, 
               MAX(m.MatchId) AS AdminSiteMatchId, 
               MAX(r.Value) AS OffVR
        FROM dbo.OWPMatch m WITH(NOLOCK)
             INNER JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
             INNER JOIN dbo.MatchOfferDetail mo WITH(NOLOCK) ON mo.OWPMatchId = m.OWPMatchId
             INNER JOIN dbo.RefResource r WITH(NOLOCK) ON r.RefName = 'MatchOffer'
                                                          AND r.Value LIKE '%OFF VR%'
                                                          AND r.Value NOT LIKE '%Big HDP%'
                                                          AND mo.MatchOfferId = r.ResourceId
        WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
              AND m.EventDateTime > @SyncTime
              AND i.MatchStatus <> 'Cancel'
              AND i.IsSelected = 1
              AND m.MatchId IS NOT NULL
        GROUP BY m.OWPMatchId
        HAVING COUNT(*) = 1;
    END;