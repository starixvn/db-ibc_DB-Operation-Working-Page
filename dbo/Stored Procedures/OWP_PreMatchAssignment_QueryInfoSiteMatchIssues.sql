
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryInfoSiteMatchIssues]  @ActorId   INT
AS

/*  
Created: 20201003@Tyler
Task : Query day shift
DB: bodb_OWP  
  
Revisions:  
 20201003@Tyler: get other assignments  - [Redmine: #142258] 
 20201020@Tyler: Remove EventDate  - [Redmine: #143792] 
*/

     SELECT m.PreMatchIssueId, 
            x.InfoSiteMatchId, 
            im.[Message],
            CASE
                WHEN r.IsRead IS NULL
                THEN 1
                ELSE r.IsRead
            END AS 'IsRead'
     FROM(
         SELECT i.InfoSiteMatchId, 
                MAX(m.CreatedDate) AS 'MaxDate'
         FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
              LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
         WHERE i.InfoSiteMatchId IS NOT NULL
         GROUP BY i.InfoSiteMatchId) AS x
         INNER JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.InfoSiteMatchId = x.InfoSiteMatchId
         INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = m.PreMatchIssueId
         LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                    AND r.UserId = @ActorId
     WHERE im.CreatedDate = x.MaxDate;