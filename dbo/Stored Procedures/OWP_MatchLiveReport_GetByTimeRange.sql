
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MatchLiveReport_GetByTimeRange] @FromDate DATE, @ToDate DATE

/*      
 Created: 20220401@carlos.nguyen
 Task : Get match report in time range
 DB: bodb_OWP      
      
Revisions:  
	20220401@carlos.nguyen: Initial SP - [Redmine: #170737]  
	
*/

AS
     SELECT * 
     FROM MatchLiveReport AS ml WITH (NOLOCK)
     WHERE ml.EventDate BETWEEN @FromDate AND @ToDate
GO