/*
	Creator:	20181204@Kane.Le
	Task:		Init Data - [Redmine: #105043]
	Server:		DBOWP.bodb_OWP
*/
USE [bodb_OWP]
GO

DECLARE @NotificationSettingIdTraderAssignment INT = 2
DECLARE @NotificationSettingIdLAAssignment INT = 10
DECLARE @NotificationSettingIdMatchInfo INT = 9
DECLARE @NotificationSettingIdProviderInfo INT = 11

CREATE TABLE #tblNotificationSettingMap (
	NotificationSettingId INT
	,UserId INT
	,[Value] NVARCHAR(250)
	)

INSERT INTO #tblNotificationSettingMap (
	NotificationSettingId
	,UserId
	,[Value]
	)
SELECT @NotificationSettingIdLAAssignment AS NotificationSettingId
	,UserId
	,[Value]
FROM dbo.NotificationSettingMapping WITH (NOLOCK)
WHERE NotificationSettingId = @NotificationSettingIdTraderAssignment
	AND [Value] = 'False'

-- 
INSERT INTO #tblNotificationSettingMap (
	NotificationSettingId
	,UserId
	,[Value]
	)
SELECT @NotificationSettingIdProviderInfo AS NotificationSettingId
	,UserId
	,[Value]
FROM dbo.NotificationSettingMapping WITH (NOLOCK)
WHERE NotificationSettingId = @NotificationSettingIdMatchInfo
	AND [Value] = 'False'

INSERT INTO NotificationSettingMapping (
	NotificationSettingId
	,UserId
	,[Value]
	)
SELECT NotificationSettingId
	,UserId
	,[Value]
FROM #tblNotificationSettingMap

DROP TABLE #tblNotificationSettingMap
