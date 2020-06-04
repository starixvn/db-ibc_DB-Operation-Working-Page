
ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_MessageInsert] @Messages        NVARCHAR(MAX), 
                                                           @CreatedByUserId INT, 
                                                           @SessionId       VARCHAR(50)
AS

/*
Created: 20200604@Mira
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200604@Mira: New structure of Assignment Uploading - [Redmine: #129397]
	
*/

     SET NOCOUNT ON;
     CREATE TABLE #tmpMessage
     (MessageContent NVARCHAR(MAX), 
      IsImportant    BIT, 
      MessageType    TINYINT, 
      IsWatcher      BIT, 
      AssigneeId     INT, 
      AssigneeName   NVARCHAR(MAX)
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @Messages;
     INSERT INTO #tmpMessage
            SELECT DISTINCT 
                   MessageContent, 
                   IsImportant, 
                   MessageType, 
                   IsWatcher, 
                   AssigneeId, 
                   AssigneeName
            FROM OPENXML(@idoc, '/Root/MessageTemplate', 1) WITH(MessageContent NVARCHAR(MAX), IsImportant BIT, MessageType TINYINT, IsWatcher BIT, AssigneeId INT, AssigneeName NVARCHAR(MAX));
     EXEC sp_xml_removedocument 
          @idoc;

     -- insert message
     MERGE dbo.[Message] WITH(ROWLOCK) AS ms
     USING
     (
         SELECT m.AssigneeId, 
                m.MessageContent, 
                m.MessageType, 
                m.IsImportant, 
                m.IsWatcher
         FROM #tmpMessage AS m
     ) AS msn
     ON 1 = 0
         WHEN NOT MATCHED
         THEN
           INSERT(MessageContent, 
                  CreatedBy, 
                  CreatedDate, 
                  IsImportant, 
                  MessageType, 
                  IsWatcher)
           VALUES
     (msn.MessageContent, 
      @CreatedByUserId, 
      GETDATE(), 
      msn.IsImportant, 
      msn.MessageType, 
      msn.IsWatcher
     )
     OUTPUT inserted.MessageId, 
            msn.AssigneeId, 
            @SessionId
            INTO dbo.MessageUser([MessageId], 
                                 [UserId], 
                                 [SessionId]);
     DROP TABLE #tmpMessage;