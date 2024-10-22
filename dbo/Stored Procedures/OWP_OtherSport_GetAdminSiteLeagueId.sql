
/*<info serverAlias="DBOWP-bodb02" executers="wsv_nap" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_OtherSport_GetAdminSiteLeagueId] @AdminSiteMatchId INT
AS

/*      
 Created: 20240326@Johnny 
 Task : Get LeagueId by adminSiteId
 DB: bodb_OWP      
      
 Revisions:          
	20240326@Johnny: Get event from bodb02 - [Redmine: #199409]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT m.leagueid
        FROM [match] AS m
        WHERE m.matchid = @AdminSiteMatchId
    END;