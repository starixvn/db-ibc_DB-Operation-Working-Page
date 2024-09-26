/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_UpdateIssueIsRead] @ActorId         INT, 
                                                                 @PreMatchIssueId INT, 
                                                                 @IsRead          BIT
AS

/*
Created: 20200914@Tyler
Task : Update IsRead issue
DB: bodb_OWP

Revisions:
	20200914@Tyler: Init sync SP - [Redmine: #140620]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  	
*/

     SET NOCOUNT ON;
     UPDATE dbo.[PreMatchIssueReceiver] WITH(ROWLOCK)
       SET 
           IsRead = @IsRead
     WHERE UserId = @ActorId
           AND PreMatchIssueId = @PreMatchIssueId;