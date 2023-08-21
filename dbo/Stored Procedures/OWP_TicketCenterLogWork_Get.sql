
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenterLogWork_Get] @ActorId        INT, 
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
 Created: 20230602@Johnny
 Task : Get ticket Log Work
 DB: bodb_OWP      
      
 Revisions:          
	20230602@Johnny: Get Ticket Log Work - [Redmine: #185890]
	20230703@Johnny: Get Ticket Log Work from bodb02 - [Redmine: #190284]
	20230713@Johnny: Search subject  - [Redmine: #190284]
	20230807@Los: Get ticket logwork - [Redmine: #191778]
*/

    BEGIN
        SET NOCOUNT ON;
        SET @FromDateFilter = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDateFilter), '00:00:00');
        SET @ToDateFilter = DATEADD(DAY, DATEDIFF(DAY, 0, @ToDateFilter), '23:59:59');
        DECLARE @tblTicketRecipient TABLE(TicketId INT);
        DECLARE @allMarketKey INT= 1;
        DECLARE @earlyMarketKey INT= 2;
        DECLARE @todayMarketKey INT= 3;
        DECLARE @earlyFilter INT= 2;
        DECLARE @fromDate DATETIME;
        DECLARE @toDate DATETIME;
        DECLARE @tblTicketStatus TABLE(TicketStatus VARCHAR(10));
        DECLARE @tblTicketLogWorkEvent TABLE
        (TicketId      INT, 
         AdminSiteId   INT, 
         LeagueId      INT, 
         HomeId        INT, 
         AwayId        INT, 
         EventDateTime DATETIME, 
         [Subject]     NVARCHAR(2000)
        );
        INSERT INTO @tblTicketLogWorkEvent
        (TicketId, 
         AdminSiteId, 
         LeagueId, 
         HomeId, 
         AwayId, 
         EventDateTime, 
         [Subject]
        )
               SELECT til.TicketId, 
                      til.AdminsiteId_New AS AdminsiteId, 
                      COALESCE(m.leagueid, m14.leagueid) AS LeagueId, 
                      COALESCE(m.homeid, m14.homeid) AS HomeId, 
                      COALESCE(m.awayid, m14.awayid) AS AwayId,
                      CASE
                          WHEN m.globalshowtime IS NOT NULL
                          THEN DATEADD(HOUR, 12, m.globalshowtime)
                          WHEN m14.globalshowtime IS NOT NULL
                          THEN DATEADD(HOUR, 12, m14.globalshowtime)
                          ELSE NULL
                      END AS EventDateTime, 
                      til.[Subject_New] AS [Subject]
               FROM TicketIssue AS til WITH(NOLOCK)
                    LEFT JOIN [bodb02].[dbo].[match] AS m WITH(NOLOCK) ON til.AdminsiteId_New = m.matchid
                    LEFT JOIN [bodb02].[dbo].[match14] AS m14 WITH(NOLOCK) ON til.AdminsiteId_New = m14.matchid
			WHERE til.EventType_New=@EventType
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
               CASE
                   WHEN til.[Subject] IS NULL
                        OR til.[Subject] = ''
                   THEN CONVERT(NVARCHAR(100), til.AdminsiteId)
                   ELSE til.[Subject]
               END AS [Subject], 
               l.leaguename AS LeagueName, 
               t.teamname AS HomeName, 
               ta.teamname AS AwayName, 
               tis.TicketType, 
               tis.TicketStatus, 
               tis.LastCommentDate, 
               ty.TypeName, 
               til.EventDateTime AS KOTime, 
               reader.IsRead, 
               reader.IsPinned, 
               ts.SubtypeName 'TicketSubTypeName', 
               ts.SubtypeId 'TicketSubTypeId',
			   tis.EventType_New AS EventType
        FROM TicketIssue AS tis WITH(NOLOCK)
             INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId = tis.TicketId
             INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId
             INNER JOIN @tblTicketLogWorkEvent AS til ON tis.TicketId = til.TicketId
             INNER JOIN @tblTicketType AS temp ON tis.TicketType = temp.TypeId
             LEFT JOIN [bodb02].[dbo].[league] AS l ON til.LeagueId = l.leagueid
             LEFT JOIN [bodb02].[dbo].[Team] AS t ON til.HomeId = t.teamid
             LEFT JOIN [bodb02].[dbo].[Team] AS ta ON til.AwayId = ta.teamid
             LEFT JOIN [TicketSubtype] AS ts ON tis.SubtypeId = ts.SubtypeId
             LEFT JOIN TicketMessageReader AS reader WITH(NOLOCK) ON tbltk.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        WHERE(@Keyword IS NULL
              OR @Keyword = ''
              OR l.leaguename LIKE '%' + @Keyword + '%'
              OR t.teamname LIKE '%' + @Keyword + '%'
              OR ta.teamname LIKE '%' + @Keyword + '%'
              OR til.[Subject] LIKE '%' + @Keyword + '%')
             AND (@TicketId IS NULL
                  OR @TicketId = ''
                  OR CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId + '%')
             AND (@MarketKey = @allMarketKey
                  OR (@MarketKey = @earlyMarketKey
                      AND til.EventDateTime >= @fromDate)
                  OR (@MarketKey = @todayMarketKey
                      AND til.EventDateTime BETWEEN @fromDate AND @toDate))
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