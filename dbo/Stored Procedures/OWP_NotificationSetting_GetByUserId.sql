
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_NotificationSetting_GetByUserId] @UserId INT
AS
/*          
 Created: 20180925@Kane.Le
 Task : Get All NotificationSetting By UserId
 DB: bodb_OWP_Test          
          
 Revisions:      
	20181008@Kane.Le Improve selected data
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
END