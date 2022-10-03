
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketEvent_GetTicketByOwpMatchId] @OWPMatchId INT,
																@ActorId INT
AS

/*      
 Created: 20220216@Carlos.nguyen
 Task : Get ticket
 DB: bodb_OWP      
      
 Revisions:          
	20220929@Carlos.nguyen: Init sp - [Redmine: #178183]
*/

    BEGIN
        SET NOCOUNT ON;

		-- select Latest comment ticket
        SELECT DISTINCT 
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
            SELECT te.TicketId, 
                   MAX(tm.CreatedDate) MaxDateTime, 
                   ti.SubtypeId
            FROM dbo.TicketIssueLiveIncident AS te WITH(NOLOCK)
                 INNER JOIN dbo.TicketIssue ti WITH(NOLOCK) ON ti.TicketId = te.TicketId
                 LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON ti.TicketId = tm.TicketId
            GROUP BY te.TicketId, 
                     ti.SubtypeId
        ) AS x
        LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
        INNER JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        LEFT JOIN dbo.TicketSubtype AS ts WITH(NOLOCK) ON ts.SubtypeId = x.SubtypeId
        WHERE tm.CreatedDate = x.MaxDateTime;

        SELECT ti.TicketId,
		u.Username, 
        u.Nickname,
		tm.CreatedDate,
		tm.[Message],
		ts.SubtypeName
		FROM TicketIssue AS ti WITH (NOLOCK)
		INNER JOIN TicketIssueLiveIncident AS til WITH (NOLOCK) ON ti.TicketId = til.TicketId AND til.OwpMatchId=@OWPMatchId
		LEFT JOIN TicketSubtype AS ts WITH (NOLOCK) ON ti.SubtypeId=ts.SubtypeId
		INNER JOIN TicketMessage AS tm WITH (NOLOCK) ON tm.TicketId=ti.TicketId 
		INNER JOIN [User] AS u WITH (NOLOCK) ON u.UserId=tm.UserId

    END;