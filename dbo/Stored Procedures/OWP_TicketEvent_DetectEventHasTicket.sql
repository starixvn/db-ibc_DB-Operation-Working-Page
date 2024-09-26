
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketEvent_DetectEventHasTicket] @OWPMatchIds VARCHAR(MAX), 
                                                             @ActorId     INT
AS

/*      
 Created: 20220216@Carlos.nguyen
 Task : Detect event has ticket
 DB: bodb_OWP      
      
 Revisions:          
	20220929@Carlos.nguyen: Init sp - [Redmine: #178183]
	20240222@Los : Get parent match Id - [Redmine: #200265]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @OWPMatchId TABLE(OWPMatchId INT);
       
        INSERT INTO @OWPMatchId
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@OWPMatchIds, ',') u OPTION(MAXRECURSION 0);

        -- select Latest comment ticket
        DECLARE @HasTicket BIT= 1;
        SELECT DISTINCT 
                      CASE WHEN mm.MinorMatchId IS NULL
						THEN x.OWPMatchId
						ELSE mm.ParentMatchId
						END 'ParentMatchId', 
                      reader.IsRead, 
                      @HasTicket AS HasTicket
               FROM
               (
                   SELECT te.TicketId, 
                          MAX(tm.Id) MaxId, 
                          owpm.OWPMatchId
                   FROM @OWPMatchId AS owpm
                        INNER JOIN dbo.TicketIssue AS te WITH(NOLOCK) ON owpm.OWPMatchId = te.OwpMatchId_New
                        INNER JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON te.TicketId = tm.TicketId
                   WHERE te.EventType_New = 5
                   GROUP BY te.TicketId, 
                            owpm.OWPMatchId
               ) AS x
               LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
               INNER JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                            AND reader.RecipientId = @ActorId
				LEFT JOIN MinorMatch AS mm WITH(NOLOCK) ON mm.MinorMatchId = x.OWPMatchId
               WHERE tm.Id = x.MaxId;
    END;