/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_NotificationSetting_GetByUserId] @UserId INT
AS
/*          
 Created: 20180925@Kane.Le
 Task : Get All NotificationSetting By UserId
 DB: bodb_OWP_Test          
          
 Revisions:      
	20181008@Kane.Le Improve selected data - [Redmine: #92868]
	20181120@Leo.Vo: Ordering - [Redmine: #105043]
*/
BEGIN
	SET NOCOUNT ON

	SELECT n.NotificationSettingId
		,n.NAME
		,n.IsWatcher
		,ISNULL(m.Value, n.DefaultValue) AS Value
	FROM [dbo].[NotificationSetting] n WITH (NOLOCK)
		LEFT JOIN dbo.NotificationSettingMapping AS m WITH (NOLOCK) ON m.UserId = @UserId
		AND n.NotificationSettingId = m.NotificationSettingId
		ORDER BY n.[Order]
END