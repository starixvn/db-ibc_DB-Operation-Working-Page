
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketCenter_GetAllMessageBySubtypeId] @ActorId      INT, 
                                                                 @SubtypeId    INT = NULL, 
                                                                 @TicketTypeId INT = NULL
AS

/*      
 Created: 20240816@Liam.Pham
 Task : Get all message by subtype 
 DB: bodb_OWP      
      
 Revisions:         
	20240816@Liam.Pham: Get All message by subtype - [Redmine: #207945]

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @DateValid DATETIME;
        SET @DateValid = DATEADD(DAY, -3, GETDATE());
        CREATE TABLE #tblTicketValid(TicketId INT);
        CREATE TABLE #tblTicketRecipient(TicketId INT);
        INSERT INTO #tblTicketValid
               SELECT t.TicketId
               FROM TicketIssue t WITH(NOLOCK)
               WHERE t.LastCommentDate > @DateValid
                     AND TicketType = @TicketTypeId;
        INSERT INTO #tblTicketRecipient
               SELECT tr.TicketId
               FROM TicketRecipient AS tr WITH(NOLOCK)
                    INNER JOIN #tblTicketValid AS ti WITH(NOLOCK) ON tr.TicketId = ti.TicketId
               WHERE tr.RecipientType = 1
                     AND tr.RecipientId = @ActorId
               UNION ALL
               SELECT tr.TicketId
               FROM TicketRecipient AS tr WITH(NOLOCK)
                    INNER JOIN #tblTicketValid AS ti WITH(NOLOCK) ON tr.TicketId = ti.TicketId
                    INNER JOIN RecipientGroup AS rg WITH(NOLOCK) ON tr.RecipientId = rg.GroupId
               WHERE tr.RecipientType = 2
                     AND rg.RecipientId = @ActorId
               UNION ALL
               SELECT tr.TicketId
               FROM TicketRecipient AS tr WITH(NOLOCK)
                    INNER JOIN #tblTicketValid AS ti WITH(NOLOCK) ON tr.TicketId = ti.TicketId
                    INNER JOIN [User] AS u WITH(NOLOCK) ON tr.RecipientId = u.SectionId
               WHERE tr.RecipientType = 3
                     AND u.UserId = @ActorId;

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
               ti.[Message] AS QuoteMessage, 
               tm.QuoteMessageId,
               CASE
                   WHEN u2.Nickname IS NULL
                   THEN u2.Username
                   ELSE u2.Nickname
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
               END AS ImageFileName, 
               u.Extension, 
               tm.TicketId, 
               fu.SavedFileName AS AvatarFileName
        FROM TicketMessage AS tm WITH(NOLOCK)
             INNER JOIN #tblTicketRecipient tbl ON tm.TicketId = tbl.TicketId
             LEFT JOIN [User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
             LEFT JOIN [FileUpload] AS f WITH(NOLOCK) ON tm.FileId = f.FileId
             LEFT JOIN TicketMessage AS ti WITH(NOLOCK) ON tm.QuoteMessageId = ti.Id
             LEFT JOIN [User] AS u2 WITH(NOLOCK) ON ti.UserId = u2.UserId
             LEFT JOIN UserProfile AS up WITH(NOLOCK) ON up.UserId = tm.UserId
             LEFT JOIN FileUpload AS fu WITH(NOLOCK) ON fu.FileId = up.FileId;

        DROP TABLE #tblTicketRecipient;
        DROP TABLE #tblTicketValid;
    END;