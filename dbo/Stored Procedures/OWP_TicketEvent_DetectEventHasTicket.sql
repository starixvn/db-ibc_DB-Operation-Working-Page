
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketEvent_DetectEventHasTicket] @OWPMatchIds VARCHAR(MAX), 
                                                                   @ActorId      INT
AS

/*      
 Created: 20220216@Carlos.nguyen
 Task : Detect event has ticket
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
       DECLARE @HasTicket BIT = 1;

        SELECT DISTINCT 
               x.OWPMatchId,
               reader.IsRead,
			   @HasTicket AS HasTicket
        FROM
        (
            SELECT te.TicketId, 
                   MAX(tm.Id) MaxId,
				   owpm.OWPMatchId
            FROM @OWPMatchId AS owpm
				INNER JOIN  dbo.TicketIssueLiveIncident AS te WITH(NOLOCK) ON owpm.OWPMatchId=te.OwpMatchId
                INNER JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON te.TicketId = tm.TicketId
            GROUP BY te.TicketId, owpm.OWPMatchId
        ) AS x
        LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
        LEFT JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        WHERE tm.Id = x.MaxId;
    END;