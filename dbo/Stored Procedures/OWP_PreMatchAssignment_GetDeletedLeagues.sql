
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE dbo.OWP_PreMatchAssignment_GetDeletedLeagues @EventDate DATE, 
                                                             @IsDay     BIT
AS

/*  
Created: 20200817@Esther.Nguyen  
Task : Pre-Match Assignment 
DB: bodb_OWP  
  
Revisions:  
 20200817@Esther.Nguyen: Get list deleted leagues - [Redmine: #138643]  
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               p.PreMatchLeagueId 'PreMatchLeagueId', 
               o.OWPLeagueName 'LeagueName', 
               u.Username 'DeletedBy', 
               MAX(ul.LoggedDate) 'DeletedTime'
        FROM PreMatchLeague AS p WITH(NOLOCK)
             INNER JOIN OWPLeague AS o WITH(NOLOCK) ON o.OWPLeagueId = p.OWPLeagueId
             INNER JOIN UserLog AS ul WITH(NOLOCK) ON ul.ObjectId = p.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.UserId = ul.CreatorId
        WHERE EventDate = @EventDate
              AND IsDeleted = 1
              AND IsDay = @IsDay
        GROUP BY p.PreMatchLeagueId, 
                 o.OWPLeagueName, 
                 u.Username;
    END;