
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetNextListMessage] @MsgOfPage          INT = 20, 
                                                            @TicketId           INT, 
                                                            @FirstMsgId         INT = NULL, 
                                                            @CanShowMoreMessage BIT = 0 OUTPUT
AS

/*      
 Created: 20221222@liam.pham
 Task : get list message 
 DB: bodb_OWP      
      
 Revisions:          
	20221222@liam.pham: get next list message - [Redmine: #181438]
	20230801@Johnny: Get quote message - [Redmine: #191543]
	20230801@Liam: Get image file name - [Redmine: #191543]
	20240617@Liam: Get correct text message  [Redmine: #206560]
	20240522@Los: Get extension - [Redmine: #201603]
*/

    BEGIN
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
         Username       VARCHAR(100), 
         QuoteMessageId INT, 
         ImageFileName  NVARCHAR(200),
		 Extension NVARCHAR(200)
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
               SELECT TOP (@MsgOfPage) tm.CreatedDate, 
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
               FROM TicketMessage AS tm
                    LEFT JOIN [User] AS u ON u.UserId = tm.UserId
                    LEFT JOIN [FileUpload] AS f ON tm.FileId = f.FileId
               WHERE tm.TicketId = @TicketId
                     AND (@FirstMsgId IS NULL
                          OR tm.Id < @FirstMsgId)
               ORDER BY tm.Id DESC;

        -- select ticket detail
        SELECT tm.CreatedDate, 
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
			   f.SavedFileName 'AvatarFileName'
        FROM #tblMessageDetail AS tm
             LEFT JOIN TicketMessage AS ti WITH(NOLOCK) ON tm.QuoteMessageId = ti.Id
             LEFT JOIN [User] AS u WITH(NOLOCK) ON ti.UserId = u.UserId
			 LEFT JOIN UserProfile AS up WITH(NOLOCK) ON up.UserId=tm.UserId
             LEFT JOIN dbo.FileUpload f WITH(NOLOCK) ON f.FileId = up.FileId
        ORDER BY tm.MessageId ASC;

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