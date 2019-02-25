/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_API_SyncNotificationSettingWatcher]
	/*    
 Created: 20190221@Kane.Le
 Task : Sync NotificationSetting
 DB: bodb_OWP    
    
 Revisions:
	20190104@Kane.Le: Initial SP - [Redmine: #108723] 
*/
	@Ids NVARCHAR(MAX)
AS
BEGIN
	CREATE TABLE #NotificationSettingWatcher (
		NotificationId INT
		,UserId INT
		)

	INSERT INTO #NotificationSettingWatcher
	SELECT ns.NotificationSettingId
		,snm.UserId
	FROM NotificationSetting ns WITH (NOLOCK)
	JOIN NotificationSettingMapping snm WITH (NOLOCK) ON ns.NotificationSettingId = snm.NotificationSettingId
	WHERE ns.IsWatcher = 1
		AND snm.UserId IN (
			SELECT val
			FROM dbo.fnc_SplitStrings(@Ids, ',')
			)
	OPTION (MAXRECURSION 0)

	DELETE dbo.NotificationSettingMapping
	WITH (ROWLOCK)
	WHERE UserId NOT IN (
			SELECT UserId
			FROM #NotificationSettingWatcher
			)

	DROP TABLE #NotificationSettingWatcher
END