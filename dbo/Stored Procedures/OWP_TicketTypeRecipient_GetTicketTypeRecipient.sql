
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketTypeRecipient_GetTicketTypeRecipient]
AS

/*    
Created: 20210914@Tyler  
Task : Ticket Type Recipient page  
DB: bodb_OWP  
    
Revisions:    
  20210914@Tyler: Initial SP - [Redmine: #160545]  
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT t.TypeId, 
               t.TypeName, 
			   r.TicketTypeRecipientId,
               r.RecipientId,
			   r.RecipientType,
               CASE
                   WHEN r.RecipientType = 1
                   THEN g.GroupName
                   ELSE u.Username
               END 'RecipientName'
        FROM dbo.TicketType t WITH(NOLOCK)
             INNER JOIN dbo.TicketTypeRecipient r WITH(NOLOCK) ON t.TypeId = r.TypeId
             LEFT JOIN dbo.TicketGroup g WITH(NOLOCK) ON r.RecipientId = g.GroupId
             LEFT JOIN dbo.[User] u WITH(NOLOCK) ON r.RecipientId = u.UserId;
    END;