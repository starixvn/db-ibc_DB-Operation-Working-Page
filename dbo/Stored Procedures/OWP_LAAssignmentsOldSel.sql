
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LAAssignmentsOldSel] @FromDate DATETIME = '2022-01-01', 
                                                @ToDate   DATETIME = '2022-01-01'
AS

/*    
 Created: 20220407@Mira
 Task : Enhance LA Reports
 DB: bodb_OWP    
    
 Revisions:
	20220407@Mira: Query old data - [Redmine: #171212]	
*/

     SET NOCOUNT ON;
     SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
     SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');
     SELECT DISTINCT 
            a.UserId, 
            a.AssignmentId, 
            p.ProviderName, 
            l.OWPLeagueName, 
            mn.MinorBettypeId, 
            ma.OWPMatchId, 
            mn.ParentMatchId, 
            ma.EventDateTime
     FROM dbo.Assignment a WITH(NOLOCK)
          INNER JOIN dbo.OWPMatch_Old ma WITH(NOLOCK) ON ma.OWPMatchId = a.OWPMatchId
          INNER JOIN dbo.MatchInfo_Old mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
          INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON ma.OWPLeagueId = l.OWPLeagueId
          LEFT JOIN dbo.MatchProvider_Old mp WITH(NOLOCK) ON ma.OWPMatchId = mp.OWPMatchId
          LEFT JOIN dbo.[Provider] p WITH(NOLOCK) ON mp.ProviderId = p.ProviderId
          LEFT JOIN dbo.MinorMatch_Old mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
     WHERE a.AssignmentType = 1
           AND a.Bettype = -1002
           AND mi.MatchStatus = 'Live'
           AND ma.EventDateTime BETWEEN @FromDate AND @ToDate
     UNION
     SELECT DISTINCT 
            a.UserId, 
            a.AssignmentId, 
            p.ProviderName, 
            l.OWPLeagueName, 
            mn.MinorBettypeId, 
            ma.OWPMatchId, 
            mn.ParentMatchId, 
            ma.EventDateTime
     FROM dbo.Assignment a WITH(NOLOCK)
          INNER JOIN dbo.OWPMatch ma WITH(NOLOCK) ON ma.OWPMatchId = a.OWPMatchId
          INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
          INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON ma.OWPLeagueId = l.OWPLeagueId
          LEFT JOIN dbo.MatchProvider mp WITH(NOLOCK) ON ma.OWPMatchId = mp.OWPMatchId
          LEFT JOIN dbo.[Provider] p WITH(NOLOCK) ON mp.ProviderId = p.ProviderId
          LEFT JOIN dbo.MinorMatch mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
     WHERE a.AssignmentType = 1
           AND a.Bettype = -1002
           AND mi.MatchStatus = 'Live'
           AND ma.EventDateTime BETWEEN @FromDate AND @ToDate
     ORDER BY UserId ASC, 
              ma.EventDateTime ASC;