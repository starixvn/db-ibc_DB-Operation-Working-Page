
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketCenter_GetMatchInfoByAdminSiteId] @AdminSiteId INT
AS

/*      
 Created: 20220605@Liam 
 Task : Get Match Info by adminSiteId
 DB: bodb_OWP      
      
 Revisions:          
	20220605@Liam: Init sp - [Redmine: #185890]
*/

     DECLARE @startDate DATETIME;
     SELECT @startDate = DATEADD(DAY, DATEDIFF(DAY, 1, GETDATE()), '12:00:00');
    BEGIN
        SET NOCOUNT ON;
        SELECT ifm.LeagueName, 
               ifm.HomeName, 
               ifm.AwayName, 
               ifm.EventDateTime 'KOTime'
        FROM InfoSiteMatch ifm
        WHERE ifm.EventDateTime > @startDate
              AND ifm.AdminSiteMatchId = @AdminSiteId;
    END;


	