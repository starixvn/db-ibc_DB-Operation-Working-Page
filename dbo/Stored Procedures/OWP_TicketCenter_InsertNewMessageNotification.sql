USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenter_InsertNewMessageNotification]    Script Date: 11/1/2021 9:46:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_InsertNewMessageNotification] 
    @ActorId             INT, 
    @IsImportant         BIT, 
    @IsWatcher           BIT, 
    @NotificationType    INT, 
    @SessionId           VARCHAR(100)  = NULL, 
    @TicketId            INT, 
    @NotificationContent NVARCHAR(MAX)
AS
/*
Created: 20211101@Luca.Duong
Task : send notification when there's send comment to recipient
DB: bodb_OWP

Revisions:
	20211101@Luca.Duong: Init SP - [Redmine: #163895]
	
*/
BEGIN
     SET NOCOUNT ON;
     DECLARE @messageTemplate NVARCHAR(MAX);
     
     -- username
     DECLARE @actorName NVARCHAR(50);
     DECLARE @tblReceivedUser TVP_INT;
     SELECT TOP 1 @actorName = CASE
                             WHEN Nickname IS NOT NULL
                             THEN Nickname
                             ELSE Username
                         END
     FROM dbo.[User] WITH(NOLOCK)
     WHERE UserId = @ActorId;
     -- end
     
     SELECT @messageTemplate = REPLACE(@NotificationContent, '<username>', @actorName);
     
     INSERT INTO @tblReceivedUser(Id)
	 EXEC [dbo].[OWP_TicketCenterEvent_GetUserIdsByTicketId] @TicketId=@TicketId
	 
	 -- Delete creatorId
	 DELETE FROM @tblReceivedUser
	 WHERE Id=@ActorId
	 
     EXEC dbo.OWP_MessageInsert 
          @UserId = @ActorId, 
          @MessageContent = @messageTemplate, 
          @MessageType = @NotificationType, 
          @MessageTo = @tblReceivedUser, 
          @IsImportant = @IsImportant, 
          @IsWatcher = @IsWatcher, 
          @SessionId = @SessionId;
END;