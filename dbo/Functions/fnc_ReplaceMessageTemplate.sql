
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_ReplaceMessageTemplate] (
	@MessageTemplate NVARCHAR(MAX)
	,@OWPMatchId INT
	,@UserId INT = NULL
	)
RETURNS NVARCHAR(MAX)
AS
/*
Created: Leo.Vo@20181012
Task: Replace template message with match info (only apply on main match)
DB: bodb_OWP

Param's Explanation:
Revisions:
	20181012@Leo.Vo: Initial SP - [Redmine: #102867]
	20190703@Tyler.Dang: change message template - [Redmine: #116230]
*/
BEGIN
	DECLARE @Username NVARCHAR(30)
		,@HomeTeam NVARCHAR(200)
		,@AwayTeam NVARCHAR(200)
		,@MatchNo VARCHAR(50)
		,@League NVARCHAR(500)

	SELECT @HomeTeam = h.OWPTeamName
		,@AwayTeam = a.OWPTeamName
		,@MatchNo = CASE WHEN m.MatchNo = '' THEN '' ELSE '#' + m.MatchNo END
		,@League = b.OWPLeagueName
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		LEFT JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
		LEFT JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
		LEFT JOIN dbo.OWPLeague AS b WITH (NOLOCK) ON b.OWPLeagueId = m.OWPLeagueId
	WHERE m.OWPMatchId = @OWPMatchId

	SET @MessageTemplate = REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<Event>', @HomeTeam + ' -vs- ' + @AwayTeam)
								, '<League>', @League)
							, '<Match.No>', @MatchNo)

	IF @UserId IS NOT NULL
	BEGIN
		SELECT @Username = dbo.[fnc_GetUsernameByUserId](@UserId)

		SET @MessageTemplate = REPLACE(@MessageTemplate, '<User>', @Username)
	END

	RETURN @MessageTemplate
END