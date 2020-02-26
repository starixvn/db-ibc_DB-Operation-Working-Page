
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LSTReport_ListTraderAssigmments] @FromDate DATETIME = '2020-01-01', 
                                                             @ToDate   DATETIME = '2020-02-28'
AS

/*    
 Created: 20200205@Kane.Le
 Task : Caculate report MultipleMatches of LST Report
 DB: bodb_OWP    
    
 Revisions:
	20200226@Kane.Le: Initial SP - [Redmine: #124448]	
*/

     SET NOCOUNT ON;
     SET ANSI_WARNINGS OFF;
     SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
     SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');
     SELECT DISTINCT 
            UserId, 
            ma.OWPMatchId, 
            ma.EventDateTime,
            CASE
                WHEN ass.Bettype < 4
                THEN 1
                ELSE 0
            END AS IsFullTime
     FROM dbo.Assignment ass WITH(NOLOCK)
          INNER JOIN dbo.OWPMatch ma WITH(NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
          INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
     WHERE ass.AssignmentType = 1
           AND ass.Bettype IN(1, 3, 7, 8)
          AND mi.MatchStatus NOT IN('Cancel', 'Postponed', 'Suspended')
		  AND ma.EventDateTime BETWEEN @FromDate AND @ToDate