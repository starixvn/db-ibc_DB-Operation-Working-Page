
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketMatchDetail_Get] @TicketId INT
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get ticket match detail
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211018@Liam.Pham: Update ticket match detail - [Redmine: #158037]
	20211130@Mira: Get ticket status - [Redmine: #165017]
	20220222@Luca: Get TicketSubType - [Redmine: #168624]
	20220310@Liam: Save message  - [Redmine: #163767]	
	20221222@Mira: Refactor flow get detail - [Redmine: #181438]
	2023031@Johnny: Add KOTime - [Redmine: #184166]
	20230807@Los: Get ticket event - [Redmine: #191778]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               ti.OWPLeagueId_New AS OwpLeagueId, 
               owpl.OWPLeagueName, 
               ti.OwpHomeId_New AS OwpHomeId, 
               ti.OwpAwayId_New AS OwpAwayId, 
               ifm.HomeName, 
               ifm.AwayName, 
               ti.TicketId, 
               ti.TicketStatus, 
               ti.TicketType, 
               tt.TypeName,
			   ifm.EventDateTime AS KOTime,
               tst.SubtypeId AS TicketSubTypeId, 
               tst.SubtypeName AS TicketSubTypeName
        FROM TicketIssue AS ti
             INNER JOIN OWPLeague AS owpl ON owpl.OWPLeagueId = ti.OwpLeagueId_New
             INNER JOIN TicketType AS tt ON tt.TypeId = ti.TicketType
             INNER JOIN InfoSiteMatch AS ifm ON ifm.InfoSiteMatchId = ti.InfoSiteMatchId_New
             LEFT JOIN TicketSubtype AS tst ON ti.TicketType = tst.TypeId
                                               AND ti.SubtypeId = tst.SubtypeId
        WHERE ti.TicketId = @TicketId;
    END;