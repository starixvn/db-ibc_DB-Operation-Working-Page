
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OvertimeReport_GetTradersAssignments] @EventDate DATE, 
                                                                 @UserIds   NVARCHAR(MAX)
AS

/*    
Created: 20211014@Tyler
Task : Overtime Report
DB: bodb_OWP

Revisions:
	20211014@Tyler: init sp - [Redmine: #162821]
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
               WHERE i.MatchStatus LIKE '%live%'
                     AND u.SectionId IN(@SecionLiveTradingPH, @SecionLiveTradingVN)
                    AND (CASE
                             WHEN m.OtherTime IS NOT NULL
                             THEN m.EventDate + CAST(m.OtherTime AS DATETIME)
                             ELSE m.EventDateTime
                         END) BETWEEN @FromDate AND @ToDate;
        SELECT UserId, 
               OWPMatchId, 
               ParentMatchId, 
               MinorBettypeId, 
               Bettype, 
               Remark, 
               EventDateTime, 
               OWPLeagueName
        FROM @tblAssignment;

        -- Select main matches remark to detect Corner & Booking ET
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
             INNER JOIN @tblAssignment a ON a.ParentMatchId = m.OWPMatchId;
    END;