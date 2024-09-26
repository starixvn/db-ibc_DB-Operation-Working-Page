
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

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
	20231016@Mira: tuning SP - [Redmine: #195524]
	20240119@Mira: Correct SP - [Redmine: #123456]
	20240131@Mira: Refactor get recipient - [Redmine: #123456]
*/

    BEGIN
        SET NOCOUNT ON;
        -- define constants
        DECLARE @allMarketKey INT= 1;
        DECLARE @earlyMarketKey INT= 2;
        DECLARE @todayMarketKey INT= 3;
        DECLARE @earlyFilter INT= 2;

        -- declare date variable
        SET @fromDateFilter = DATEADD(DAY, DATEDIFF(DAY, 0, @fromDateFilter), '00:00:00');
        SET @toDateFilter = DATEADD(DAY, DATEDIFF(DAY, 0, @toDateFilter), '23:59:59');
        DECLARE @fromMarketDate DATETIME, @toMarketDate DATETIME;

        -- temp table
        CREATE TABLE #tblTicketRecipient
        (TicketId INT
        );
        DECLARE @tblTicketStatus TABLE(TicketStatus VARCHAR(10));
        CREATE TABLE #tblTicketLogWork
        (TicketId    INT, 
         AdminsiteId INT
        );
        CREATE TABLE #tblTicketLogWorkEvent
        (TicketId      INT, 
         LeagueId      INT, 
         HomeId        INT, 
         AwayId        INT, 
         EventDateTime DATETIME
        );
        DECLARE @tblTicketType TABLE
        (TypeId    INT, 
         SubTypeId INT
        );

        /********* PARSE PARAM XML *********/

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
        IF @MarketKey = @earlyMarketKey
            BEGIN
                SET @fromMarketDate = DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE()), '12:00:00');
                SET @toMarketDate = NULL;
        END;
        IF @MarketKey = @todayMarketKey
            BEGIN
                SET @fromMarketDate = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00');
                SET @toMarketDate = DATEADD(DAY, DATEDIFF(DAY, -1, @fromMarketDate), '11:59:59');
        END;

        -- get TicketId related to actorId 
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

        -- Filter ticket by important condition
        INSERT INTO #tblTicketLogWork
        (TicketId, 
         AdminsiteId
        )
               SELECT til.TicketId, 
                      til.AdminsiteId_New
               FROM TicketIssue AS til WITH(NOLOCK)
                    INNER JOIN #tblTicketRecipient AS tbltk ON tbltk.TicketId = til.TicketId
                    INNER JOIN @tblTicketType AS temp ON til.TicketType = temp.TypeId
               WHERE til.EventType_New = @EventType
                     AND til.LastCommentDate BETWEEN @fromDateFilter AND @toDateFilter
                     AND til.TicketStatus IN
               (
                   SELECT TicketStatus
                   FROM @tblTicketStatus
               )
                     AND (@TicketId IS NULL
                          OR @TicketId = ''
                          OR CONVERT(VARCHAR(255), til.TicketId) LIKE @TicketId + '%')
                     AND (til.SubtypeId = temp.SubTypeId
                          OR (til.SubtypeId IS NULL
                              AND temp.SubTypeId IS NULL));

        -- collect eventId info from match/match14
        INSERT INTO #tblTicketLogWorkEvent
        (TicketId, 
         LeagueId, 
         HomeId, 
         AwayId, 
         EventDateTime
        )
               SELECT t.TicketId, 
                      COALESCE(m.leagueid, m14.leagueid) AS LeagueId, 
                      COALESCE(m.homeid, m14.homeid) AS HomeId, 
                      COALESCE(m.awayid, m14.awayid) AS AwayId,
                      CASE
                          WHEN m.globalshowtime IS NOT NULL
                          THEN DATEADD(HOUR, 12, m.globalshowtime)
                          WHEN m14.globalshowtime IS NOT NULL
                          THEN DATEADD(HOUR, 12, m14.globalshowtime)
                          ELSE NULL
                      END
               FROM #tblTicketLogWork t WITH(NOLOCK)
                    LEFT JOIN [bodb02].[dbo].[match] m WITH(NOLOCK) ON t.AdminsiteId = m.matchid
                    LEFT JOIN [bodb02].[dbo].[match14] m14 WITH(NOLOCK) ON t.AdminsiteId = m14.matchid;

        -- select and filter by keyword and Market key
        SELECT DISTINCT 
               tis.TicketId, 
               COALESCE(NULLIF(tis.[Subject_New], ''), CONVERT(NVARCHAR(100), tis.AdminsiteId_New)) AS [Subject], 
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
        FROM TicketIssue tis WITH(NOLOCK)
             INNER JOIN TicketType ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId
             INNER JOIN #tblTicketLogWorkEvent til ON tis.TicketId = til.TicketId
             LEFT JOIN [bodb02].[dbo].[league] l WITH(NOLOCK) ON til.LeagueId = l.leagueid
             LEFT JOIN [bodb02].[dbo].[Team] t WITH(NOLOCK) ON til.HomeId = t.teamid
             LEFT JOIN [bodb02].[dbo].[Team] ta WITH(NOLOCK) ON til.AwayId = ta.teamid
             LEFT JOIN [TicketSubtype] ts WITH(NOLOCK) ON tis.SubtypeId = ts.SubtypeId
             LEFT JOIN TicketMessageReader reader WITH(NOLOCK) ON tis.TicketId = reader.TicketId
                                                                  AND reader.RecipientId = @ActorId
        WHERE(@Keyword IS NULL
              OR @Keyword = ''
              OR l.leaguename LIKE '%' + @Keyword + '%'
              OR t.teamname LIKE '%' + @Keyword + '%'
              OR ta.teamname LIKE '%' + @Keyword + '%'
              OR tis.Subject_New LIKE '%' + @Keyword + '%')
             AND @MarketKey = @allMarketKey
             OR (@toMarketDate IS NULL
                 AND til.EventDateTime >= @fromMarketDate
                 OR til.EventDateTime BETWEEN @fromMarketDate AND @toMarketDate);

        --drop temp table
        DROP TABLE #tblTicketRecipient;
        DROP TABLE #tblTicketLogWork;
        DROP TABLE #tblTicketLogWorkEvent;
    END;