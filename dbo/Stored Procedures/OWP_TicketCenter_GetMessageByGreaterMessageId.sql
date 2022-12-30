
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetMessageByGreaterMessageId] @TicketId           INT, 
                                                                       @MessageId          INT, 
                                                                       @CanShowMoreMessage BIT = 0 OUTPUT
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get ticket league detail
 DB: bodb_OWP      
      
 Revisions: 
	20221222@Carlos: Refactor flow get detail - [Redmine: #181438]
*/

    BEGIN
        DECLARE @GMT8Time DATETIME= DATEADD(HOUR, 8, CONVERT(DATETIME, GETUTCDATE()));
        DECLARE @FromDateTime DATETIME= DATEDIFF(DAY, 2, @GMT8Time);
        SET NOCOUNT ON;
        DECLARE @MinMessageId INT;
    
        CREATE TABLE #tblMessageDetail
        (CreatedDate DATETIME NOT NULL, 
         MessageId   INT NOT NULL, 
         [Message]   VARCHAR(2000) NOT NULL, 
         UserId      INT NOT NULL, 
         FileId      INT, 
         IsSaved     BIT, 
         Username    VARCHAR(100)
        );
        INSERT INTO #tblMessageDetail
        (CreatedDate, 
         MessageId, 
         [Message], 
         UserId, 
         FileId, 
         IsSaved, 
         Username
        )
               SELECT DISTINCT 
                      tm.CreatedDate, 
                      tm.Id AS MessageId, 
                      tm.[Message], 
                      tm.UserId, 
                      tm.FileId, 
                      tm.IsSaved,
                      CASE
                          WHEN u.Nickname IS NULL
                          THEN u.Username
                          ELSE u.Nickname
                      END AS Username
               FROM TicketMessage AS tm
                    LEFT JOIN [User] AS u ON u.UserId = tm.UserId
               WHERE tm.TicketId = @TicketId
                     AND tm.Id>=@MessageId

        -- select ticket detail
        SELECT tm.CreatedDate, 
               tm.MessageId, 
               tm.[Message], 
               tm.UserId, 
               tm.FileId, 
               tm.IsSaved, 
               tm.Username
        FROM #tblMessageDetail AS tm;

        -- Can show more message
        SELECT @MinMessageId = MIN(tm.Id)
        FROM TicketMessage AS tm
        WHERE tm.TicketId = @TicketId;
       
        SELECT @CanShowMoreMessage = CASE
                                         WHEN @MessageId = @MinMessageId
                                         THEN 0
                                         ELSE 1
                                     END;
        DROP TABLE #tblMessageDetail;
    END;