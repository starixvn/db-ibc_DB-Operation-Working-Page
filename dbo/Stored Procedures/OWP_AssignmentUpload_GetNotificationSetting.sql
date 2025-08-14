
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_GetNotificationSetting]
AS

/*
Created: 20200609@Mira
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	0200609@Mira: New structure of Assignment Uploading - [Redmine: 129397]
	
*/

     SET NOCOUNT ON;

     -- Result
     SELECT nm.UserId, 
            ns.NotificationSettingId, 
            ISNULL(nm.Value, ns.DefaultValue) 'Value'
     FROM dbo.NotificationSettingMapping AS nm WITH(NOLOCK)
          LEFT JOIN dbo.NotificationSetting AS ns WITH(NOLOCK) ON ns.NotificationSettingId = nm.NotificationSettingId
     WHERE ns.NotificationSettingId IS NOT NULL AND ISNULL(nm.Value, ns.DefaultValue) = 'False';

