
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenterLeague_Get] @ActorId        INT, 
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
 Task : New ticket issue league
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
	20230807@Los: Get ticket league - [Redmine: #191778]
*/

    BEGIN
        SET NOCOUNT ON;
        SET @FromDateFilter = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDateFilter), '00:00:00');
        SET @ToDateFilter = DATEADD(DAY, DATEDIFF(DAY, 0, @ToDateFilter), '23:59:59');
        DECLARE @tblTicketRecipient TABLE(TicketId INT);
        DECLARE @allMarketKey INT= 1;
        DECLARE @tblTicketStatus TABLE(TicketStatus VARCHAR(10));
        DECLARE @tblTicketType TABLE
        (TypeId    INT, 
         SubTypeId INT
        );
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
        INSERT INTO @tblTicketStatus
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@TicketStatuses, ',') u OPTION(MAXRECURSION 0);
        INSERT INTO @tblTicketRecipient
        EXEC [dbo].[OWP_TicketCenter_GetTicketIdByRecipientId] 
             @ActorId = @ActorId;
        SELECT DISTINCT 
               tbltk.TicketId, 
               owpl.OWPLeagueId, 
               owpl.OWPLeagueName, 
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
             INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId = tis.TicketId
             INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId           
             INNER JOIN OWPLeague AS owpl WITH(NOLOCK) ON owpl.OWPLeagueId = tis.OwpLeagueId_New
             INNER JOIN @tblTicketType AS temp ON tis.TicketType = temp.TypeId
             LEFT JOIN [TicketSubtype] AS ts ON tis.SubtypeId = ts.SubtypeId
             LEFT JOIN TicketMessageReader AS reader WITH(NOLOCK) ON tbltk.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        WHERE(@Keyword IS NULL
              OR @Keyword = ''
              OR owpl.OWPLeagueName LIKE '%' + @Keyword + '%')
             AND (@TicketId IS NULL
                  OR @TicketId = ''
                  OR CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId + '%')
			AND tis.EventType_New=@EventType
             AND @MarketKey = @allMarketKey
             AND (tis.SubtypeId = temp.SubTypeId
                  OR (tis.SubtypeId IS NULL
                      AND temp.SubTypeId IS NULL))
             AND tis.TicketStatus IN
        (
            SELECT TicketStatus
            FROM @tblTicketStatus
        )
             AND tis.LastCommentDate BETWEEN @FromDateFilter AND @ToDateFilter;
    END;