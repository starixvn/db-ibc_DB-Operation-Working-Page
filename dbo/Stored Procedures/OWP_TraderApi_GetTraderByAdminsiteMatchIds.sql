
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TraderApi_GetTraderByAdminsiteMatchIds] @MatchesJson NVARCHAR(MAX)
AS

/*
Created: 20240911@Mira
Task : Trader api
DB: bodb_OWP

Revisions:
	20240911@Mira: Get trader corresponding matchid and subtype [Redmine: #209390]
	20240930@Mira: Get more AIO trader [Redmine: #211426]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FT1x2 INT= 5;
        DECLARE @HT1x2 INT= 15;
        DECLARE @NoOfCorners INT= -3, @TotalBooking INT= -6;
        DECLARE @AIO INT= -89, @AllInOneTotalBookings INT= -189, @AllInOneCorners INT= -289;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -2, @FromDate), '11:59:59');
        CREATE TABLE #Matches
        (MatchId          INT NOT NULL, 
         ParentId         INT, 
         Subtype          INT, 
         MinorBettypeId   INT, 
         OWPMatchId       INT, 
         OWPParentMatchId INT, 
         IsMainMatch      BIT
        );
        CREATE INDEX idx_MatchId ON #Matches(MatchId);
        INSERT INTO #Matches
        (MatchId, 
         ParentId, 
         Subtype, 
         MinorBettypeId, 
         IsMainMatch
        )
               SELECT MatchId, 
                      ParentId, 
                      Subtype, 
                      MinorBettypeId, 
                      IsMainMatch
               FROM OPENJSON(@MatchesJson) WITH(MatchId INT, ParentId INT, Subtype INT, MinorBettypeId INT, IsMainMatch BIT);

        -- update OWPMatchId for main match
        UPDATE m
          SET 
              m.OWPMatchId = o.OWPMatchId, 
              m.OWPParentMatchId = o.OWPMatchId
        FROM #Matches m
             LEFT JOIN OWPMatch o WITH(NOLOCK) ON m.ParentId = o.MatchId
                                                  AND m.IsMainMatch = 1
                                                  AND o.EventDateTime BETWEEN @FromDate AND @ToDate;

        -- update OWPMatchId for special match
        UPDATE m
          SET 
              m.OWPMatchId = mm.MinorMatchId, 
              m.OWPParentMatchId = parent.OWPMatchId
        FROM #Matches m
             LEFT JOIN OWPMatch parent WITH(NOLOCK) ON m.ParentId = parent.MatchId
                                                       AND m.IsMainMatch = 0
                                                       AND m.MinorBettypeId < 0 -- non update invalid special match
                                                       AND parent.EventDateTime BETWEEN @FromDate AND @ToDate
             INNER JOIN MinorMatch mm WITH(NOLOCK) ON mm.ParentMatchId = parent.OWPMatchId
             INNER JOIN OWPMatch special WITH(NOLOCK) ON mm.MinorMatchId = special.OWPMatchId
                                                         AND m.MinorBettypeId = mm.MinorBettypeId;

        -- get AIO trader of main match
        SELECT DISTINCT 
               m.MatchId, 
               a.UserId, 
               -1004 'Bettype', 
               minor.MinorBettypeId, 
               minor.MinorMatchId 'OWPMatchId'
        FROM #Matches m
             INNER JOIN MinorMatch AS minor ON minor.ParentMatchId = m.OWPParentMatchId
                                               AND m.IsMainMatch = 1
             LEFT JOIN Assignment a WITH(NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
        WHERE minor.MinorBettypeId = -89
        UNION
        -- get AIO trader of minor match (no. of corner and total booking)
        SELECT DISTINCT 
               m.MatchId, 
               a.UserId, 
               -1004 'Bettype', 
               m.MinorBettypeId, 
               minor1.MinorMatchId 'OWPMatchId'
        FROM #Matches m
             INNER JOIN MinorMatch AS minor1 ON minor1.ParentMatchId = m.OWPParentMatchId
             LEFT JOIN Assignment a WITH(NOLOCK) ON a.OWPMatchId = minor1.MinorMatchId
        WHERE(m.MinorBettypeId = @NoOfCorners
              AND minor1.MinorBettypeId = @AllInOneCorners)
             OR (m.MinorBettypeId = @TotalBooking
                 AND minor1.MinorBettypeId = @AllInOneTotalBookings)
        UNION
        -- select assignment FT1x2, HT1x2  
        SELECT DISTINCT 
               m.MatchId, 
               a.UserId, 
               a.Bettype, 
               m.MinorBettypeId, 
               m.OWPMatchId
        FROM #Matches m
             LEFT JOIN Assignment a WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
                                                    AND (a.Bettype IS NULL
                                                         OR a.Bettype IN(@FT1x2, @HT1x2));
        -- drop table  
        DROP TABLE #Matches;
    END;