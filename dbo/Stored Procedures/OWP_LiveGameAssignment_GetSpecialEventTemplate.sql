
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_GetSpecialEventTemplate] @ParentMatchId INT
	,@MinorBettypeId INT
AS
/*
Created: 20191724@Leo
Task : Get special event template
DB: bodb_OWP

Revisions:
	20190724@Leo: Initial SP - [Feature: #117227]
*/
BEGIN
	DECLARE @LeagueName NVARCHAR(500)
		,@HomeName NVARCHAR(200)
		,@AwayName NVARCHAR(200)

	SELECT @LeagueName = l.OWPLeagueName
		,@HomeName = h.OWPTeamName
		,@AwayName = a.OWPTeamName
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
	WHERE OWPMatchId = @ParentMatchId

	SELECT REPLACE(ts.League, '<name>', @LeagueName) AS LeagueName
		,REPLACE(ts.Home, '<name>', @HomeName) AS HomeName
		,REPLACE(ts.Away, '<name>', @AwayName) AS AwayName
	FROM dbo.MinorMatchTemplateSetting AS ts WITH (NOLOCK)
	WHERE ts.MinorBettypeId = @MinorBettypeId
END