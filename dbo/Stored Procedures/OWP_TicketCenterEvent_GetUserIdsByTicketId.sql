
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenterEvent_GetUserIdsByTicketId] @TicketId INT
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : get user id by ticket id
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211006@Liam.Pham: Event ticket - [Redmine: #158037]
	20240216@Mira: Refactor ticket center - [Redmine: #200671]
*/

    BEGIN
        SET NOCOUNT ON;

        -- Get all userId individual & belong to group
        SELECT DISTINCT 
               reader.RecipientId, 
               reader.IsRead, 
               reader.IsPinned
        FROM TicketMessageReader AS reader
        WHERE reader.TicketId = @TicketId;
    END;