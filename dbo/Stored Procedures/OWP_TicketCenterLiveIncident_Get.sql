
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenterLiveIncident_Get] @ActorId        INT, 
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
 Created: 20221005@Mira
 Task : Get ticket Live Incident detail
 DB: bodb_OWP      
      
 Revisions:          
	20221005@Mira: Get Ticket Live Incident - [Redmine: #178183]
	20220311@Liam: Performance tuning - [Redmine: #169841]
	20230703@Johnny: Get Ticket Log Work from bodb02 - [Redmine: #190284]
	20230807@Los: Get ticket live - [Redmine: #191778]
	20231016@Liam: Tuning performance - [Redmine: #195524]
	20240119@Mira: Correct SP - [Redmine: #123456]
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
        EXEC [dbo].[OWP_TicketCenter_GetTicketIdByRecipientId] 
             @ActorId = @ActorId;

        -- select by param
        SELECT DISTINCT 
               tbltk.TicketId, 
               owpm.OWPLeagueId, 
               owpl.OWPLeagueName, 
               owpm.OWPHomeId, 
               owph.OWPTeamName 'HomeName', 
               owpm.OWPAwayId, 
               owpa.OWPTeamName 'AwayName', 
               tis.TicketType, 
               tis.TicketStatus, 
               tis.LastCommentDate, 
               ty.TypeName, 
               owpm.EventDateTime AS KOTime, 
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
             LEFT JOIN OWPMatch AS owpm WITH(NOLOCK) ON owpm.OWPMatchId = tis.OwpMatchId_New
             LEFT JOIN OWPLeague AS owpl WITH(NOLOCK) ON owpl.OWPLeagueId = owpm.OWPLeagueId
             LEFT JOIN OWPTeam AS owph WITH(NOLOCK) ON owph.OWPTeamId = owpm.OWPHomeId
             LEFT JOIN OWPTeam AS owpa WITH(NOLOCK) ON owpa.OWPTeamId = owpm.OWPAwayId
        WHERE tis.LastCommentDate BETWEEN @FromDateFilter AND @ToDateFilter
              AND (@Keyword IS NULL
                   OR @Keyword = ''
                   OR owpl.OWPLeagueName LIKE '%' + @Keyword + '%'
                   OR owph.OWPTeamName LIKE '%' + @Keyword + '%'
                   OR owpa.OWPTeamName LIKE '%' + @Keyword + '%')
              AND tis.EventType_New = @EventType
              AND (@TicketId IS NULL
                   OR @TicketId = ''
                   OR CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId + '%')
              AND (@MarketKey = @allMarketKey
                   OR (@toMarketDate IS NULL
                       AND owpm.EventDateTime >= @fromMarketDate
                       OR owpm.EventDateTime BETWEEN @fromMarketDate AND @toMarketDate))
              AND (tis.SubtypeId = temp.SubTypeId
                   OR (tis.SubtypeId IS NULL
                       AND temp.SubTypeId IS NULL))
              AND tis.TicketStatus IN
        (
            SELECT TicketStatus
            FROM @tblTicketStatus
        );

        -- drop temp table
        DROP TABLE #tblTicketRecipient;
    END;