
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketSetting_GetAllRecipients] @IncludeGroup BIT
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
        DECLARE @UserType INT= 1, @GroupType INT= 2;
        SELECT u.UserId 'recipientId', 
               u.Username 'recipientName', 
               u.Nickname 'recipientNickname', 
               @UserType 'recipientType'
        FROM dbo.[User] u WITH(NOLOCK)
        WHERE u.Username IS NOT NULL
        UNION ALL
        SELECT r.GroupId 'recipientId', 
               r.GroupName 'recipientName', 
               NULL 'recipientNickname', 
               @GroupType 'recipientType'
        FROM dbo.TicketGroup r WITH(NOLOCK)
        WHERE @IncludeGroup = 1;
    END;