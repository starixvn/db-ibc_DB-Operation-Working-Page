
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
               reader.IsRead
        FROM
        (
            SELECT im.InfoSiteMatchId, 
                   te.TicketId, 
                   MAX(tm.CreatedDate) MaxDateTime
            FROM @InfoSiteMatchId AS im
                 INNER JOIN dbo.TicketIssueEvent AS te WITH(NOLOCK) ON im.InfoSiteMatchId = te.InfoSiteMatchId
                 INNER JOIN dbo.TicketIssue ti WITH(NOLOCK) ON ti.TicketId = te.TicketId
                 LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON ti.TicketId = tm.TicketId
            GROUP BY im.InfoSiteMatchId, 
                     te.TicketId
        ) AS x
        LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
        INNER JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        WHERE tm.CreatedDate = x.MaxDateTime;
    END;