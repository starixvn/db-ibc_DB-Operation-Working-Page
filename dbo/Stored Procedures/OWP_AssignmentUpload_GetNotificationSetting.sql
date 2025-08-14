
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_GetNotificationSetting]
AS

/*
Created: 20200609@Mira
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	0200609@Mira: New structure of Assignment Uploading - [Redmine: 129397]
	020250814@Hank: New structure of Assignment Uploading - [Redmine: 235398]
*/

     SET NOCOUNT ON;

     SELECT u.UserId, 
            ns.NotificationSettingId, 
            ISNULL(nm.Value, ns.DefaultValue) 'Value'
     FROM dbo.[User] AS u WITH(NOLOCK)
          CROSS JOIN dbo.NotificationSetting AS ns WITH(NOLOCK)
          LEFT JOIN dbo.NotificationSettingMapping AS nm WITH(NOLOCK) 
               ON nm.UserId = u.UserId AND nm.NotificationSettingId = ns.NotificationSettingId
     WHERE ISNULL(nm.Value, ns.DefaultValue) = 'True';


