/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertNewNoteMessage] @ActorId               INT, 
                                                                    @Message               NVARCHAR(MAX), 
                                                                    @PreMatchNoteId        INT, 
                                                                    @CreatedDate           DATETIME OUTPUT, 
                                                                    @Username              NVARCHAR(30) OUTPUT, 
                                                                    @PreMatchNoteMessageId INT OUTPUT
AS

/*
Created: 20201006@Tyler
Task : Create new note
DB: bodb_OWP

Revisions:
	20201006@Tyler: Init SP - [Redmine: #142258]
	
*/

     SET NOCOUNT ON;
     DECLARE @insertTime DATETIME= GETDATE();
     DECLARE @noteMessageId INT;

     INSERT INTO [dbo].[PreMatchNoteMessage]
     ([PreMatchNoteId], 
      [CreatedDate], 
      [UserId], 
      [Message]
     )
     VALUES
     (@PreMatchNoteId, 
      @insertTime, 
      @ActorId, 
      @Message
     );
     SELECT @noteMessageId = SCOPE_IDENTITY();

     SELECT @CreatedDate = DATEADD(HOUR, 12, @insertTime), 
            @Username = CASE
                            WHEN u.Nickname IS NOT NULL
                            THEN u.Nickname
                            ELSE u.Username
                        END, 
            @PreMatchNoteMessageId = @noteMessageId
     FROM dbo.[User] AS u WITH(NOLOCK)
     WHERE u.UserId = @ActorId;