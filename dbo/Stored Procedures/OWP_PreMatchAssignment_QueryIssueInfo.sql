
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryIssueInfo] @PreMatchIssueId INT
AS

/*  
Created: 20201119@Tyler.Dang  
Task : Query issue info
DB: bodb_OWP  
  
Revisions:  
	20201119@Tyler: Init SP  - [Redmine: #145568]  
*/

     SET NOCOUNT ON;
     SELECT im.PreMatchIssueId, 
            im.[Message] AS 'MessageContent', 
            DATEADD(HOUR, 12, im.CreatedDate) AS 'CreatedDate',
            CASE
                WHEN u.Nickname IS NULL
                THEN u.Username
                ELSE u.Nickname
            END AS Nickname
     FROM dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK)
          INNER JOIN dbo.[PreMatchIssue] AS i WITH(NOLOCK) ON im.PreMatchIssueId = i.PreMatchIssueId
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.UserId = im.UserId
     WHERE i.PreMatchIssueId = @PreMatchIssueId
     ORDER BY CreatedDate ASC;