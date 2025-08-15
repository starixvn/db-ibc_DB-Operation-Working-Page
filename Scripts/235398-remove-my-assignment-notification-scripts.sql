/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250815@Hank.nguyen
Task : Remove my assignment notification
DB: bodb_OWP

Revisions:
	20250815@Hank.nguyen: Remove my assignment notification [Redmine: #235398]
*/
-- Step 1: Create backup of current data
IF OBJECT_ID('dbo.NotificationSettingMapping_backup', 'U') IS NOT NULL
    DROP TABLE dbo.NotificationSettingMapping_backup;

SELECT * INTO dbo.NotificationSettingMapping_backup 
FROM dbo.NotificationSettingMapping WITH(NOLOCK);


GO

-- Step 3: Insert new notification settings
INSERT INTO dbo.NotificationSettingMapping (UserId, NotificationSettingId, Value)
SELECT DISTINCT u.UserId, ns.NotificationSettingId, 'False'
FROM dbo.[User] u WITH(NOLOCK)
CROSS JOIN dbo.NotificationSetting ns WITH(NOLOCK)
WHERE ns.NotificationSettingId != 1
AND NOT EXISTS (
    SELECT 1 
    FROM dbo.NotificationSettingMapping nm WITH(NOLOCK)
    WHERE nm.UserId = u.UserId 
    AND nm.NotificationSettingId = ns.NotificationSettingId
);
