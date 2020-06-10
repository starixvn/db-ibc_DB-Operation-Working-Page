
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_GetNotificationSetting] @UserIdList VARCHAR(1000)
AS

/*
Created: 20200609@Mira
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	0200609@Mira: New structure of Assignment Uploading - [Redmine: 129397]
	
*/

     SET NOCOUNT ON;
     -- temp User
     CREATE TABLE #tempUser
     (UserId INT
     );
     INSERT INTO #tempUser
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@UserIdList, ',') u OPTION(MAXRECURSION 0);

     -- Result
     SELECT u.UserId, 
            ns.NotificationSettingId, 
            ISNULL(nm.Value, ns.DefaultValue) 'Value'
     FROM #tempUser u
          LEFT JOIN dbo.NotificationSettingMapping AS nm WITH(NOLOCK) ON nm.UserId = u.UserId
          LEFT JOIN dbo.NotificationSetting AS ns WITH(NOLOCK) ON ns.NotificationSettingId = nm.NotificationSettingId
     WHERE ns.NotificationSettingId IS NOT NULL;
     
	 -- Drop table
	 DROP TABLE #tempUser;