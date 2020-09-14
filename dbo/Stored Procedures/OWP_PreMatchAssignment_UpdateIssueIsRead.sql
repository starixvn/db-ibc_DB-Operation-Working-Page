USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_UpdateIssueIsRead]    Script Date: 9/14/2020 11:04:23 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_UpdateIssueIsRead] @ActorId         INT, 
                                                                 @PreMatchIssueId INT, 
                                                                 @IsRead          BIT
AS

/*
Created: 202000914@Tyler
Task : Update IsRead issue
DB: bodb_OWP

Revisions:
	202000914@Tyler: Init sync SP - [Redmine: #140620]
	
*/

     SET NOCOUNT ON;
     UPDATE dbo.[PreMatchIssueReceiver] WITH(ROWLOCK)
       SET 
           IsRead = @IsRead
     WHERE UserId = @ActorId
           AND PreMatchIssueId = @PreMatchIssueId;