
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketIssueLiveIncident_Create] @TicketId   INT, 
                                                            @OwpMatchId INT = NULL
AS

/*      
 Created: 202210104@Johnny.Thai
 Task : New ticket issue lga
 DB: bodb_OWP      
      
 Revisions:          
	202210104@Johnny.Thai: Event ticket - [Redmine: #178183]
*/

    BEGIN
        SET NOCOUNT ON;
        INSERT INTO TicketIssueLiveIncident
        (TicketId, 
         OwpMatchId
        )
        VALUES
        (@TicketId, 
         @OwpMatchId
        );
    END;