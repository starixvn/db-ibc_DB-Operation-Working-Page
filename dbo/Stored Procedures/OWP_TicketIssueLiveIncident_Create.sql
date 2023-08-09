
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketIssueLiveIncident_Create] @TicketId   INT, 
                                                            @OwpMatchId INT = NULL
AS

/*      
 Created: 202210104@Johnny.Thai
 Task : New ticket issue lga
 DB: bodb_OWP      
      
 Revisions:          
	202210104@Johnny.Thai: Event ticket - [Redmine: #178183]
	20230807@Los: Get ticket event - [Redmine: #191778]
*/

    BEGIN
        SET NOCOUNT ON;
        INSERT INTO TicketIssue
        (TicketId, 
         OwpMatchId
        )
        VALUES
        (@TicketId, 
         @OwpMatchId
        );
    END;