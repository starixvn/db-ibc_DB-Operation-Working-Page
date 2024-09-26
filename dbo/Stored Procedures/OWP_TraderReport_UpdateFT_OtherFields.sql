
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TraderReport_UpdateFT_OtherFields] @EventDate DATE
AS

/*
Created: 20230301@Los
Task : Calculate FT_Other
DB: bodb_OWP

Revisions:
	20230301@Los: Calculate FT_Other - [Redmine: #184170]	
	20230918@Los: Count suspened - [Redmine: #194475]
*/

     SET NOCOUNT ON;
     SET ANSI_WARNINGS OFF;
     DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00'), @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
     -- Insert statements for procedure here
     -- DECLARE CONSTANTS
     DECLARE @HandicapHDP INT= 1, @OverUnderOU INT= 3, @LA_Bettype INT= -1002, @LeagueCategoryId_MJ INT= 1, @LeagueCategoryId_MIN_1 INT= 2, @LeagueCategoryId_MIN_2 INT= 3, @LeagueCategoryId_MIN_3 INT= 4;
     CREATE TABLE #tblTempAssignmentReportMainMatch
     (Id               INT IDENTITY, 
      UserId           INT, 
      Username         NVARCHAR(50), 
      OWPMatchId       INT, 
      Bettype          INT, 
      EventDate        DATETIME, 
      IsSoloMatch      BIT, 
      LeagueId         INT, 
      LeagueName       NVARCHAR(500), 
      LeagueCategoryId INT, 
      MinorBettypeId   INT
     );
     INSERT INTO #tblTempAssignmentReportMainMatch
     (UserId, 
      Username, 
      OWPMatchId, 
      Bettype, 
      EventDate, 
      IsSoloMatch, 
      LeagueId, 
      LeagueName, 
      LeagueCategoryId, 
      MinorBettypeId
     )
            SELECT DISTINCT 
                   u.UserId, 
                   u.Username, 
                   ma.OWPMatchId, 
                   ass.Bettype, 
                   ma.EventDateTime, 
                   mi.IsSoloMatch, 
                   ma.OWPLeagueId, 
                   la.OWPLeagueName, 
                   la.CategoryId, 
                   mn.MinorBettypeId
            FROM dbo.[User] u WITH(NOLOCK)
                 LEFT JOIN dbo.Assignment ass WITH(NOLOCK) ON u.UserId = ass.UserId
                 LEFT JOIN dbo.OWPMatch ma WITH(NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
                 INNER JOIN dbo.OWPLeague la WITH(NOLOCK) ON la.OWPLeagueId = ma.OWPLeagueId
                 LEFT JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
                 LEFT OUTER JOIN dbo.MinorMatch mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
            WHERE mn.MinorMatchId IS NULL
                  AND ass.AssignmentType = 1
                  AND ma.EventDateTime >= @FromDate
                  AND ma.EventDateTime <= @ToDate
                  AND ass.Bettype <> @LA_Bettype
                  AND mi.MatchStatus NOT IN('Cancel', 'Postponed')
                 AND UPPER(la.OWPLeagueName) NOT LIKE '%SABA %'
                 AND la.OWPLeagueName NOT LIKE '%FANTASY MATCH%'
                 AND (la.CategoryId IS NULL
                      OR la.CategoryId NOT IN(@LeagueCategoryId_MJ, @LeagueCategoryId_MIN_1, @LeagueCategoryId_MIN_2, @LeagueCategoryId_MIN_3))
            UNION
            SELECT DISTINCT 
                   u.UserId, 
                   u.Username, 
                   ma.OWPMatchId, 
                   ass.Bettype, 
                   ma.EventDateTime, 
                   mi.IsSoloMatch, 
                   ma.OWPLeagueId, 
                   la.OWPLeagueName, 
                   la.CategoryId, 
                   mn.MinorBettypeId
            FROM dbo.[User] u WITH(NOLOCK)
                 LEFT JOIN dbo.Assignment_Old ass WITH(NOLOCK) ON u.UserId = ass.UserId
                 LEFT JOIN dbo.OWPMatch_Old ma WITH(NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
                 INNER JOIN dbo.OWPLeague la WITH(NOLOCK) ON la.OWPLeagueId = ma.OWPLeagueId
                 LEFT JOIN dbo.MatchInfo_Old mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
                 LEFT OUTER JOIN dbo.MinorMatch_Old mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
            WHERE mn.MinorMatchId IS NULL
                  AND ass.AssignmentType = 1
                  AND ma.EventDateTime >= @FromDate
                  AND ma.EventDateTime <= @ToDate
                  AND ass.Bettype <> @LA_Bettype
                  AND mi.MatchStatus NOT IN('Cancel', 'Postponed')
                 AND UPPER(la.OWPLeagueName) NOT LIKE '%SABA %'
                 AND la.OWPLeagueName NOT LIKE '%FANTASY MATCH%'
                 AND (la.CategoryId IS NULL
                      OR la.CategoryId NOT IN(@LeagueCategoryId_MJ, @LeagueCategoryId_MIN_1, @LeagueCategoryId_MIN_2, @LeagueCategoryId_MIN_3));
     CREATE TABLE #tblReportTypeGeneral
     (Id        INT IDENTITY, 
      UserId    INT, 
      Username  NVARCHAR(50), 
      FT_HDP    INT, 
      FT_OU     INT, 
      FT_HDP_OU INT
     );
     INSERT INTO #tblReportTypeGeneral
     (UserId, 
      UserName, 
      FT_HDP, 
      FT_OU, 
      FT_HDP_OU
     )
            SELECT a.UserId, 
                   a.Username, 
                   SUM(a.FT_HDP) AS 'FT_HDP', 
                   SUM(a.FT_OU) AS 'FT_OU', 
                   SUM(a.FT_HDP_OU) AS 'FT_HDP_OU'
            FROM
            (
                SELECT tmp.UserId, 
                       tmp.UserName, 
                       tmp.OWPMatchId,
                       CASE
                           WHEN COUNT(CASE
                                          WHEN tmp.Bettype = @HandicapHDP
                                          THEN 1
                                          ELSE NULL
                                      END) > 0
                                AND COUNT(CASE
                                              WHEN tmp.Bettype = @OverUnderOU
                                              THEN 1
                                              ELSE NULL
                                          END) < 1
                           THEN 1
                           ELSE 0
                       END AS 'FT_HDP',
                       CASE
                           WHEN COUNT(CASE
                                          WHEN tmp.Bettype = @HandicapHDP
                                          THEN 1
                                          ELSE NULL
                                      END) < 1
                                AND COUNT(CASE
                                              WHEN tmp.Bettype = @OverUnderOU
                                              THEN 1
                                              ELSE NULL
                                          END) > 0
                           THEN 1
                           ELSE 0
                       END AS 'FT_OU',
                       CASE
                           WHEN COUNT(CASE
                                          WHEN tmp.Bettype = @HandicapHDP
                                          THEN 1
                                          ELSE NULL
                                      END) > 0
                                AND COUNT(CASE
                                              WHEN tmp.Bettype = @OverUnderOU
                                              THEN 1
                                              ELSE NULL
                                          END) > 0
                           THEN 1
                           ELSE 0
                       END AS 'FT_HDP_OU'
                FROM
                (
                    SELECT DISTINCT 
                           UserId, 
                           Username, 
                           OWPMatchId, 
                           Bettype
                    FROM #tblTempAssignmentReportMainMatch
                    WHERE Bettype IN(@HandicapHDP, @OverUnderOU)
                ) AS tmp
                GROUP BY tmp.UserId, 
                         tmp.UserName, 
                         tmp.OWPMatchId
            ) AS a
            GROUP BY a.UserId, 
                     a.UserName;

     -- Type 4 FT-Other
     MERGE dbo.TraderReport AS TARGET
     USING #tblReportTypeGeneral AS SOURCE
     ON(TARGET.UserId = SOURCE.UserId
        AND CAST(TARGET.ReportDate AS DATE) = @EventDate)
         WHEN MATCHED AND TARGET.UserId = SOURCE.UserId
                          AND CAST(TARGET.ReportDate AS DATE) = @EventDate
         THEN UPDATE SET 
                         TARGET.Type4_FT_Other = SOURCE.FT_HDP + SOURCE.FT_OU + SOURCE.FT_HDP_OU
         WHEN NOT MATCHED BY TARGET
         THEN
           INSERT(ReportDate, 
                  UserId, 
                  Username, 
                  Type4_FT_Other, 
                  CreatedDate)
           VALUES
     (@EventDate, 
      SOURCE.UserId, 
      SOURCE.UserName, 
      SOURCE.FT_HDP + SOURCE.FT_OU + SOURCE.FT_HDP_OU, 
      GETDATE()
     );
     DROP TABLE #tblReportTypeGeneral;
     DROP TABLE #tblTempAssignmentReportMainMatch;