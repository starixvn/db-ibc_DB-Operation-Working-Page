
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LSTReport_ListTraderAssigmmentsX3] @FromDate DATETIME = '2020-01-03', 
                                                               @ToDate   DATETIME = '2020-01-05'
AS

/*    
 Created: 20200205@Kane.Le
 Task : Caculate report MultipleMatches of LST Report
 DB: bodb_OWP    
    
 Revisions:
	20200226@Kane.Le: Initial SP - [Redmine: #124448]	
	20200715@Jacob: Initial SP - [Redmine: #137210]	
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
          LEFT JOIN dbo.MinorMatch mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
     WHERE mn.MinorMatchId IS NULL
           AND ass.AssignmentType = 1
           AND ass.Bettype IN(1, 3)
          AND mi.MatchStatus = 'Live'
     AND ma.EventDateTime BETWEEN @FromDate AND @ToDate
     ORDER BY ma.EventDateTime ASC, 
              UserId ASC;