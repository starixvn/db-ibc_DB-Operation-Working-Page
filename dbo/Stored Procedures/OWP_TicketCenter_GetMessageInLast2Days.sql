
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetMessageInLast2Days] @TicketId           INT, 
                                                               @CanShowMoreMessage BIT = 0 OUTPUT
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get ticket league detail
 DB: bodb_OWP      
      
 Revisions: 
	20221222@Mira: Refactor flow get detail - [Redmine: #181438]
	20230209@Johnny: Edit data type for message - [Redmine: #183655]
	20230801@Johnny: Get quote message - [Redmine: #191543]
	20230801@Liam: Get image file name - [Redmine: #191543]
	20240522@Los: Get extension - [Redmine: #201603]
	20240822@Mira: Change range time - [Redmine: #207945]
*/

    BEGIN
        DECLARE @GMT8Time DATETIME= DATEADD(HOUR, 8, CONVERT(DATETIME, GETUTCDATE()));
        DECLARE @FromDateTime DATETIME= DATEDIFF(DAY, 2, @GMT8Time);
        SET NOCOUNT ON;
        DECLARE @MinMessageId INT;
        DECLARE @MinCurrentMessageId INT;
        CREATE TABLE #tblMessageDetail
        (CreatedDate    DATETIME NOT NULL, 
         MessageId      INT NOT NULL, 
         [Message]      NVARCHAR(2000) NOT NULL, 
         UserId         INT NOT NULL, 
         FileId         INT, 
         IsSaved        BIT, 
         Username       NVARCHAR(100), 
         QuoteMessageId INT, 
         ImageFileName  NVARCHAR(200), 
         Extension      NVARCHAR(200)
        );
        INSERT INTO #tblMessageDetail
        (CreatedDate, 
         MessageId, 
         [Message], 
         UserId, 
         FileId, 
         IsSaved, 
         Username, 
         QuoteMessageId, 
         ImageFileName, 
         Extension
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
                      END AS Username, 
                      tm.QuoteMessageId,
                      CASE
                          WHEN f.Title LIKE '%.jpg'
                               OR f.Title LIKE '%.jpeg'
                               OR f.Title LIKE '%.png'
                               OR f.Title LIKE '%.gif'
                               OR f.Title LIKE '%.bmp'
                          THEN f.SavedFileName
                          ELSE NULL
                      END, 
                      u.Extension
               FROM TicketMessage AS tm WITH(NOLOCK)
                    LEFT JOIN [User] AS u WITH(NOLOCK) ON u.UserId = tm.UserId
                    LEFT JOIN [FileUpload] AS f WITH(NOLOCK) ON tm.FileId = f.FileId
               WHERE tm.TicketId = @TicketId
                     AND tm.CreatedDate >= @FromDateTime;

        -- select ticket detail
        SELECT @TicketId 'TicketId', 
               tm.CreatedDate, 
               tm.MessageId, 
               tm.[Message], 
               tm.UserId, 
               tm.FileId, 
               tm.IsSaved, 
               tm.Username, 
               ti.[Message] AS QuoteMessage,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS QuoteUsername, 
               tm.QuoteMessageId, 
               ti.CreatedDate AS QuoteCreatedDate, 
               tm.ImageFileName, 
               tm.Extension, 
               fu.SavedFileName 'AvatarFileName'
        FROM #tblMessageDetail AS tm
             LEFT JOIN TicketMessage AS ti WITH(NOLOCK) ON tm.QuoteMessageId = ti.Id
             LEFT JOIN [User] AS u WITH(NOLOCK) ON ti.UserId = u.UserId
             LEFT JOIN UserProfile AS up WITH(NOLOCK) ON up.UserId = tm.UserId
             LEFT JOIN FileUpload AS fu WITH(NOLOCK) ON fu.FileId = up.FileId;

        -- Can show more message
        SELECT @MinMessageId = MIN(tm.Id)
        FROM TicketMessage AS tm
        WHERE tm.TicketId = @TicketId;
        SELECT @MinCurrentMessageId = MIN(tm.MessageId)
        FROM #tblMessageDetail AS tm;
        IF @MinMessageId IS NULL
            BEGIN
                SET @MinMessageId = -1;
        END;
        IF @MinCurrentMessageId IS NULL
            BEGIN
                SET @MinCurrentMessageId = -1;
        END;
        SELECT @CanShowMoreMessage = CASE
                                         WHEN @MinCurrentMessageId = @MinMessageId
                                         THEN 0
                                         ELSE 1
                                     END;
        DROP TABLE #tblMessageDetail;
    END;