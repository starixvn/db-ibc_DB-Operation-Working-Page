
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_NewLeagueSetting_GetLog] @SettingId INT
AS

/*
Created: 20250924@carlos
Task : Get logs
DB: bodb_OWP	

Revisions:
	20250924@carlos: Initial - [Redmine: #236027]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT [Id] 'LogId', 
               CreatedDate, 
               ModifiedBy, 
               SettingId, 
               [Action], 
               Content
        FROM LeagueSettingLog
        WHERE SettingId = @SettingId
        ORDER BY CreatedDate DESC;
    END;