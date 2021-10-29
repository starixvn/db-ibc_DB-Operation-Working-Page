
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OvertimeReport_GetTradersAssignments] @EventDate DATETIME, 
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
        SELECT a.UserId, 
               a.Bettype, 
               a.AssignmentNote, 
               m.EventDateTime, 
               m.EventDate + m.OtherTime 'OtherDateTime', 
               l.OWPLeagueName
        FROM Assignment a
             INNER JOIN @tblUserId ui ON ui.UserId = a.UserId
             INNER JOIN [User] u WITH(NOLOCK) ON u.UserId = a.UserId
             INNER JOIN OWPMatch m WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
             INNER JOIN OWPLeague l WITH(NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
             INNER JOIN MatchInfo i WITH(NOLOCK) ON i.OWPMatchId = m.OWPMatchId
        WHERE i.MatchStatus LIKE '%live%'
              AND m.EventDateTime BETWEEN @FromDate AND @ToDate
              AND u.SectionId IN(@SecionLiveTradingPH, @SecionLiveTradingVN)
             AND (CASE
                      WHEN m.OtherTime IS NOT NULL
                      THEN m.EventDate + m.OtherTime
                      ELSE m.EventDateTime
                  END) BETWEEN @FromDate AND @ToDate;
    END;