
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_SyncNotification_MessageInsert] @Messages        NVARCHAR(MAX), 
                                                            @CreatedByUserId INT, 
                                                            @SessionId       VARCHAR(50)
AS

/*
Created: 20200728@Esther
Task : Ready to Trade Status 
DB: bodb_OWP

Revisions:
	20200728@Esther: Staff's readiness notification - [Redmine: #137751]
	
*/

     SET NOCOUNT ON;
     CREATE TABLE #tmpMessage
     (MessageContent     NVARCHAR(MAX), 
      IsImportant        BIT, 
      MessageType        TINYINT, 
      IsWatcher          BIT, 
      ReceivedUserIds NVARCHAR(MAX)
     );
     CREATE TABLE #tblMessageUser
     (MessageId          INT, 
      ReceivedUserIds NVARCHAR(MAX)
     );
     DECLARE @CreatedDate DATETIME = GETDATE();
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
                   ReceivedUserIds
            FROM OPENXML(@idoc, '/Root/MessageModel', 1) WITH(MessageContent NVARCHAR(MAX), IsImportant BIT, MessageType TINYINT, IsWatcher BIT, ReceivedUserIds NVARCHAR(MAX));
     EXEC sp_xml_removedocument 
          @idoc;

     -- insert message
     MERGE dbo.[Message] WITH(ROWLOCK) AS ms
     USING
     (
         SELECT m.ReceivedUserIds, 
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
      @CreatedDate, 
      msn.IsImportant, 
      msn.MessageType, 
      msn.IsWatcher
     )
     OUTPUT inserted.MessageId, 
            msn.ReceivedUserIds
            INTO #tblMessageUser(MessageId, 
                                 ReceivedUserIds);

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
                 CROSS APPLY fnc_SplitStrings(mu.ReceivedUserIds, ',');

     -- insert NotificationQueue
     INSERT INTO dbo.NotificationQueue
     ([SessionId], 
      [CreatedDate]
     )
            SELECT @SessionId, 
                   @CreatedDate;

     -- drop temp table
     DROP TABLE #tmpMessage;
     DROP TABLE #tblMessageUser;