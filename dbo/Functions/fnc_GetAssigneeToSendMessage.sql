
/*<info serverAlias="DBOWP-bodb_OWP" selecters="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetAssigneeToSendMessage] (
	@OWPMatchId INT
	,@NotificationSettingId SMALLINT
	)
RETURNS @User TABLE (UserId INT NOT NULL)
AS
/*
Created: Leo.Vo@20181012
Task: Get assignee to send message
DB: bodb_OWP

Param's Explanation:
Revisions:
	20181012@Leo.Vo: Initial SP - [Redmine: #102867]
*/
BEGIN
	DECLARE @MainMatchId INT = @OWPMatchId

	SELECT @MainMatchId = ParentMatchId
	FROM dbo.MinorMatch WITH (NOLOCK)
	WHERE MinorMatchId = @OWPMatchId

	INSERT INTO @User
	SELECT DISTINCT a.UserId
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN (
		SELECT OWPMatchId
		FROM dbo.OWPMatch WITH (NOLOCK)
		WHERE OWPMatchId = @MainMatchId
		
		UNION
		SELECT MinorMatchId AS OWPMatchId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @MainMatchId
		) AS m ON a.OWPMatchId = m.OWPMatchId
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotificationSettingId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
		AND nsm.UserId = a.UserId
	WHERE a.UserId IS NOT NULL
		AND ISNULL(nsm.Value, ns.DefaultValue) = 'True'

	RETURN
END