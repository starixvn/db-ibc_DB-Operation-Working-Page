
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketLiveIncidentDetail_Get] @TicketId INT
AS

/*      
 Created: 20221005@Mira
 Task : Get ticket Live Incident detail
 DB: bodb_OWP      
      
 Revisions:          
	20221005@Mira: Get Ticket Live Incident - [Redmine: #178183]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               owpl.OWPLeagueName, 
               owph.OWPTeamName 'HomeName', 
               owpa.OWPTeamName 'AwayName', 
               ti.TicketId, 
               ti.TicketStatus, 
               ti.TicketType, 
               tt.TypeName, 
               tm.CreatedDate, 
               tm.Id AS MessageId, 
               tm.[Message], 
               tm.UserId, 
               tm.FileId, 
               owpm.EventDateTime AS KOTime, 
               tm.IsSaved,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS Username, 
               tst.SubtypeId AS TicketSubTypeId, 
               tst.SubtypeName AS TicketSubTypeName
        FROM TicketIssue AS ti
             INNER JOIN TicketIssueLiveIncident AS tli ON ti.TicketId = tli.TicketId
             INNER JOIN TicketType AS tt ON tt.TypeId = ti.TicketType
             LEFT JOIN TicketMessage AS tm ON tm.TicketId = ti.TicketId
             LEFT JOIN [User] AS u ON u.UserId = tm.UserId
             LEFT JOIN OWPMatch AS owpm ON owpm.OWPMatchId = tli.OwpMatchId
             LEFT JOIN OWPLeague AS owpl ON owpl.OWPLeagueId = owpm.OWPLeagueId
             LEFT JOIN OWPTeam AS owph ON owph.OWPTeamId = owpm.OWPHomeId
             LEFT JOIN OWPTeam AS owpa ON owpa.OWPTeamId = owpm.OWPAwayId
             LEFT JOIN TicketSubtype AS tst ON ti.TicketType = tst.TypeId
                                               AND ti.SubtypeId = tst.SubtypeId
        WHERE ti.TicketId = @TicketId;
    END;