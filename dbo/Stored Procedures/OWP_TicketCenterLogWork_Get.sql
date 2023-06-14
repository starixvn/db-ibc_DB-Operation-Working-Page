/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketCenterLogWork_Get] @ActorId        INT, 
                                                    @Keyword        NVARCHAR(255) = NULL, 
                                                    @TicketId       NVARCHAR(255) = NULL, 
                                                    @TicketStatuses VARCHAR(100), 
                                                    @TicketTypeXML  NVARCHAR(MAX), 
                                                    @MarketKey      INT           = 1
AS

/*      
 Created: 20230602@Johnny
 Task : Get ticket Log Work
 DB: bodb_OWP      
      
 Revisions:          
	20230602@Johnny: Get Ticket Log Work - [Redmine: #185890]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tblTicketRecipient TABLE(TicketId INT);
        DECLARE @allMarketKey INT= 1;
        DECLARE @earlyMarketKey INT= 2;
        DECLARE @todayMarketKey INT= 3;
        DECLARE @earlyFilter INT= 2;
        DECLARE @fromDate DATETIME;
        DECLARE @toDate DATETIME;
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
        IF @MarketKey = @earlyMarketKey
            BEGIN
                SET @fromDate = DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE()), '12:00:00');
        END;
        IF @MarketKey = @todayMarketKey
            BEGIN
                SET @fromDate = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00');
                SET @toDate = DATEADD(DAY, DATEDIFF(DAY, -1, @fromDate), '11:59:59');
        END;
        INSERT INTO @tblTicketRecipient
        EXEC [dbo].[OWP_TicketCenter_GetTicketIdByRecipientId] 
             @ActorId = @ActorId;
        SELECT DISTINCT 
               tbltk.TicketId, 
			   til.[Subject],
               im.LeagueName, 
               im.HomeName, 
               im.AwayName, 
               tis.TicketType, 
               tis.TicketStatus, 
               tis.LastCommentDate, 
               ty.TypeName, 
               im.EventDateTime AS KOTime, 
               reader.IsRead, 
               reader.IsPinned, 
               ts.SubtypeName 'TicketSubTypeName', 
               ts.SubtypeId 'TicketSubTypeId'
        FROM TicketIssue AS tis WITH(NOLOCK)
             INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId = tis.TicketId
             INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId
             INNER JOIN TicketIssueLogWork AS til WITH(NOLOCK) ON tis.TicketId = til.TicketId
             INNER JOIN @tblTicketType AS temp ON tis.TicketType = temp.TypeId
			 LEFT JOIN InfoSiteMatch As im ON til.AdminsiteId = im.AdminSiteMatchId
             LEFT JOIN [TicketSubtype] AS ts ON tis.SubtypeId = ts.SubtypeId
             LEFT JOIN TicketMessageReader AS reader WITH(NOLOCK) ON tbltk.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        WHERE(@Keyword IS NULL
              OR @Keyword = ''
              OR im.LeagueName LIKE '%' + @Keyword + '%'
              OR im.AwayName LIKE '%' + @Keyword + '%'
              OR im.HomeName LIKE '%' + @Keyword + '%')
             AND (@TicketId IS NULL
                  OR @TicketId = ''
                  OR CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId + '%')
             AND (@MarketKey = @allMarketKey
                  OR (@MarketKey = @earlyMarketKey
                      AND im.EventDateTime >= @fromDate)
                  OR (@MarketKey = @todayMarketKey
                      AND im.EventDateTime BETWEEN @fromDate AND @toDate))
             AND (tis.SubtypeId = temp.SubTypeId
                  OR (tis.SubtypeId IS NULL
                      AND temp.SubTypeId IS NULL))
             AND tis.TicketStatus IN
        (
            SELECT TicketStatus
            FROM @tblTicketStatus
        )
             AND DATEDIFF(DAY, tis.LastCommentDate, DATEADD(HOUR, 12, GETDATE())) <= 30;
    END;