/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_TeamManagement_GetInfoTeam] @TeamName NVARCHAR(100) = '',
	@LeagueName NVARCHAR(100) = '',
	@LeagueGroupId INT = -1
AS

/*
Created: 230303@Frankie
Task : Implement Team Management Function
DB: bodb_OWP	

Revisions:
	20250618@Frankie: Query data - [Redmine: #230303]
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @TimeZoneGMT8 INT = 8;
	DECLARE @Today DATE = DATEADD(HOUR, @TimeZoneGMT8 - DATEDIFF(HOUR, GETUTCDATE(), GETDATE()), GETDATE());

	SELECT 
		team.OWPTeamId AS TeamId,
		team.OWPTeamName AS TeamName,
		league.OWPLeagueId AS LeagueId,
		league.OWPLeagueName AS LeagueName,
		rr.ResourceId as LeagueGroupId,
		leagueGroup.LeagueGroupName
	FROM LinkLeagueAndTeam AS link WITH (NOLOCK)
		INNER JOIN OWPTeam AS team WITH (NOLOCK) ON link.OWPTeamId = team.OWPTeamId
		INNER JOIN OWPLeague AS league WITH (NOLOCK) ON link.OWPLeagueId = league.OWPLeagueId
		CROSS APPLY (
			SELECT [dbo].[fnc_GetLeagueGroupByDate](@Today, league.OWPLeagueId) AS LeagueGroupName
		) AS leagueGroup
		INNER JOIN RefResource AS rr WITH (NOLOCK) ON leagueGroup.LeagueGroupName = rr.Value
	WHERE team.OWPTeamName LIKE '%'+@TeamName+'%'
			AND league.OWPLeagueName LIKE '%'+@LeagueName+'%'
			AND rr.RefName = 'LeagueCategory'
			AND (
				@LeagueGroupId = -1 AND rr.ResourceId IN (1, 2, 3, 4, 5)
				OR @LeagueGroupId <> -1 AND rr.ResourceId = @LeagueGroupId
			)
		
END