/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_UserSetting_GetByUserKey]
	@UserId INT,
	@Key NVARCHAR(MAX)
AS

/*
Created: 20250710@Hank.Nguyen
Task : Get user setting by userId and key
DB: bodb_OWP

Revisions:
	20250710@Hank.Nguyen: Get user setting by userId and key [Redmine: #232270]
*/

    BEGIN
        SET NOCOUNT ON;
        
        -- Get user setting by userId and key
        SELECT 
            [Value]
        FROM UserSetting 
        WHERE UserId = @UserId AND [Key] = @Key
    END; 