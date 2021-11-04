USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenter_InsertNewRecipientNotification]    Script Date: 10/29/2021 08:08:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROC [dbo].[OWP_TicketCenter_InsertNewRecipientNotification] 
	@NotificationContent NVARCHAR(MAX),
	@SessionId VARCHAR(100)  = NULL,
	@IsImportant BIT,
	@IsWatcher BIT,
	@ReceivedUserId INT,
	@ReceivedUserType INT,
	@ActorId INT,
	@NotificationType INT 
  
AS
/*
Created: Luca.Duong
Task : send notification when there's add new recipient
DB: bodb_OWP

Revisions:
	Luca.Duong: Init SP - [Redmine: #162851]
	
*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @tblReceivedUser TVP_INT;
	DECLARE @messageTemplate NVARCHAR(MAX);
	DECLARE @actorName NVARCHAR(50);
	--
	SELECT TOP 1 @actorName = CASE
           WHEN Nickname IS NOT NULL
           THEN Nickname
           ELSE Username
		END
     FROM dbo.[User] WITH(NOLOCK)
     WHERE UserId = @ActorId;
	SELECT @messageTemplate = REPLACE(@NotificationContent, '<username>', @actorName);
	--
	IF @ReceivedUserType = 1
	BEGiN
		INSERT INTO @tblReceivedUser(Id) VALUES(@ReceivedUserId);
	END
	ELSE
	BEGIN
		INSERT INTO @tblReceivedUser(Id)
		SELECT RecipientId FROM RecipientGroup WHERE GroupId = @ReceivedUserId;
	END
	--
	 DELETE FROM @tblReceivedUser
	 WHERE Id=@ActorId
	--
	EXEC dbo.OWP_MessageInsert 
		@UserId = @ActorId,
		@MessageContent = @messageTemplate,
		@SessionId = @SessionId,
		@IsImportant = @IsImportant, 
        @IsWatcher = @IsWatcher,
		@MessageTo = @tblReceivedUser,
		@MessageType = @NotificationType
END