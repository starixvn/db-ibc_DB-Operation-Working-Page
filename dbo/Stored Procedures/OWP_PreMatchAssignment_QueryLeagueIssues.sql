
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryLeagueIssues] @EventDate DATE, 
                                                                  @ActorId   INT
AS

/*  
Created: 20201003@Tyler
Task : Query day shift
DB: bodb_OWP  
  
Revisions:  
 20201003@Tyler: get other assignments  - [Redmine: #142258]  
*/

     SELECT m.PreMatchIssueId, 
            x.OWPLeagueId, 
            im.[Message],
            CASE
                WHEN r.IsRead IS NULL
                THEN 1
                ELSE r.IsRead
            END AS 'IsRead'
     FROM(
         SELECT i.OWPLeagueId, 
                MAX(m.CreatedDate) AS 'MaxDate'
         FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
              LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
         WHERE i.EventDate = @EventDate
               AND i.OWPLeagueId IS NOT NULL
         GROUP BY i.OWPLeagueId) AS x
         INNER JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.OWPLeagueId = x.OWPLeagueId
         INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = m.PreMatchIssueId
         LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                    AND r.UserId = @ActorId
     WHERE im.CreatedDate = x.MaxDate;