
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenterOther_Get] @ActorId        INT, 
                                                  @Keyword        NVARCHAR(255) = NULL, 
                                                  @TicketId       NVARCHAR(255) = NULL, 
                                                  @TicketStatuses VARCHAR(100), 
                                                  @TicketTypeXML  NVARCHAR(MAX), 
                                                  @MarketKey      INT           = 1, 
                                                  @FromDateFilter DATETIME, 
                                                  @ToDateFilter   DATETIME, 
                                                  @EventType      INT
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
	20220302@Liam: Get ticket by subtype - [Redmine: #168624]
	20220311@Johnny.Thai: Hide Ticket - [Redmine: #169841]
	20220311@Liam: Performance tuning - [Redmine: #169841]
	20220613@Johnny.Thai: Hide ticket without any comment in 30 days  - [Redmine: #173994]
	20230517@Liam: Performance tuning - [Redmine: #169841]
	20230703@Johnny: Get Ticket Log Work from bodb02 - [Redmine: #190284]
	20230807@Los: Get ticket support - [Redmine: #191778]
	20231016@Johnny: tuning SP - [Redmine: #195524]
	20240119@Mira: Correct SP - [Redmine: #123456]
	20240131@Mira: Refactor get recipient - [Redmine: #123456]
*/

    BEGIN
        SET NOCOUNT ON;
        SET @FromDateFilter = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDateFilter), '00:00:00');
        SET @ToDateFilter = DATEADD(DAY, DATEDIFF(DAY, 0, @ToDateFilter), '23:59:59');
        DECLARE @allMarketKey INT= 1;
        CREATE TABLE #tblTicketRecipient(TicketId INT);
        DECLARE @tblTicketStatus TABLE(TicketStatus VARCHAR(10));
        DECLARE @tblTicketType TABLE
        (TypeId    INT, 
         SubTypeId INT
        );

        -- ticket type
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @TicketTypeXML;
        INSERT INTO @tblTicketType
        (TypeId, 
         SubTypeId
        )
               SELECT [TypeId], 
                      NULLIF([SubTypeId], '')
               FROM OPENXML(@idoc, '/Root/TicketType', 1) WITH([TypeId] INT, [SubTypeId] INT);
        EXEC sp_xml_removedocument 
             @idoc;

        -- match status
        INSERT INTO @tblTicketStatus
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@TicketStatuses, ',') u OPTION(MAXRECURSION 0);
        -- parse date time
        INSERT INTO #tblTicketRecipient
               SELECT tr.TicketId
               FROM TicketRecipient AS tr WITH(NOLOCK)
               WHERE tr.RecipientType = 1
                     AND tr.RecipientId = @ActorId
               UNION
               SELECT tr.TicketId
               FROM TicketRecipient AS tr WITH(NOLOCK)
                    INNER JOIN RecipientGroup AS rg WITH(NOLOCK) ON tr.RecipientId = rg.GroupId
               WHERE tr.RecipientType = 2
                     AND rg.RecipientId = @ActorId
               UNION
               SELECT tr.TicketId
               FROM TicketRecipient AS tr WITH(NOLOCK)
                    INNER JOIN [User] AS u WITH(NOLOCK) ON tr.RecipientId = u.SectionId
               WHERE tr.RecipientType = 3
                     AND u.UserId = @ActorId;

        -- select by param
        SELECT DISTINCT 
               tbltk.TicketId, 
               tis.[Subject_New] AS [Subject], 
               tis.TicketType, 
               tis.TicketStatus, 
               tis.LastCommentDate, 
               ty.TypeName, 
               reader.IsRead, 
               reader.IsPinned, 
               ts.SubtypeName 'TicketSubTypeName', 
               ts.SubtypeId 'TicketSubTypeId', 
               tis.EventType_New AS EventType
        FROM TicketIssue AS tis WITH(NOLOCK)
             INNER JOIN #tblTicketRecipient AS tbltk ON tbltk.TicketId = tis.TicketId
             INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId
             INNER JOIN @tblTicketType AS temp ON tis.TicketType = temp.TypeId
             LEFT JOIN [TicketSubtype] AS ts WITH(NOLOCK) ON tis.SubtypeId = ts.SubtypeId
             LEFT JOIN TicketMessageReader AS reader WITH(NOLOCK) ON tbltk.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        WHERE tis.LastCommentDate BETWEEN @FromDateFilter AND @ToDateFilter
              AND (@Keyword IS NULL
                   OR @Keyword = ''
                   OR tis.[Subject_New] LIKE '%' + @Keyword + '%')
              AND tis.EventType_New = @EventType
              AND (@TicketId IS NULL
                   OR @TicketId = ''
                   OR CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId + '%')
              AND @MarketKey = @allMarketKey
              AND (tis.SubtypeId = temp.SubTypeId
                   OR (tis.SubtypeId IS NULL
                       AND temp.SubTypeId IS NULL))
              AND tis.TicketStatus IN
        (
            SELECT TicketStatus
            FROM @tblTicketStatus
        );

        -- drop table
        DROP TABLE #tblTicketRecipient;
    END;