
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TraderApi_GetTraderByAdminsiteMatchIds] @MatchesJson NVARCHAR(MAX)
AS

/*
Created: 20240911@Mira
Task : Trader api
DB: bodb_OWP

Revisions:
	20240911@Mira: Get trader corresponding matchid and subtype [Redmine: #209390]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FT1x2 INT= 5;
        DECLARE @HT1x2 INT= 15;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -2, @FromDate), '11:59:59');
        CREATE TABLE #Matches
        (MatchId        INT NOT NULL, 
         ParentId       INT, 
         Subtype        INT, 
         MinorBettypeId INT, 
         OWPMatchId     INT, 
         IsMainMatch    BIT
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
              m.OWPMatchId = o.OWPMatchId
        FROM #Matches m
             LEFT JOIN OWPMatch o WITH(NOLOCK) ON m.MatchId = o.MatchId
                                                  AND m.IsMainMatch = 1
                                                  AND o.EventDateTime BETWEEN @FromDate AND @ToDate;

        -- update OWPMatchId for special match
        UPDATE m
          SET 
              m.OWPMatchId = mm.MinorMatchId
        FROM #Matches m
             LEFT JOIN OWPMatch parent WITH(NOLOCK) ON m.ParentId = parent.MatchId
                                                       AND m.IsMainMatch = 0
                                                       AND m.MinorBettypeId < 0 -- non update invalid special match
                                                       AND parent.EventDateTime BETWEEN @FromDate AND @ToDate
             INNER JOIN MinorMatch mm WITH(NOLOCK) ON mm.ParentMatchId = parent.OWPMatchId
             INNER JOIN OWPMatch special WITH(NOLOCK) ON mm.MinorMatchId = special.OWPMatchId
                                                         AND m.MinorBettypeId = mm.MinorBettypeId;

        -- select assignment FT1x2, HT1x2  
        SELECT DISTINCT 
               m.MatchId, 
               a.UserId, 
               a.Bettype
        FROM #Matches m
             LEFT JOIN Assignment a WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
                                                    AND (a.Bettype IS NULL
                                                         OR a.Bettype IN(@FT1x2, @HT1x2));

        -- drop table  
        DROP TABLE #Matches;
    END;