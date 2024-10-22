/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_DeleteNoteMessage] @PreMatchNoteMessageId INT
AS

/*
Created: 20201006@Tyler
Task : edit note
DB: bodb_OWP

Revisions:
	20201006@Tyler: Init SP - [Redmine: #142258]
	
*/

     SET NOCOUNT ON;
     DECLARE @noteId INT;
     SELECT @noteId = PreMatchNoteId
     FROM dbo.[PreMatchNoteMessage] WITH(NOLOCK)
     WHERE PreMatchNoteMessageId = @PreMatchNoteMessageId;
     DELETE FROM dbo.[PreMatchNoteMessage] WITH(ROWLOCK)
     WHERE PreMatchNoteMessageId = @PreMatchNoteMessageId;
     DELETE n
     FROM dbo.[PreMatchNote] n WITH(ROWLOCK)
     WHERE PreMatchNoteId = @noteId
           AND NOT EXISTS
     (
         SELECT 1
         FROM dbo.[PreMatchNoteMessage] WITH(NOLOCK)
         WHERE PreMatchNoteId = @noteId
     );