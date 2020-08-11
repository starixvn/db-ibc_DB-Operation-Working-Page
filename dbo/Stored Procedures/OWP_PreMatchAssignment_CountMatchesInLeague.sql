
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_PreMatchAssignment_CountMatchesInLeague @EventDate DATE
AS

/*  
Created: 20200811@Esther.Nguyen  
Task : Count matchs in league 
DB: bodb_OWP  
  
Revisions:  
 20200811@Esther.Nguyen: Count matches in league  - [Redmine: #138643]  
*/

     SET NOCOUNT ON;
     DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, @EventDate));
     DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 36, CONVERT(DATETIME, @EventDate));
     -- Result
     SELECT info1.LeagueName, 
            COUNT(CASE
                      WHEN info1.LeagueName = info2.LeagueName
                      THEN 1
                      ELSE 0
                  END) AS 'TotalMatch'
     FROM InfoSiteMatch info1
          INNER JOIN InfoSiteMatch info2 ON info1.InfoSiteMatchId = info2.InfoSiteMatchId
     WHERE info1.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
	 GROUP BY info1.LeagueName