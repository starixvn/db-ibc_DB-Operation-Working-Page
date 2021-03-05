/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE OWP_AutoAssignment_GetLARealAssignment @UserIds   NVARCHAR(MAX), 
                                                        @EventDate DATE
AS

/*
Created: 20201223@Tyler
Task : Auto LA - Results verification
DB: bodb_OWP

Revisions:
	20201223@Tyler: Initial - [Redmine: #150268]
	
*/

    BEGIN
        SET NOCOUNT ON;
        -- temp User
        DECLARE @tblUserId TABLE(UserId INT);
        INSERT INTO @tblUserId
               SELECT DISTINCT 
                      [Value]
               FROM fnc_SplitString(@UserIds, ',') u OPTION(MAXRECURSION 0);
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '04:00:00');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '11:59:59');
        SELECT DISTINCT 
               a.UserId, 
               a.AssignmentId, 
               p.ProviderName, 
               mn.MinorBettypeId, 
               ma.OWPMatchId, 
               mn.ParentMatchId, 
               ma.EventDateTime,
			   l.OWPLeagueName,
			   a.AssignmentNote
        FROM dbo.Assignment a WITH(NOLOCK)
             INNER JOIN @tblUserId ids ON ids.UserId = a.UserId
             INNER JOIN dbo.OWPMatch ma WITH(NOLOCK) ON ma.OWPMatchId = a.OWPMatchId
             INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON ma.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN dbo.MatchProvider mp WITH(NOLOCK) ON ma.OWPMatchId = mp.OWPMatchId
             LEFT JOIN dbo.[Provider] p WITH(NOLOCK) ON mp.ProviderId = p.ProviderId
             LEFT JOIN dbo.MinorMatch mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
        WHERE mi.MatchStatus = 'Live'
              AND ma.EventDateTime BETWEEN @FromDate AND @ToDate
              AND l.OWPLeagueName NOT LIKE '%SABA%'
        ORDER BY UserId ASC, 
                 ma.EventDateTime ASC;
        DELETE @tblUserId;
    END;