ALTER PROC [dbo].[OWP_TicketCenter_InsertNewRecipientNotification] 
	@NotificationContent NVARCHAR(MAX),
	@SessionId VARCHAR(100)  = NULL,
	@IsImportant BIT,
	@IsWatcher BIT,
	@ReceivedUserId INT,
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

	INSERT INTO @tblReceivedUser(Id) VALUES(@ReceivedUserId);

	EXEC dbo.OWP_MessageInsert 
		@UserId = @ActorId,
		@MessageContent = @NotificationContent,
		@SessionId = @SessionId,
		@IsImportant = @IsImportant, 
        @IsWatcher = @IsWatcher,
		@MessageTo = @tblReceivedUser,
		@MessageType = @NotificationType
END