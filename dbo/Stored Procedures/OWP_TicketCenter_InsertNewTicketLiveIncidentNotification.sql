
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_InsertNewTicketLiveIncidentNotification] @ActorId             INT, 
                                                                                 @OwpLeagueName       NVARCHAR(MAX), 
                                                                                 @OwpHomeName         NVARCHAR(MAX), 
                                                                                 @OwpAwayName         NVARCHAR(MAX), 
                                                                                 @IsImportant         BIT, 
                                                                                 @IsWatcher           BIT, 
                                                                                 @NotificationType    INT, 
                                                                                 @SessionId           VARCHAR(100)  = NULL, 
                                                                                 @TicketId            INT, 
                                                                                 @NotificationContent NVARCHAR(MAX)
AS

/*
Created: 20221006@Johnny
Task : send notification when there's a new message inserted
DB: bodb_OWP

Revisions:
	20221006@Johnny: Init SP - [Redmine: #178183]
	20240216@Mira: Refactor ticket center - [Redmine: #200671]
*/

     SET NOCOUNT ON;
     DECLARE @messageTemplate NVARCHAR(MAX);
     DECLARE @eventName NVARCHAR(MAX);
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
     -- event name
     SELECT @eventName = @OwpLeagueName + ' - ' + @OwpHomeName + ' - vs - ' + @OwpAwayName;
     -- end

     SELECT @messageTemplate = REPLACE(REPLACE(@NotificationContent, '<Event>', @eventName), '<username>', @actorName);
     INSERT INTO @tblReceivedUser(Id)
            SELECT DISTINCT 
                   RecipientId
            FROM TicketMessageReader
            WHERE TicketId = @TicketId;

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