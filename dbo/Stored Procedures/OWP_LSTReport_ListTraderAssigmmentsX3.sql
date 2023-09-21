
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LSTReport_ListTraderAssigmmentsX3] @FromDate DATETIME = '2020-01-03', 
                                                              @ToDate   DATETIME = '2020-01-05'
AS

/*    
 Created: 20200205@Kane.Le
 Task : Caculate report MultipleMatches of LST Report
 DB: bodb_OWP    
    
 Revisions:
	20200226@Kane.Le: Initial SP - [Redmine: #124448]	
	20200715@Jacob: Initial SP - [Redmine: #137210]	
	20230228@Los: Exclude SABA match + FANTASY MATCH - [Redmine: #184170]
	20230918@Los: Count suspened - [Redmine: #193722]
*/

     SET NOCOUNT ON;
     SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
     SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');
     SELECT DISTINCT 
            UserId, 
            ma.OWPMatchId, 
            ma.EventDateTime
     FROM dbo.Assignment ass WITH(NOLOCK)
          INNER JOIN dbo.OWPMatch ma WITH(NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
          INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
          INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON ma.OWPLeagueId = l.OWPLeagueId
          LEFT JOIN dbo.MinorMatch mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
     WHERE mn.MinorMatchId IS NULL
           AND ass.AssignmentType = 1
           AND ass.Bettype IN(1, 3)
           AND mi.MatchStatus IN('Live', 'Suspended')
          AND UPPER(l.OWPLeagueName) NOT LIKE '%SABA %'
          AND l.OWPLeagueName NOT LIKE '%FANTASY MATCH%'
          AND ma.EventDateTime BETWEEN @FromDate AND @ToDate
     ORDER BY ma.EventDateTime ASC, 
              UserId ASC;