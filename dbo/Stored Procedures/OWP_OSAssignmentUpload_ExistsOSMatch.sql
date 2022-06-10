/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROC [dbo].[OWP_OSAssignmentUpload_ExistsOSMatch] @OSMatches NVARCHAR(MAX)
/*
Created: 20220610@Luca
Task : delete match 
DB: bodb_OWP

Revisions:
	20220610@Luca: check exists os match [Redmine: #173765]
*/
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Temp TABLE
        (Id         INT, 
         [DateTime] DATETIME, 
         League     NVARCHAR(100), 
         Home       NVARCHAR(100), 
         Away       NVARCHAR(100), 
         Sport      NVARCHAR(100)
        );
        INSERT INTO @Temp
               SELECT *
               FROM OPENJSON(@OSMatches) WITH(Id INT, [DateTime] DATETIME, League NVARCHAR(100), Home NVARCHAR(100), Away NVARCHAR(100), Sport NVARCHAR(100));
        
        SELECT m.OSMatchId AS Id, 
               l.LeagueName AS League, 
               t.[DateTime], 
               t.Home, 
               t.Away, 
               t.Sport
        FROM OSMatch m
             INNER JOIN OSLeague l ON m.LeagueId = l.OSLeagueId
             INNER JOIN @Temp t ON m.EventDateTime = t.[DateTime]
                                   AND l.LeagueName = t.League
                                   AND m.HomeName = t.Home
                                   AND m.AwayName = t.Away
                                   AND m.Sport = t.Sport;
    END;