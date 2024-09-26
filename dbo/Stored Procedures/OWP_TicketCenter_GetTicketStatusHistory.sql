
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetTicketStatusHistory] @TicketId INT
AS

/*
Created: 20211130@Mira
Task : Enhance Ticket Center
DB: bodb_OWP

Revisions:
	20211130@Mira: Add ticket status - [Redmine: #165017]
*/

    BEGIN
        SET NOCOUNT ON;

        -- Get status log
        SELECT TicketId, 
               LogDate, 
               u.Username 'ModifiedBy', 
               OldValue, 
               NewValue
        FROM dbo.[TicketStatusLog] t
             LEFT JOIN dbo.[User] u ON u.UserId = t.ModifiedBy
        WHERE t.TicketId = @TicketId
        ORDER BY t.LogDate DESC;
    END;