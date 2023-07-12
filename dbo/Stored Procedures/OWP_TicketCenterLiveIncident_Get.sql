
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenterLiveIncident_Get] @ActorId        INT, 
                                                         @Keyword        NVARCHAR(255) = NULL, 
                                                         @TicketId       NVARCHAR(255) = NULL, 
                                                         @TicketStatuses VARCHAR(100), 
                                                         @TicketTypeXML  NVARCHAR(MAX), 
                                                         @MarketKey      INT           = 1, 
                                                         @FromDateFilter DATETIME, 
                                                         @ToDateFilter   DATETIME
AS

/*      
 Created: 20221005@Mira
 Task : Get ticket Live Incident detail
 DB: bodb_OWP      
      
 Revisions:          
	20221005@Mira: Get Ticket Live Incident - [Redmine: #178183]
	20220311@Liam: Performance tuning - [Redmine: #169841]
	20230703@Johnny: Get Ticket Log Work from bodb02 - [Redmine: #190284]
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
               ts.SubtypeId 'TicketSubTypeId'
        FROM TicketIssue AS tis WITH(NOLOCK)
             INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId = tis.TicketId
             INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId
             INNER JOIN TicketIssueLiveIncident AS tli WITH(NOLOCK) ON tis.TicketId = tli.TicketId
             INNER JOIN @tblTicketType AS temp ON tis.TicketType = temp.TypeId
             LEFT JOIN [TicketSubtype] AS ts ON tis.SubtypeId = ts.SubtypeId
             LEFT JOIN TicketMessageReader AS reader WITH(NOLOCK) ON tbltk.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
             LEFT JOIN OWPMatch AS owpm ON owpm.OWPMatchId = tli.OwpMatchId
             LEFT JOIN OWPLeague AS owpl ON owpl.OWPLeagueId = owpm.OWPLeagueId
             LEFT JOIN OWPTeam AS owph ON owph.OWPTeamId = owpm.OWPHomeId
             LEFT JOIN OWPTeam AS owpa ON owpa.OWPTeamId = owpm.OWPAwayId
        WHERE(@Keyword IS NULL
              OR @Keyword = ''
              OR owpl.OWPLeagueName LIKE '%' + @Keyword + '%'
              OR owph.OWPTeamName LIKE '%' + @Keyword + '%'
              OR owpa.OWPTeamName LIKE '%' + @Keyword + '%')
             AND (@TicketId IS NULL
                  OR @TicketId = ''
                  OR CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId + '%')
             AND (@MarketKey = @allMarketKey
                  OR (@MarketKey = @earlyMarketKey
                      AND owpm.EventDateTime >= @fromDate)
                  OR (@MarketKey = @todayMarketKey
                      AND owpm.EventDateTime BETWEEN @fromDate AND @toDate))
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