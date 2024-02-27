USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_TicketIssueMessage_Create]    Script Date: 09/23/2021 11:18:03 ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketIssueMessage_Create] @TicketId       INT, 
                                                      @Message        NVARCHAR(2000), 
                                                      @UserId         INT, 
                                                      @IsSaved        BIT, 
                                                      @FileId         INT            = NULL, 
                                                      @QuoteMessageId INT            = NULL
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : New ticket issue message
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20220311@Johnny.Thai: Update LastComment - [Redmine: #169841]
	20230801@Johnny: Get quote message - [Redmine: #191543]
	20240216@Los: Refactor ticket center - [Redmine: #200671]
*/

    BEGIN
        SET NOCOUNT ON;
        UPDATE TicketIssue
          SET 
              LastCommentDate = DATEADD(HOUR, 12, GETDATE())
        FROM TicketIssue AS a
        WHERE a.TicketId = @TicketId;
        INSERT INTO TicketMessage
        (TicketId, 
         CreatedDate, 
         [Message], 
         UserId, 
         IsSaved, 
         FileId, 
         QuoteMessageId
        )
        VALUES
        (@TicketId, 
         DATEADD(HOUR, 12, GETDATE()), 
         @Message, 
         @UserId, 
         0, 
         @FileId, 
         @QuoteMessageId
        );
        DECLARE @id INT;
        SELECT @id = MAX(tm.Id)
        FROM TicketMessage AS tm;
        CREATE TABLE #tblMessageDetail
        (CreatedDate    DATETIME NOT NULL, 
         MessageId      INT NOT NULL, 
         [Message]      NVARCHAR(2000) NOT NULL, 
         UserId         INT NOT NULL, 
         FileId         INT, 
         IsSaved        BIT, 
         Username       NVARCHAR(100), 
         QuoteMessageId INT
        );
        INSERT INTO #tblMessageDetail
        (CreatedDate, 
         MessageId, 
         [Message], 
         UserId, 
         FileId, 
         IsSaved, 
         Username, 
         QuoteMessageId
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
                      tm.QuoteMessageId
               FROM TicketMessage AS tm
                    LEFT JOIN [User] AS u ON u.UserId = tm.UserId
               WHERE tm.Id = @id;

        -- select ticket detail
        SELECT tm.CreatedDate, 
               tm.MessageId, 
               tm.[Message], 
               tm.UserId, 
               tm.FileId, 
               tm.IsSaved, 
               tm.Username, 
               ti.[Message] AS QuoteMessage,
			   tm.QuoteMessageId,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS QuoteUsername, 
               ti.CreatedDate AS QuoteCreatedDate,
               CASE
                   WHEN f.Title LIKE '%.jpg'
                        OR f.Title LIKE '%.jpeg'
                        OR f.Title LIKE '%.png'
                        OR f.Title LIKE '%.gif'
                        OR f.Title LIKE '%.bmp'
                   THEN f.SavedFileName 
                   ELSE NULL 
               END 'ImageFileName'
        FROM #tblMessageDetail AS tm
             LEFT JOIN TicketMessage AS ti ON tm.QuoteMessageId = ti.Id
             LEFT JOIN [User] AS u ON ti.UserId = u.UserId
             LEFT JOIN [FileUpload] AS f ON tm.FileId = f.FileId;
    END;