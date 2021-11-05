
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketSetting_GetAllRecipients] @IncludeGroup BIT, 
                                                           @SiteId       INT
AS

/*    
Created: 20210914@Tyler  
Task : Ticket Type Recipient page  
DB: bodb_OWP  
    
Revisions:    
  20210914@Tyler: Initial SP - [Redmine: #160545]  
  20211005@Mira: Get only active user - [Redmine: #162851]  
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @UserType INT= 1, @GroupType INT= 2;

        -- Get active user
        SELECT u.UserId 'recipientId', 
               u.Username 'recipientName', 
               u.Nickname 'recipientNickname', 
               @UserType 'recipientType'
        FROM dbo.[User] u WITH(NOLOCK)
             INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
             INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH(NOLOCK) ON us.UserId = u.UserId
                                                                                     AND us.SiteId = @SiteId
        WHERE u.Username IS NOT NULL
              AND ci.closed = 0
              AND ci.reject = 0
              AND ci.[Enabled] = 1
              AND us.IsActive = 1

        -- Get TicketGroup
        UNION ALL
        SELECT r.GroupId 'recipientId', 
               r.GroupName 'recipientName', 
               NULL 'recipientNickname', 
               @GroupType 'recipientType'
        FROM dbo.TicketGroup r WITH(NOLOCK)
        WHERE @IncludeGroup = 1;
    END;