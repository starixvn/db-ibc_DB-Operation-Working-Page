
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketLogWorkDetail_Get] @TicketId INT
AS

/*      
 Created: 20230602@Johnny
 Task : Get ticket Log Work detail
 DB: bodb_OWP      
      
 Revisions:          
	20230602@Johnny: Get ticket Log Work detail - [Redmine: #185890]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               til.[Subject], 
               im.LeagueName, 
               im.HomeName, 
               im.AwayName, 
               im.AdminSiteMatchId AS 'AdminSiteId', 
               ti.TicketId, 
               ti.TicketStatus, 
               ti.TicketType, 
               tt.TypeName, 
               im.EventDateTime AS KOTime, 
               tst.SubtypeId AS TicketSubTypeId, 
               tst.SubtypeName AS TicketSubTypeName
        FROM TicketIssue AS ti
             INNER JOIN TicketIssueLogWork AS til ON ti.TicketId = til.TicketId
             INNER JOIN TicketType AS tt ON tt.TypeId = ti.TicketType
             LEFT JOIN InfoSiteMatch AS im ON til.AdminsiteId = im.AdminSiteMatchId
             LEFT JOIN TicketSubtype AS tst ON ti.TicketType = tst.TypeId
                                               AND ti.SubtypeId = tst.SubtypeId
        WHERE ti.TicketId = @TicketId;
    END;