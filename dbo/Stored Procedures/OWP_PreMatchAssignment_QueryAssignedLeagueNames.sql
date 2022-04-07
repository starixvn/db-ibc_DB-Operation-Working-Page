
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryAssignedLeagueNames] @ActorId           INT, 
                                                                        @BettypeId         INT, 
                                                                        @IsTakeOver        BIT, 
                                                                        @IsDay             BIT, 
                                                                        @PrematchLeagueIds NVARCHAR(MAX)
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
        DECLARE @tempPrematchLeagueId TABLE(PrematchLeagueId INT);
        INSERT INTO @tempPrematchLeagueId
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@PrematchLeagueIds, ',') u OPTION(MAXRECURSION 0);

        -- select league name
        SELECT DISTINCT 
               ol.OWPLeagueName
        FROM dbo.PreMatchAssignment a
             INNER JOIN dbo.PreMatchLeague l WITH(NOLOCK) ON l.PreMatchLeagueId = a.PreMatchLeagueId
             INNER JOIN dbo.OWPLeague ol WITH(NOLOCK) ON ol.OWPLeagueId = l.OWPLeagueId
             INNER JOIN @tempPrematchLeagueId t ON t.PrematchLeagueId = l.PreMatchLeagueId
        WHERE a.UserId = @ActorId
              AND a.Bettype = @BettypeId
              AND l.IsDay = @IsDay
              AND a.IsTakeOver = @IsTakeOver;
    END;