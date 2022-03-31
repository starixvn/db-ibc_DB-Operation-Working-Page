
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryAssignedLeagueNames] @ActorId INT, 
                                                                        @Date    DATETIME
AS

/*
Created: 20220331@Mira
Task : Open Prematch Trading page
DB: bodb_OWP

Revisions:
	20220331@Mira: Get league names - [Redmine: #170721]
*/

    BEGIN
        SET NOCOUNT ON;

        -- select league name
        SELECT DISTINCT 
               ol.OWPLeagueName
        FROM dbo.PreMatchAssignment a
             INNER JOIN dbo.PreMatchLeague l WITH(NOLOCK) ON l.PreMatchLeagueId = a.PreMatchLeagueId
             INNER JOIN dbo.OWPLeague ol WITH(NOLOCK) ON ol.OWPLeagueId = l.OWPLeagueId
        WHERE a.UserId = @ActorId
              AND l.EventDate = @Date;
    END;