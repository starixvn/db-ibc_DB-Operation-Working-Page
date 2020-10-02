USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_InsertNewMessage]    Script Date: 9/22/2020 8:56:23 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertNewMessage] @ActorId         INT, 
                                                                @Message         NVARCHAR(MAX), 
                                                                @PreMatchIssueId INT
AS

/*
Created: 20200914@Tyler
Task : Insert new message
DB: bodb_OWP

Revisions:
	20200914@Tyler: Init sync SP - [Redmine: #140620]
	
*/

     SET NOCOUNT ON;
     DECLARE @insertTime DATETIME= GETDATE();
     INSERT INTO [dbo].[PreMatchIssueMessage]
     ([PreMatchIssueId], 
      [CreatedDate], 
      [UserId], 
      [Message]
     )
     VALUES
     (@PreMatchIssueId, 
      @insertTime, 
      @ActorId, 
      @Message
     );
     IF NOT EXISTS
     (
         SELECT 1
         FROM dbo.[PreMatchIssueReceiver] WITH(NOLOCK)
         WHERE UserId = @ActorId
               AND PreMatchIssueId = @PreMatchIssueId
     )
         BEGIN
             INSERT INTO [dbo].[PreMatchIssueReceiver]
             ([PreMatchIssueId], 
              [UserId], 
              [IsRead]
             )
             VALUES
             (@PreMatchIssueId, 
              @ActorId, 
              1
             );
     END;
         ELSE
         BEGIN
             UPDATE dbo.[PreMatchIssueReceiver] WITH(ROWLOCK)
               SET 
                   IsRead = 0
             WHERE PreMatchIssueId = @PreMatchIssueId
                   AND UserId <> @ActorId;

             -- Set undone
             UPDATE dbo.[PreMatchIssue] WITH(ROWLOCK)
               SET 
                   IsDone = 0
             WHERE PreMatchIssueId = @PreMatchIssueId;
     END;