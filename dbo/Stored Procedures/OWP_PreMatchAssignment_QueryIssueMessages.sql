
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

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
	20201202@Esther: Show message in the last 24 hours  - [Redmine: #145591]
	20201201@Tyler: file upload  - [Redmine: #145591]
	20210113@Mira: save message in chat board - [Redmine: #148266]
	20241002@Mira: join with File Upload Old [Redmine: #211716]
*/

    BEGIN
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
               END AS IsMyMessage, 
               im.FileId,
               CASE
                   WHEN im.FileId IS NULL
                        OR ISNULL(f.FileId, fo.FileId) IS NULL
                   THEN 0
                   ELSE 1
               END AS 'IsFileAvailable', 
               im.IsSaved, 
               im.PreMatchIssueMessageId
        FROM dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchIssue] AS i WITH(NOLOCK) ON im.PreMatchIssueId = i.PreMatchIssueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.UserId = im.UserId
             LEFT JOIN dbo.[FileUpload] AS f WITH(NOLOCK) ON im.FileId = f.FileId
             LEFT JOIN dbo.[FileUpload_Old] AS fo WITH(NOLOCK) ON im.FileId = fo.FileId
                                                                  AND f.FileId IS NULL
        WHERE i.PreMatchIssueId = @PreMatchIssueId
        ORDER BY CreatedDate ASC;
        SELECT DATEADD(HOUR, 12, GETDATE());
    END;