/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_InsertNewTicketSupportNotification] @ActorId             INT, 
                                                                            @IsImportant         BIT, 
                                                                            @IsWatcher           BIT, 
                                                                            @NotificationType    INT, 
                                                                            @SessionId           VARCHAR(100)  = NULL, 
                                                                            @TicketId            INT, 
                                                                            @NotificationContent NVARCHAR(MAX)
AS

/*
Created: 20211231@Johnny.Thai
Task : send notification when there's a new message inserted
DB: bodb_OWP

Revisions:
	20211231@Johnny.Thai: Init SP - [Redmine: #162851]
	20230807@Los: Get ticket event - [Redmine: #191778]
*/

     SET NOCOUNT ON;
     DECLARE @messageTemplate NVARCHAR(MAX);
     DECLARE @eventName NVARCHAR(2000);

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
     -- Subject name
     SELECT TOP 1 @eventName = tis.[Subject]
     FROM dbo.[TicketIssue] AS tis WITH(NOLOCK)
     WHERE tis.TicketId = @TicketId;
     -- end

     SELECT @messageTemplate = REPLACE(REPLACE(@NotificationContent, '<Event>', @eventName), '<username>', @actorName);
     INSERT INTO @tblReceivedUser(Id)
     EXEC [dbo].[OWP_TicketCenterEvent_GetUserIdsByTicketId] 
          @TicketId = @TicketId;

     -- Delete creatorId
     DELETE FROM @tblReceivedUser
     WHERE Id = @ActorId;
     EXEC dbo.OWP_MessageInsert 
          @UserId = @ActorId, 
          @MessageContent = @messageTemplate, 
          @MessageType = @NotificationType, 
          @MessageTo = @tblReceivedUser, 
          @IsImportant = @IsImportant, 
          @IsWatcher = @IsWatcher, 
          @SessionId = @SessionId;