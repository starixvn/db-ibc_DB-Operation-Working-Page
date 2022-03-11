USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_TicketCenterEvent_Get]    Script Date: 3/2/2022 9:41:25 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenterEvent_Get] @ActorId        INT, 
                                                  @Keyword        NVARCHAR(255) = NULL, 
                                                  @TicketId       NVARCHAR(255) = NULL, 
                                                  @TicketStatuses VARCHAR(100), 
                                                  @TicketTypeXML  NVARCHAR(MAX), 
                                                  @MarketKey      INT           = 1
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : New ticket issue event
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211015@Liam.Pham: Event ticket - [Redmine: #158037]
	20211104@Liam.Pham: fix duplicate messages - [Redmine: #162851]
	20211130@Mira: Add ticket status column - [Redmine: #165017]
	20211130@Tyler: Get pinned prop - [Redmine: #165017]
	20220302@Liam: Get ticket by subtype - [Redmine: #168624]
	20220311@Johnny.Thai: Hide Ticket - [Redmine: #169841]
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
               owpl.OWPLeagueId, 
               owpl.OWPLeagueName, 
               tl.OwpHomeId, 
               tl.OwpAwayId, 
               ifm.HomeName, 
               ifm.AwayName, 
               tis.TicketType, 
               tis.TicketStatus, 
               ty.TypeName, 
               tis.SubtypeId AS TicketSubTypeId, 
               tst.SubtypeName AS TicketSubTypeName, 
               tm.UserId, 
               tm.CreatedDate, 
               tm.[Message], 
               ifm.EventDateTime AS KOTime, 
               tm.FileId, 
               tm.Id AS MessageId,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS Username, 
               reader.IsRead, 
               reader.IsPinned, 
               ts.SubtypeName 'TicketSubTypeName', 
               ts.SubtypeId 'TicketSubTypeId'
        FROM TicketIssue AS tis WITH(NOLOCK)
             INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId = tis.TicketId
             INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId
             LEFT JOIN TicketSubtype AS tst WITH(NOLOCK) ON tis.TicketId = tst.TypeId
                                                            AND tis.SubtypeId = tst.SubtypeId
             INNER JOIN TicketIssueEvent AS tl WITH(NOLOCK) ON tis.TicketId = tl.TicketId
             INNER JOIN InfoSiteMatch AS ifm ON ifm.InfoSiteMatchId = tl.InfoSiteMatchId
             INNER JOIN TicketMessage AS tm WITH(NOLOCK) ON tis.TicketId = tm.TicketId
             INNER JOIN OWPLeague AS owpl WITH(NOLOCK) ON owpl.OWPLeagueId = tl.OwpLeagueId
             INNER JOIN [User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
             INNER JOIN @tblTicketType AS temp ON tis.TicketType = temp.TypeId
             LEFT JOIN [TicketSubtype] AS ts ON tis.SubtypeId = ts.SubtypeId
             LEFT JOIN TicketMessageReader AS reader WITH(NOLOCK) ON tbltk.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        WHERE(@Keyword IS NULL
              OR @Keyword = ''
              OR owpl.OWPLeagueName LIKE '%' + @Keyword + '%'
              OR ifm.HomeName LIKE '%' + @Keyword + '%'
              OR ifm.AwayName LIKE '%' + @Keyword + '%')
             AND (@TicketId IS NULL
                  OR @TicketId = ''
                  OR CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId + '%')
             AND (@MarketKey = @allMarketKey
                  OR (@MarketKey = @earlyMarketKey
                      AND ifm.EventDateTime >= @fromDate)
                  OR (@MarketKey = @todayMarketKey
                      AND ifm.EventDateTime BETWEEN @fromDate AND @toDate))
             AND (tis.SubtypeId = temp.SubTypeId
                  OR (tis.SubtypeId IS NULL
                      AND temp.SubTypeId IS NULL))
             AND (tis.TicketStatus = 'Closed'
                  AND DATEDIFF(DAY, tis.LastCommentDate, DATEADD(HOUR, 12, GETDATE())) < 90)
             OR (tis.TicketStatus <> 'Closed')
             AND tis.TicketStatus IN
        (
            SELECT TicketStatus
            FROM @tblTicketStatus
        );
    END;