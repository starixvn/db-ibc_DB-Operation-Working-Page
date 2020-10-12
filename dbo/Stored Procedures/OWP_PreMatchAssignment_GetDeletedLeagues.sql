USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_GetDeletedLeagues]    Script Date: 10/12/2020 4:22:54 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
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

*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT TOP 1 p.PreMatchLeagueId 'PreMatchLeagueId', 
                              o.OWPLeagueName 'LeagueName', 
                              u.Username 'DeletedBy', 
                              MAX(DATEADD(HOUR, 12, ul.LoggedDate)) 'DeletedTime'
        FROM PreMatchLeague AS p WITH(NOLOCK)
             INNER JOIN OWPLeague AS o WITH(NOLOCK) ON o.OWPLeagueId = p.OWPLeagueId
             INNER JOIN UserLog AS ul WITH(NOLOCK) ON ul.ObjectId = p.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.UserId = ul.CreatorId
        WHERE EventDate = @EventDate
              AND IsDeleted = 1
              AND IsDay = @IsDay
        GROUP BY p.PreMatchLeagueId, 
                 o.OWPLeagueName, 
                 u.Username
        ORDER BY 'DeletedTime' DESC;
    END;