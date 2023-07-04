
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketLogWorkDetail_Get] @TicketId INT
AS

/*      
 Created: 20230602@Johnny
 Task : Get ticket Log Work detail
 DB: bodb_OWP      
      
 Revisions:          
	20230602@Johnny: Get ticket Log Work detail - [Redmine: #185890]
	20230703@Johnny: Get Ticket Log Work from bodb02 - [Redmine: #190284]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tblTicketLogWorkEvent TABLE
        (TicketId      INT, 
         AdminSiteId   INT, 
         LeagueId      INT, 
         HomeId        INT, 
         AwayId        INT, 
         EventDateTime DATETIME, 
         [Subject]     NVARCHAR(2000)
        );
        INSERT INTO @tblTicketLogWorkEvent
        (TicketId, 
         AdminSiteId, 
         LeagueId, 
         HomeId, 
         AwayId, 
         EventDateTime, 
         [Subject]
        )
               SELECT til.TicketId, 
                      til.AdminsiteId, 
                      COALESCE(m.leagueid, m14.leagueid) AS LeagueId, 
                      COALESCE(m.homeid, m14.homeid) AS HomeId, 
                      COALESCE(m.awayid, m14.awayid) AS AwayId, 
                      COALESCE(m.globalshowtime, m14.globalshowtime) AS EventDateTime, 
                      til.[Subject]
               FROM TicketIssueLogWork AS til WITH(NOLOCK)
                    LEFT JOIN [bodb02].[dbo].[match] AS m WITH(NOLOCK) ON til.AdminsiteId = m.matchid
                    LEFT JOIN [bodb02].[dbo].[match14] AS m14 WITH(NOLOCK) ON til.AdminsiteId = m14.matchid
               WHERE til.TicketId = @TicketId;
        SELECT DISTINCT 
               til.[Subject], 
               l.leaguename AS LeagueName, 
               t.teamname AS HomeName, 
               ta.teamname AS AwayName, 
               til.AdminSiteId, 
               ti.TicketId, 
               ti.TicketStatus, 
               ti.TicketType, 
               tt.TypeName, 
               til.EventDateTime AS KOTime, 
               tst.SubtypeId AS TicketSubTypeId, 
               tst.SubtypeName AS TicketSubTypeName
        FROM TicketIssue AS ti
             INNER JOIN @tblTicketLogWorkEvent AS til ON ti.TicketId = til.TicketId
             INNER JOIN TicketType AS tt ON tt.TypeId = ti.TicketType
             LEFT JOIN [bodb02].[dbo].[league] AS l ON til.LeagueId = l.leagueid
             LEFT JOIN [bodb02].[dbo].[Team] AS t ON til.HomeId = t.teamid
             LEFT JOIN [bodb02].[dbo].[Team] AS ta ON til.AwayId = ta.teamid
             LEFT JOIN TicketSubtype AS tst ON ti.TicketType = tst.TypeId
                                               AND ti.SubtypeId = tst.SubtypeId;
    END;