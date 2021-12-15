
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenterOther_Get] @ActorId        INT, 
                                                  @Keyword        NVARCHAR(255) = NULL, 
                                                  @TicketId       NVARCHAR(255) = NULL, 
                                                  @TicketStatuses VARCHAR(100), 
                                                  @TicketTypeId   INT           = 0, 
                                                  @MarketKey      INT           = 1
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : New ticket issue event
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211104@Liam.Pham: fix duplicate messages - [Redmine: #162851]
	20211130@Mira: Add ticket status column - [Redmine: #165017]
	20211130@Tyler: Get pinned prop - [Redmine: #165017]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tblTicketRecipient TABLE(TicketId INT);
        DECLARE @allTicketTypeId INT= 0;
        DECLARE @allMarketKey INT= 1;
        DECLARE @tblTicketStatus TABLE(TicketStatus VARCHAR(10));
        INSERT INTO @tblTicketStatus
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@TicketStatuses, ',') u OPTION(MAXRECURSION 0);
        INSERT INTO @tblTicketRecipient
        EXEC [dbo].[OWP_TicketCenter_GetTicketIdByRecipientId] 
             @ActorId = @ActorId;
        SELECT DISTINCT 
               tbltk.TicketId, 
               tl.[Subject], 
               tis.TicketType, 
               tis.TicketStatus, 
               ty.TypeName, 
               tm.UserId, 
               tm.Id AS MessageId, 
               tm.FileId,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS Username, 
               tm.CreatedDate, 
               tm.[Message], 
               reader.IsRead, 
               reader.IsPinned
        FROM TicketIssue AS tis WITH(NOLOCK)
             INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId = tis.TicketId
             INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId
             INNER JOIN TicketIssueOther AS tl WITH(NOLOCK) ON tis.TicketId = tl.TicketId
             INNER JOIN TicketMessage AS tm WITH(NOLOCK) ON tis.TicketId = tm.TicketId
             INNER JOIN [User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
             LEFT JOIN TicketMessageReader AS reader WITH(NOLOCK) ON tbltk.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        WHERE(@Keyword IS NULL
              OR @Keyword = ''
              OR tl.[Subject] LIKE '%' + @Keyword + '%')
             AND (@TicketId IS NULL
                  OR @TicketId = ''
                  OR CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId + '%')
             AND (@TicketTypeId = @allTicketTypeId
                  OR tis.TicketType = @TicketTypeId)
             AND @MarketKey = @allMarketKey
             AND tis.TicketStatus IN
        (
            SELECT TicketStatus
            FROM @tblTicketStatus
        );
    END;