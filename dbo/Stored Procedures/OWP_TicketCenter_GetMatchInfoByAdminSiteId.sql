
/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetMatchInfoByAdminSiteId] @AdminSiteId INT
AS

/*      
 Created: 20220605@Liam 
 Task : Get Match Info by adminSiteId
 DB: bodb_OWP      
      
 Revisions:          
	20220605@Liam: Init sp - [Redmine: #185890]
	20230630@Johnny: Get event from bodb02 - [Redmine: #185890]
*/

     DECLARE @startDate DATETIME;
     SELECT @startDate = DATEADD(DAY, DATEDIFF(DAY, 1, GETDATE()), '12:00:00');
    BEGIN
        SET NOCOUNT ON;
        SELECT l.leaguename AS LeagueName, 
               t.teamname AS HomeName, 
               te.teamname AS AwayName, 
               DATEADD(HOUR, 12, m.GlobalShowTime) AS KOTime
        FROM [match] AS m
             LEFT JOIN league AS l WITH(NOLOCK) ON m.leagueid = l.leagueid
             LEFT JOIN Team AS t WITH(NOLOCK) ON m.homeid = t.teamid
             LEFT JOIN Team AS te WITH(NOLOCK) ON m.awayid = te.teamid
        WHERE m.matchid = @AdminSiteId
              AND m.GlobalShowTime >= @startDate;
    END;