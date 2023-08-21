
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketOtherDetail_Get] @TicketId INT
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get ticket other detail
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211130@Mira: Get ticket status - [Redmine: #165017]
	20220222@Luca: Get TicketSubType - [Redmine: #168624]
	20220310@Liam: Save message - [Redmine: #163767]	
	20221222@Mira: Refactor flow get detail - [Redmine: #181438]
	20230807@Los: Get ticket event - [Redmine: #191778]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               ti.Subject_New  AS [Subject], 
               ti.TicketId, 
               ti.TicketType, 
               ti.TicketStatus, 
               tt.TypeName, 
               tst.SubtypeId AS TicketSubTypeId, 
               tst.SubtypeName AS TicketSubTypeName
        FROM TicketIssue AS ti
             --INNER JOIN TicketIssueOther AS til ON ti.TicketId = til.TicketId

             INNER JOIN TicketType AS tt ON tt.TypeId = ti.TicketType
             LEFT JOIN TicketSubtype AS tst ON ti.TicketType = tst.TypeId
                                           AND ti.SubtypeId = tst.SubtypeId
        WHERE ti.TicketId = @TicketId;
    END;