/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_MessageInsert] @Messages        NVARCHAR(MAX), 
                                                           @CreatedByUserId INT, 
                                                           @SessionId       VARCHAR(50)
AS

/*
Created: 20200604@Mira
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200604@Mira: New structure of Assignment Uploading - [Redmine: #129397]
	20250120@Assistant: Only insert message if IsWatcher is 0 - [Redmine: #235398]
	20250930@Hank: Remove insert watcher message - [Redmine: #236509]
*/

     SET NOCOUNT ON;
     CREATE TABLE #tmpMessage
     (MessageContent   NVARCHAR(MAX), 
      IsImportant      BIT, 
      MessageType      TINYINT, 
      IsWatcher        BIT, 
      ReceivedUserIdList NVARCHAR(MAX)
     );
     CREATE TABLE #tblMessageUser
     (MessageId        INT, 
      ReceivedUserIdList NVARCHAR(MAX)
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
                   ReceivedUserIdList
            FROM OPENXML(@idoc, '/Root/MessageModel', 1) WITH(MessageContent NVARCHAR(MAX), IsImportant BIT, MessageType TINYINT, IsWatcher BIT, ReceivedUserIdList NVARCHAR(MAX))
            WHERE IsWatcher = 0;
     EXEC sp_xml_removedocument 
          @idoc;

     -- insert message
     MERGE dbo.[Message] WITH(ROWLOCK) AS ms
     USING
     (
         SELECT m.ReceivedUserIdList, 
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
            msn.ReceivedUserIdList
            INTO #tblMessageUser(MessageId, 
                                 ReceivedUserIdList);

     -- insert messageUser
     INSERT INTO dbo.MessageUser
     ([MessageId], 
      [UserId], 
      [SessionId]
     )
            SELECT mu.MessageId, 
                   val, 
                   @SessionId
            FROM #tblMessageUser mu
                 CROSS APPLY fnc_SplitStrings(mu.ReceivedUserIdList, ',');

     -- drop temp table
     DROP TABLE #tmpMessage;
     DROP TABLE #tblMessageUser;