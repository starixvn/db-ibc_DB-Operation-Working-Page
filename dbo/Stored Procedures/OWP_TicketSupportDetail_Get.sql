
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketSupportDetail_Get] @TicketId INT
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get ticket support detail
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211130@Mira: Get ticket status - [Redmine: #165017]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               til.[Subject], 
               ti.TicketId, 
               ti.TicketType, 
               ti.TicketStatus, 
               tt.TypeName, 
               tm.CreatedDate, 
               tm.Id AS MessageId, 
               tm.[Message], 
               tm.UserId, 
               tm.FileId,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS Username
        FROM TicketIssue AS ti
             INNER JOIN TicketIssueSupport AS til ON ti.TicketId = til.TicketId
             INNER JOIN TicketType AS tt ON tt.TypeId = ti.TicketType
             INNER JOIN TicketMessage AS tm ON tm.TicketId = ti.TicketId
             INNER JOIN [User] AS u ON u.UserId = tm.UserId
        WHERE ti.TicketId = @TicketId;
    END;