/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_EditNoteMessage] @ActorId               INT, 
                                                               @Message               NVARCHAR(MAX), 
                                                               @PreMatchNoteMessageId INT, 
                                                               @CreatedDate           DATETIME OUTPUT, 
                                                               @Username              NVARCHAR(30) OUTPUT
AS

/*
Created: 20201006@Tyler
Task : edit note
DB: bodb_OWP

Revisions:
	20201006@Tyler: Init SP - [Redmine: #142258]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  	
*/

     SET NOCOUNT ON;
     DECLARE @editTime DATETIME= GETDATE();
     UPDATE dbo.[PreMatchNoteMessage] WITH(ROWLOCK)
       SET 
           Message = @Message, 
           UserId = @ActorId
     WHERE PreMatchNoteMessageId = @PreMatchNoteMessageId;
     SELECT @CreatedDate = DATEADD(HOUR, 12, @editTime), 
            @Username = CASE
                            WHEN u.Nickname IS NOT NULL
                            THEN u.Nickname
                            ELSE u.Username
                        END
     FROM dbo.[User] AS u WITH(NOLOCK)
     WHERE u.UserId = @ActorId;