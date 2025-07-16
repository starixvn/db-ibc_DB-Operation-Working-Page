/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250703@Lilac.Nguyen
Task : Remove setting of message notification
DB: bodb_OWP

Revisions:
	20250703@Lilac.Nguyen: create table backup and remove setting of message notification [Redmine: #232214]
*/

CREATE TABLE NotificationSettingMapping_Backup (
    NotificationSettingId SMALLINT NOT NULL,
    UserId INT NOT NULL,
    [Value] NVARCHAR(250) NOT NULL
);

INSERT INTO NotificationSettingMapping_Backup (
    NotificationSettingId, UserId, [Value]
)
SELECT
    NotificationSettingId,
    UserId,
    [Value]
FROM NotificationSettingMapping;

UPDATE NotificationSettingMapping
SET [Value] = 'False'
WHERE NotificationSettingId != 1;