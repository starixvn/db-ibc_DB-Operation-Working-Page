
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketSupportDetail_Get] @TicketId INT
AS

/*      
 Created: 20211231@Johnny.Thai
 Task : Get ticket support detail
 DB: bodb_OWP      
      
 Revisions:          
	20211231@Johnny.Thai: Event ticket - [Redmine: #158037]
	20220222@Luca: Get TicketSubType - [Redmine: #168624]
	20220310@Liam: Save message  - [Redmine: #163767]
	20221222@Mira: Refactor flow get detail - [Redmine: #181438]
	20230807@Los: Get ticket event - [Redmine: #191778]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               ti.Subject_New AS [Subject], 
               ti.TicketId, 
               ti.TicketType, 
               ti.TicketStatus, 
               tt.TypeName, 
               tst.SubtypeId AS TicketSubTypeId, 
               tst.SubtypeName AS TicketSubTypeName
        FROM TicketIssue AS ti
             INNER JOIN TicketType AS tt WITH(NOLOCK) ON tt.TypeId = ti.TicketType
             LEFT JOIN TicketSubtype AS tst ON ti.TicketType = tst.TypeId
                                               AND ti.SubtypeId = tst.SubtypeId
        WHERE ti.TicketId = @TicketId;
    END;