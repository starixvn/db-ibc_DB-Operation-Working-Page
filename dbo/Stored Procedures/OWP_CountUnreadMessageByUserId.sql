
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_CountUnreadMessageByUserId] @UserId INT
AS

/*    
 Created: 20220217@Carlos.nguyen
 Task : CountUnreadMessage
 DB: bodb_OWP    
    
 Revisions:
	20220217@Carlos.nguyen: Initial SP - [Redmine: #168468]
	20221005@Mira:  Get Ticket Live Incident - [Redmine: #178183]
*/

    BEGIN
        SET NOCOUNT ON;	

        -- Count
        SELECT COUNT(tis.TicketId)
        FROM TicketIssue AS tis WITH(NOLOCK)
             INNER JOIN TicketType AS ty WITH(NOLOCK) ON tis.TicketType = ty.TypeId
             INNER JOIN TicketMessage AS tm WITH(NOLOCK) ON tis.TicketId = tm.TicketId
             INNER JOIN TicketMessageReader AS reader WITH(NOLOCK) ON tis.TicketId = reader.TicketId
        WHERE reader.IsRead = 0
              AND RecipientId = @UserId
              AND GroupId IS NULL;
    END;