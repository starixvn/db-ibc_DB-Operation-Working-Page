
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetInfoTicketLga] @TicketId INT
AS

/*  
Created: 20221013@Johnny
Task :Ticket Center
DB: bodb_OWP  
  
Revisions:  
 20221013@Johnny: Init sp  - [Redmine: #178183]
 20230807@Los: Get ticket event - [Redmine: #191778]
 20240222@Los : Get parent match Id - [Redmine: #200265]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT CASE
                   WHEN mm.MinorMatchId IS NULL
                   THEN tl.OwpMatchId_New
                   ELSE mm.ParentMatchId
               END 'ParentMatchId'
        FROM [dbo].[TicketIssue] AS tl WITH(NOLOCK)
             LEFT JOIN MinorMatch AS mm WITH(NOLOCK) ON mm.MinorMatchId = tl.OwpMatchId_New
        WHERE tl.TicketId = @TicketId;
    END;