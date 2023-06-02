/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_LAAssignmentsSel] @FromDate DATETIME = '2020-01-03', 
                                        @ToDate   DATETIME = '2020-01-05'
AS

/*    
 Created: 20200815@Jacob
 Task : LA Reports
 DB: bodb_OWP    
    
 Revisions:
	20200815@Jacob: Archive plan for OWP tables - [Redmine: #137757]	
	20200602@Los: LA Report change rule count Suspender - [Redmine: #184832]
*/

     SET NOCOUNT ON;
     SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
     SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');
     SELECT tm.UserId,
			tm.AssignmentId,
            p.ProviderName, 
            l.OWPLeagueName, 
            mn.MinorBettypeId, 
            ma.OWPMatchId, 
			mn.ParentMatchId,
            ma.EventDateTime
      FROM (
		SELECT a.UserId,
		   a.AssignmentId,
		   a.OWPMatchId,
		   a.Bettype,
		  ROW_NUMBER() OVER(PARTITION BY OWPMatchId ORDER BY a.AssignmentId ASC) row_num
			FROM dbo.Assignment a WITH(NOLOCK)
			WHERE a.Bettype=-1002
				AND (a.AssignmentType=1 OR (a.AssignmentType=2 AND LOWER(a.AssignmentNote) LIKE '%2nd%'))) tm
          INNER JOIN dbo.OWPMatch ma WITH(NOLOCK) ON ma.OWPMatchId = tm.OWPMatchId
          INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
          INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON ma.OWPLeagueId = l.OWPLeagueId
          LEFT JOIN dbo.MatchProvider mp WITH(NOLOCK) ON ma.OWPMatchId = mp.OWPMatchId
          LEFT JOIN dbo.[Provider] p WITH(NOLOCK) ON mp.ProviderId = p.ProviderId
          LEFT JOIN dbo.MinorMatch mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
     WHERE tm.UserId IS NOT NULL
		AND tm.row_num<=2
           AND mi.MatchStatus = 'Live'
           AND ma.EventDateTime BETWEEN @FromDate AND @ToDate
     ORDER BY UserId ASC, ma.EventDateTime ASC;