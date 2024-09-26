
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_NewTicket_GetEventForLiveGameAsssignment] @Keyword NVARCHAR(500)
AS

/*      
 Created: 20220216@Johnny
 Task : Get event option
 DB: bodb_OWP      
      
 Revisions:          
	20220929@Johnny: Init sp - [Redmine: #178183]
	20230522@Johnny: Edit date range to get event data (start from today - 1) - [Redmine: #188585]

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @startDate DATETIME;
        SELECT @startDate = DATEADD(DAY, DATEDIFF(DAY, 1, GETDATE()), '12:00:00');
        SELECT DISTINCT TOP 20 m.OWPMatchId AS OwpMatchId, 
                               m.OWPLeagueId AS OwpLeagueId, 
                               l.OWPLeagueName AS LeagueName, 
                               m.OWPHomeId AS HomeId, 
                               m.OWPAwayId AS AwayId, 
                               t.OWPTeamName AS HomeName, 
                               te.OWPTeamName AS AwayName, 
                               0 AS IsLeague, 
                               m.EventDateTime AS EventDateTimeGmt8
        FROM OWPMatch AS m WITH(NOLOCK)
             INNER JOIN OWPLeague AS l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN OWPTeam AS t ON t.OWPTeamId = m.OWPHomeId
             LEFT JOIN OWPTeam AS te ON te.OWPTeamId = m.OWPAwayId
             LEFT JOIN MinorMatch AS mm WITH(NOLOCK) ON mm.MinorMatchId = m.OWPMatchId
        WHERE m.EventDateTime > @startDate
              AND (t.OWPTeamName LIKE '%' + @Keyword + '%'
                   OR te.OWPTeamName LIKE '%' + @Keyword + '%'
                   OR l.OWPLeagueName LIKE '%' + @Keyword + '%')
              AND (mm.MinorBettypeId NOT IN(-1, -2, -88, -89, -5, -8)
        OR mm.MinorBettypeId IS NULL);
    END;