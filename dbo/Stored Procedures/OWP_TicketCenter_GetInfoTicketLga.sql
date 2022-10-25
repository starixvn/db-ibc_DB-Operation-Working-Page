
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetInfoTicketLga] @TicketId INT
AS

/*  
Created: 20221013@Johnny
Task :Ticket Center
DB: bodb_OWP  
  
Revisions:  
 20221013@Johnny: Init sp  - [Redmine: #178183]  
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT tl.OwpMatchId
        FROM [dbo].[TicketIssueLiveIncident] AS tl WITH(NOLOCK)
		WHERE tl.TicketId = @TicketId
    END;