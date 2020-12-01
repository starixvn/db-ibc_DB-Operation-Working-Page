
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryIssueMessages] @ActorId         INT, 
                                                                  @PreMatchIssueId INT
AS

/*  
Created: 20200909@Tyler.Dang  
Task : Query issue messages
DB: bodb_OWP  
  
Revisions:  
	20200909@Tyler: Init SP  - [Redmine: #140620]  
 	20201003@Tyler: update other assignments  - [Redmine: #142258]  
	20201119@Mira: is my message  - [Redmine: #145568]  
*/

     SET NOCOUNT ON;
     SELECT im.PreMatchIssueId, 
            im.[Message] AS 'MessageContent', 
            DATEADD(HOUR, 12, im.CreatedDate) AS 'CreatedDate',
            CASE
                WHEN u.Nickname IS NULL
                THEN u.Username
                ELSE u.Nickname
            END AS Nickname,
            CASE
                WHEN im.UserId = @ActorId
                THEN 1
                ELSE 0
            END AS IsMyMessage
     FROM dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK)
          INNER JOIN dbo.[PreMatchIssue] AS i WITH(NOLOCK) ON im.PreMatchIssueId = i.PreMatchIssueId
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.UserId = im.UserId
     WHERE i.PreMatchIssueId = @PreMatchIssueId
     ORDER BY CreatedDate ASC;