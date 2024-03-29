
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketTypeRecipient_GetTicketTypeRecipient]
AS

/*    
Created: 20210914@Tyler  
Task : Ticket Type Recipient page  
DB: bodb_OWP  
    
Revisions:    
  20210914@Tyler: Initial SP - [Redmine: #160545]  
  20220222@Mira: Save subtypes - [Redmine: #168468]
  20221027@Liam.Pham: add recipient by section - [Redmine: #179305]
  20230510@Johnny: get recipient with SubtypeId - [Redmine: #186518]
  20240329@Johnny: add assignee type - [Redmine: #202819]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @GroupType INT= 2;
        DECLARE @SectionType INT= 3;
        DECLARE @AssigneeType INT= 4;

        -- select ticket type
        SELECT t.TypeId, 
               t.TypeName
        FROM dbo.TicketType t WITH(NOLOCK);

        -- select recipients default
        SELECT r.TicketTypeRecipientId, 
               r.RecipientId, 
               r.RecipientType, 
               r.TypeId, 
               ts.SubtypeName,
               CASE
                   WHEN r.RecipientType = @GroupType
                   THEN g.GroupName
                   WHEN r.RecipientType = @SectionType
                   THEN rr.[Value]
				   WHEN r.RecipientType = @AssigneeType
				   THEN 'Assignee'
                   ELSE u.Username
               END 'RecipientName'
        FROM dbo.TicketTypeRecipient r WITH(NOLOCK)
             LEFT JOIN dbo.TicketSubtype ts WITH(NOLOCK) ON ts.SubtypeId = r.SubtypeId
             LEFT JOIN dbo.TicketGroup g WITH(NOLOCK) ON r.RecipientId = g.GroupId
             LEFT JOIN dbo.[User] u WITH(NOLOCK) ON r.RecipientId = u.UserId
             LEFT JOIN dbo.RefResource rr WITH(NOLOCK) ON r.RecipientId = rr.ResourceId
                                                          AND RR.RefName = 'Section';

        -- select subtypes
        SELECT t.SubtypeId, 
               t.TypeId, 
               t.SubtypeName
        FROM dbo.TicketSubtype t WITH(NOLOCK);
    END;