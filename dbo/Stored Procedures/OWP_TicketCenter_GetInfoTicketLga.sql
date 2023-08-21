
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetInfoTicketLga] @TicketId INT
AS

/*  
Created: 20221013@Johnny
Task :Ticket Center
DB: bodb_OWP  
  
Revisions:  
 20221013@Johnny: Init sp  - [Redmine: #178183]
 20230807@Los: Get ticket event - [Redmine: #191778]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT tl.OwpMatchId_New AS OwpMatchId
        FROM [dbo].[TicketIssue] AS tl WITH(NOLOCK)
		WHERE tl.TicketId = @TicketId
    END;