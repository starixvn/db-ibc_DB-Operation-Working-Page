
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketTypeRecipient_GetTicketTypeRecipient]
AS

/*    
Created: 20210914@Tyler  
Task : Ticket Type Recipient page  
DB: bodb_OWP  
    
Revisions:    
  20210914@Tyler: Initial SP - [Redmine: #160545]  
  20220222@Mira: Save subtypes - [Redmine: #168468]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @GroupType INT= 2;

        -- select ticket type
        SELECT t.TypeId, 
               t.TypeName
        FROM dbo.TicketType t WITH(NOLOCK);

        -- select recipients default
        SELECT r.TicketTypeRecipientId, 
               r.RecipientId, 
               r.RecipientType, 
               r.TypeId,
               CASE
                   WHEN r.RecipientType = @GroupType
                   THEN g.GroupName
                   ELSE u.Username
               END 'RecipientName'
        FROM dbo.TicketTypeRecipient r WITH(NOLOCK)
             LEFT JOIN dbo.TicketGroup g WITH(NOLOCK) ON r.RecipientId = g.GroupId
             LEFT JOIN dbo.[User] u WITH(NOLOCK) ON r.RecipientId = u.UserId;

        -- select subtypes
        SELECT t.SubtypeId, 
               t.TypeId, 
               t.SubtypeName
        FROM dbo.TicketSubtype t WITH(NOLOCK);
    END;