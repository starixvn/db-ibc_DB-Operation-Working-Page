
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_GetIssueNotificationReceivers] @ActorId         INT, 
                                                                              @PreMatchIssueId INT
AS

/*
Created: 20200916@Tyler
Task : get notification receivers when there's a new message inserted
DB: bodb_OWP

Revisions:
	20200916@Tyler: Init SP - [Redmine: #140620]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  	
*/

     SET NOCOUNT ON;
     SELECT Username
     FROM dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK)
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON r.UserId = u.UserId
     WHERE PreMatchIssueId = @PreMatchIssueId
           AND r.UserId <> @ActorId
     UNION
     SELECT Username
     FROM dbo.[PreMatchIssueMessage] AS r WITH(NOLOCK)
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON r.UserId = u.UserId
     WHERE PreMatchIssueId = @PreMatchIssueId
           AND r.UserId <> @ActorId;