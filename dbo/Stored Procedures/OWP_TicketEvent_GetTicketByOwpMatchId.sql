
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketEvent_GetTicketByOwpMatchId] @OWPMatchIds VARCHAR(MAX),
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
		DECLARE @OWPMatchId TABLE(OWPMatchId INT);

        INSERT INTO @OWPMatchId
        SELECT DISTINCT 
                      val
        FROM fnc_SplitStrings(@OWPMatchIds, ',') u OPTION(MAXRECURSION 0);

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
               ts.SubtypeName,
			   x.OWPMatchId
        FROM
        (
            SELECT te.TicketId, 
                   MAX(tm.Id) MaxId, 
                   ti.SubtypeId,
				   owpm.OWPMatchId
            FROM dbo.TicketIssueLiveIncident AS te WITH(NOLOCK)
				INNER JOIN @OWPMatchId AS owpm ON owpm.OWPMatchId=te.OwpMatchId
                 INNER JOIN dbo.TicketIssue ti WITH(NOLOCK) ON ti.TicketId = te.TicketId
                 LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON ti.TicketId = tm.TicketId
            GROUP BY te.TicketId, 
                     ti.SubtypeId,
					 owpm.OWPMatchId
        ) AS x
        LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
        INNER JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        LEFT JOIN dbo.TicketSubtype AS ts WITH(NOLOCK) ON ts.SubtypeId = x.SubtypeId
        WHERE tm.Id = x.MaxId;

    END;