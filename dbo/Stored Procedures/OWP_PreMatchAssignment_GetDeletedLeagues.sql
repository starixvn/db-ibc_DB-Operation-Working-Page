
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_GetDeletedLeagues] @EventDate DATE, 
                                                                 @IsDay     BIT
AS

/*  
Created: 20200817@Esther.Nguyen  
Task : Pre-Match Assignment 
DB: bodb_OWP  
  
Revisions:  
	20200817@Esther.Nguyen: Get list deleted leagues - [Redmine: #138643]  
	20200930@Tyler: Fix select duplicate  - [Redmine: #142258]  
	20201105@Tyler: Fix select duplicate  - [Redmine: #144400]  

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tblDeletedLeague TABLE
        (PreMatchLeagueId INT, 
         LeagueName       VARCHAR(MAX), 
         DeletedTime      DATETIME
        );
        INSERT INTO @tblDeletedLeague
        (PreMatchLeagueId, 
         LeagueName, 
         DeletedTime
        )
               SELECT DISTINCT 
                      p.PreMatchLeagueId 'PreMatchLeagueId', 
                      o.OWPLeagueName 'LeagueName', 
                      MAX(DATEADD(HOUR, 12, ul.LoggedDate)) 'DeletedTime'
               FROM PreMatchLeague AS p WITH(NOLOCK)
                    INNER JOIN OWPLeague AS o WITH(NOLOCK) ON o.OWPLeagueId = p.OWPLeagueId
                    INNER JOIN UserLog AS ul WITH(NOLOCK) ON ul.ObjectId = p.PreMatchLeagueId
               WHERE EventDate = @EventDate
                     AND IsDeleted = 1
                     AND IsDay = @IsDay
               GROUP BY p.PreMatchLeagueId, 
                        o.OWPLeagueName
               ORDER BY 'DeletedTime' DESC;
        SELECT PreMatchLeagueId, 
               LeagueName, 
               u.Username 'DeletedBy', 
               DeletedTime
        FROM @tblDeletedLeague AS dl
             INNER JOIN UserLog AS ul WITH(NOLOCK) ON ul.ObjectId = dl.PreMatchLeagueId
                                                      AND DeletedTime = DATEADD(HOUR, 12, ul.LoggedDate)
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON ul.CreatorId = u.UserId;
    END;