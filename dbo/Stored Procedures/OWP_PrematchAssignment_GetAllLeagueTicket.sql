
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PrematchAssignment_GetAllLeaguesTicket] @OWPLeagueIds VARCHAR(MAX), 
                                                                   @ActorId      INT
AS

/* 
 Created: 20211222@Mira
 Task : Integrate my ticket
 DB: bodb_OWP      
      
 Revisions:        
	20211222@Mira: Integrate my ticket - [Redmine: #163766]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @OWPLeagueId TABLE(OWPLeagueId INT);
        INSERT INTO @OWPLeagueId
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@OWPLeagueIds, ',') u OPTION(MAXRECURSION 0);

        -- select Latest comment ticket
        SELECT DISTINCT 
               x.OWPLeagueId, 
               x.TicketId,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS LatestUsername, 
               tm.CreatedDate AS LatestCreatedDate, 
               tm.[Message] AS LatestMessage, 
               reader.IsRead
        FROM
        (
            SELECT ol.OWPLeagueId, 
                   tl.TicketId, 
                   MAX(tm.CreatedDate) MaxDateTime
            FROM @OWPLeagueId AS ol
                 INNER JOIN dbo.TicketIssueLeague AS tl WITH(NOLOCK) ON ol.OWPLeagueId = tl.OwpLeagueId
                 INNER JOIN dbo.TicketIssue ti WITH(NOLOCK) ON ti.TicketId = tl.TicketId
                 LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON ti.TicketId = tm.TicketId
            GROUP BY ol.OWPLeagueId, 
                     tl.TicketId
        ) AS x
        LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
        INNER JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        WHERE tm.CreatedDate = x.MaxDateTime;
    END;