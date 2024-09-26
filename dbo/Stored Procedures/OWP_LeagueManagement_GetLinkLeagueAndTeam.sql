/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_LeagueManagement_GetLinkLeagueAndTeam] @LeagueIdString VARCHAR(MAX)
AS
/*
Created: 20210907@Carlos
Task : New table LinkLeagueAndTeam 
ref: https://nexdev.net/projects/operation-electronic-records/wiki/Link_League_and_Match
DB: bodb_OWP	

Revisions:
	20210907@Carlos: Get team info by leagueId - [Redmine: #160543]
*/
BEGIN

	SET NOCOUNT ON;

	DECLARE @allLeagueIds TABLE(LeagueId INT);
     INSERT INTO @allLeagueIds
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@LeagueIdString, ',') u OPTION(MAXRECURSION 0);
            
    SELECT DISTINCT ids.LeagueId
    FROM @allLeagueIds AS ids
		INNER JOIN LinkLeagueAndTeam AS lat
		ON ids.LeagueId=lat.OWPLeagueId
END