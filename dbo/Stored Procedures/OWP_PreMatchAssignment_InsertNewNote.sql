/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertNewNote] @ActorId               INT, 
                                                             @Message               NVARCHAR(MAX), 
                                                             @OWPLeagueId           INT           = NULL, 
                                                             @EventDate             DATE, 
                                                             @InfoSiteMatchId       INT           = NULL, 
                                                             @CreatedDate           DATETIME OUTPUT, 
                                                             @Username              NVARCHAR(30) OUTPUT, 
                                                             @PreMatchNoteId        INT OUTPUT, 
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
     DECLARE @noteId INT;
     DECLARE @noteMesageId INT;
     DECLARE @insertTime DATETIME= GETDATE();
     SELECT @noteId = PreMatchNoteId
     FROM [dbo].[PreMatchNote] WITH(NOLOCK)
     WHERE(OWPLeagueId = @OWPLeagueId
           OR InfoSiteMatchId = @InfoSiteMatchId)
          AND EventDate = @EventDate;

     -- If PreMatchIssue not exists
     IF @noteId IS NULL
         BEGIN
             INSERT INTO [dbo].[PreMatchNote]
             ([OWPLeagueId], 
              [InfoSiteMatchId], 
              [EventDate]
             )
             VALUES
             (@OWPLeagueId, 
              @InfoSiteMatchId, 
              @EventDate
             );
             SELECT @noteId = SCOPE_IDENTITY();

             -- Insert message
             INSERT INTO [dbo].[PreMatchNoteMessage]
             ([PreMatchNoteId], 
              [CreatedDate], 
              [UserId], 
              [Message]
             )
             VALUES
             (@noteId, 
              @insertTime, 
              @ActorId, 
              @Message
             );
             SELECT @noteMesageId = SCOPE_IDENTITY();
         END;
         ELSE
         BEGIN
             EXEC dbo.[OWP_PreMatchAssignment_InsertNewNoteMessage] 
                  @ActorId, 
                  @Message, 
                  @PreMatchNoteId = @noteId, 
                  @PreMatchNoteMessageId = @noteMesageId;
         END;
     SELECT @CreatedDate = DATEADD(HOUR, 12, @insertTime), 
            @Username = CASE
                            WHEN u.Nickname IS NOT NULL
                            THEN u.Nickname
                            ELSE u.Username
                        END, 
            @PreMatchNoteId = @noteId, 
            @PreMatchNoteMessageId = @noteMesageId
     FROM dbo.[User] AS u WITH(NOLOCK)
     WHERE u.UserId = @ActorId;