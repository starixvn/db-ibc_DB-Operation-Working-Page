
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PrematchAssignment_GetAllMatchesTicket] @InfoSiteMatchIds VARCHAR(MAX), 
                                                                   @ActorId          INT
AS

/* 
 Created: 20211222@Mira
 Task : Integrate my ticket
 DB: bodb_OWP      
      
 Revisions:        
	20211222@Mira: Integrate my ticket - [Redmine: #163766]
	20220321@Mira: Get subtype - [Redmine: #170097]
	20230807@Los: Get ticket event - [Redmine: #191778]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @InfoSiteMatchId TABLE(InfoSiteMatchId INT);
        INSERT INTO @InfoSiteMatchId
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@InfoSiteMatchIds, ',') u OPTION(MAXRECURSION 0);

        -- select Latest comment ticket
        SELECT DISTINCT 
               x.InfoSiteMatchId, 
               x.TicketId,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS LatestUsername, 
               tm.CreatedDate AS LatestCreatedDate, 
               tm.[Message] AS LatestMessage, 
               reader.IsRead, 
               ts.SubtypeId, 
               ts.SubtypeName
        FROM
        (
            SELECT im.InfoSiteMatchId, 
                   ti.TicketId, 
                   MAX(tm.CreatedDate) MaxDateTime, 
                   ti.SubtypeId
            FROM @InfoSiteMatchId AS im
                 INNER JOIN dbo.TicketIssue ti WITH(NOLOCK) ON ti.EventType_New = 2 AND im.InfoSiteMatchId = ti.InfoSiteMatchId_New
                 LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON ti.TicketId = tm.TicketId
            GROUP BY im.InfoSiteMatchId, 
                     ti.TicketId, 
                     ti.SubtypeId
        ) AS x
        LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
        INNER JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        LEFT JOIN dbo.TicketSubtype AS ts WITH(NOLOCK) ON ts.SubtypeId = x.SubtypeId
        WHERE tm.CreatedDate = x.MaxDateTime;
    END;