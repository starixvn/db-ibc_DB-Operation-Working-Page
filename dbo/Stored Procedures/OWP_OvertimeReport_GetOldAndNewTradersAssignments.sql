
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OvertimeReport_GetOldAndNewTradersAssignments] @EventDate DATE, 
                                                                           @UserIds   NVARCHAR(MAX)
AS

/*    
Created: 20220816@Mira
Task : Overtime Report
DB: bodb_OWP

Revisions:
	20220816@Mira: Get old, new data for re-generate data - [Redmine: #176629]
	20230918@Los: Count suspened - [Redmine: #194475]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tblUserId TABLE(UserId INT);
        DECLARE @SecionLiveTradingVN INT= 3, @SecionLiveTradingPH INT= 28;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 1, @EventDate), '12:00:00'), @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -2, @EventDate), '11:59:59');
        INSERT INTO @tblUserId
               SELECT DISTINCT 
                      [Value]
               FROM fnc_SplitString(@UserIds, ',') u OPTION(MAXRECURSION 0);
        DECLARE @tblAssignment TABLE
        (UserId         INT, 
         OWPMatchId     INT, 
         ParentMatchId  INT NULL, 
         MinorBettypeId INT NULL, 
         Bettype        INT, 
         Remark         NVARCHAR(2000), 
         EventDateTime  DATETIME, 
         OWPLeagueName  NVARCHAR(2000)
        );
        INSERT INTO @tblAssignment
        (UserId, 
         OWPMatchId, 
         ParentMatchId, 
         MinorBettypeId, 
         Bettype, 
         Remark, 
         EventDateTime, 
         OWPLeagueName
        )
               -- get new assignment
               SELECT a.UserId, 
                      m.OWPMatchId, 
                      mm.ParentMatchId, 
                      mm.MinorBettypeId, 
                      a.Bettype, 
                      i.Remark,
                      CASE
                          WHEN m.OtherTime IS NOT NULL
                          THEN m.EventDate + CAST(m.OtherTime AS DATETIME)
                          ELSE m.EventDateTime
                      END EventDateTime, 
                      l.OWPLeagueName
               FROM Assignment a
                    INNER JOIN @tblUserId ui ON ui.UserId = a.UserId
                    INNER JOIN [User] u WITH(NOLOCK) ON u.UserId = a.UserId
                    INNER JOIN OWPMatch m WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
                    LEFT JOIN MinorMatch mm WITH(NOLOCK) ON mm.MinorMatchId = m.OWPMatchId
                    INNER JOIN OWPLeague l WITH(NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
                    INNER JOIN MatchInfo i WITH(NOLOCK) ON i.OWPMatchId = m.OWPMatchId
               WHERE i.MatchStatus IN('Live', 'Suspended')
                     AND u.SectionId IN(@SecionLiveTradingPH, @SecionLiveTradingVN)
                    AND (CASE
                             WHEN m.OtherTime IS NOT NULL
                             THEN m.EventDate + CAST(m.OtherTime AS DATETIME)
                             ELSE m.EventDateTime
                         END) BETWEEN @FromDate AND @ToDate

               -- get old assignment
               UNION
               SELECT a.UserId, 
                      m.OWPMatchId, 
                      mm.ParentMatchId, 
                      mm.MinorBettypeId, 
                      a.Bettype, 
                      i.Remark,
                      CASE
                          WHEN m.OtherTime IS NOT NULL
                          THEN m.EventDate + CAST(m.OtherTime AS DATETIME)
                          ELSE m.EventDateTime
                      END EventDateTime, 
                      l.OWPLeagueName
               FROM Assignment_Old a
                    INNER JOIN @tblUserId ui ON ui.UserId = a.UserId
                    INNER JOIN [User] u WITH(NOLOCK) ON u.UserId = a.UserId
                    INNER JOIN OWPMatch_Old m WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
                    LEFT JOIN MinorMatch_Old mm WITH(NOLOCK) ON mm.MinorMatchId = m.OWPMatchId
                    INNER JOIN OWPLeague l WITH(NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
                    INNER JOIN MatchInfo_Old i WITH(NOLOCK) ON i.OWPMatchId = m.OWPMatchId
               WHERE i.MatchStatus IN('Live', 'Suspended')
                     AND u.SectionId IN(@SecionLiveTradingPH, @SecionLiveTradingVN)
                    AND (CASE
                             WHEN m.OtherTime IS NOT NULL
                             THEN m.EventDate + CAST(m.OtherTime AS DATETIME)
                             ELSE m.EventDateTime
                         END) BETWEEN @FromDate AND @ToDate;

        -- Select old and new assignments
        SELECT UserId, 
               OWPMatchId, 
               ParentMatchId, 
               MinorBettypeId, 
               Bettype, 
               Remark, 
               EventDateTime, 
               OWPLeagueName
        FROM @tblAssignment;

        ---- Select main matches remark to detect Corner & Booking ET
        -- get new main match
        SELECT DISTINCT 
               m.OWPMatchId, 
               m.Remark,
               CASE
                   WHEN om.OtherTime IS NOT NULL
                   THEN om.EventDate + CAST(om.OtherTime AS DATETIME)
                   ELSE om.EventDateTime
               END EventDateTime
        FROM MatchInfo m WITH(NOLOCK)
             INNER JOIN OWPMatch om WITH(NOLOCK) ON om.OWPMatchId = m.OWPMatchId
             INNER JOIN @tblAssignment a ON a.ParentMatchId = m.OWPMatchId
        -- get old main match
        UNION
        SELECT DISTINCT 
               m.OWPMatchId, 
               m.Remark,
               CASE
                   WHEN om.OtherTime IS NOT NULL
                   THEN om.EventDate + CAST(om.OtherTime AS DATETIME)
                   ELSE om.EventDateTime
               END EventDateTime
        FROM MatchInfo_Old m WITH(NOLOCK)
             INNER JOIN OWPMatch_Old om WITH(NOLOCK) ON om.OWPMatchId = m.OWPMatchId
             INNER JOIN @tblAssignment a ON a.ParentMatchId = m.OWPMatchId;
    END;