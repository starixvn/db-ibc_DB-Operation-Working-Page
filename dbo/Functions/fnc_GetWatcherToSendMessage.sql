
/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetWatcherToSendMessage] (@NotificationSettingId SMALLINT)
RETURNS @User TABLE (UserId INT NOT NULL)
AS
/*
Created: Leo.Vo@20181012
Task: Collect users to send message
DB: bodb_OWP

Param's Explanation:
Revisions:
	20181012@Leo.Vo: Initial SP - [Redmine: #102867]
	20190307@Raymond.Le: Modify get list watchers - [Redmine: #109560]
*/
BEGIN
	INSERT INTO @User
	SELECT DISTINCT nsm.UserId
	FROM dbo.NotificationSetting AS ns WITH (NOLOCK)
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
	WHERE ns.NotificationSettingId = @NotificationSettingId
		AND ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		AND ns.IsWatcher = 1

	RETURN
END