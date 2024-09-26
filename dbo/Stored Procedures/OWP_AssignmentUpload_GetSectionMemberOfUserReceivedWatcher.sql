
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_GetSectionMemberOfUserReceivedWatcher]
AS

/*
Created: 20200612@Mira
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	0200612@Mira: New structure of Assignment Uploading - [Redmine: 129397]
	
*/

     SET NOCOUNT ON;
     
     SELECT ISNULL(mem.UserId, r.UserId) 'UserId', 
            r.UserId 'UserWatcherId', 
			r.Username 'UserWatcherName',
            r.NotificationSettingId
     FROM
     (
         SELECT DISTINCT 
                nm.UserId, 
				u.Username,
                u.SectionId, 
                ns.NotificationSettingId
         FROM dbo.NotificationSetting AS ns WITH(NOLOCK)
              INNER JOIN dbo.NotificationSettingMapping AS nm WITH(NOLOCK) ON ns.NotificationSettingId = nm.NotificationSettingId
              LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON nm.UserId = u.UserId
         WHERE ns.IsWatcher = 1
               AND nm.Value = 'True'
     ) AS r
     LEFT JOIN dbo.[User] AS mem WITH(NOLOCK) ON r.SectionId = mem.SectionId
                                                 AND mem.SectionId IS NOT NULL
     ORDER BY UserId;