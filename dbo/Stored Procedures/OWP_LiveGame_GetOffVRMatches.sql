
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
	20231226@Mira: get matches by new condition - [Redmine: #200257]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, @EventDate));
        DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 36, CONVERT(DATETIME, @EventDate));
        CREATE TABLE #TempTable
        (OWPMatchId INT, 
         MatchId    INT, 
         RefName    VARCHAR(50), 
         ResourceId INT, 
         Value      VARCHAR(50)
        );
        INSERT INTO #TempTable
        (OWPMatchId, 
         MatchId, 
         RefName, 
         ResourceId, 
         Value
        )
               SELECT m.OWPMatchId, 
                      m.MatchId, 
                      r.RefName, 
                      r.ResourceId,
                      CASE
                          WHEN r.Value LIKE '%OFF VR%'
                               OR r.Value IS NULL
                          THEN Value
                          ELSE NULL
                      END
               FROM dbo.OWPMatch m WITH(NOLOCK)
                    INNER JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
                    LEFT JOIN dbo.MatchOfferDetail mo WITH(NOLOCK) ON mo.OWPMatchId = m.OWPMatchId
                    LEFT JOIN dbo.RefResource r WITH(NOLOCK) ON r.RefName = 'MatchOffer'
                                                                AND r.Value LIKE '%OFF VR%'
                                                                AND r.Value NOT LIKE '%Big HDP%'
                                                                AND mo.MatchOfferId = r.ResourceId
               WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
                     AND m.EventDateTime > @SyncTime
                     AND i.MatchStatus <> 'Cancel'
                     AND i.IsSelected = 1
                     AND m.MatchId IS NOT NULL;

        -- select distinct OWPMatchId with more information where count off vr value = 1
        SELECT OWPMatchId, 
               MatchId 'AdminSiteMatchId',
               CASE
                   WHEN COUNT(Value) > 1
                   THEN NULL
                   WHEN MAX(Value) LIKE '%OFF VR%'
                        OR MAX(Value) IS NULL
                   THEN MAX(Value)
                   ELSE NULL
               END AS 'OffVR'
        FROM #TempTable
        GROUP BY OWPMatchId, 
                 MatchId;

        -- drop temp table
        DROP TABLE #TempTable;
    END;