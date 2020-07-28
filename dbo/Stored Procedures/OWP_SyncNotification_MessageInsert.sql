
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_SyncNotification_MessageInsert] @Messages        NVARCHAR(MAX), 
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
      ReceivedUserIdList NVARCHAR(MAX)
     );
     CREATE TABLE #tblMessageUser
     (MessageId          INT, 
      ReceivedUserIdList NVARCHAR(MAX)
     );
     DECLARE @CreatedDate DATETIME= DATEADD(hh, 12, GETDATE());
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
            FROM OPENXML(@idoc, '/Root/MessageModel', 1) WITH(MessageContent NVARCHAR(MAX), IsImportant BIT, MessageType TINYINT, IsWatcher BIT, ReceivedUserIdList NVARCHAR(MAX));
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
      @CreatedDate, 
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