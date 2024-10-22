
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_RecipientGroup_GetRecipientGroup]
AS

/*    
Created: 20210914@Mira  
Task : Ticket Setting  
DB: bodb_OWP  
    
Revisions:    
  20210914@Mira: Initial SP - [Redmine: #160545]  
*/

    BEGIN
        SET NOCOUNT ON;

        -- Get RecipientGoup Data  
        SELECT rg.RecipientGroupId, 
               rg.GroupId, 
               t.GroupName, 
               rg.RecipientId 'UserId', 
               u.Username
        FROM dbo.RecipientGroup rg WITH(NOLOCK)
             INNER JOIN dbo.TicketGroup t WITH(NOLOCK) ON t.GroupId = rg.GroupId
             LEFT JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = rg.RecipientId;
    END;