
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_UserSetting_Update]
	@UserId INT,
	@Key NVARCHAR(MAX),
	@Value NVARCHAR(MAX)
AS

/*
Created: 20250710@Hank.nguyen
Task : Update user setting 
DB: bodb_OWP

Revisions:
	20250710@Hank.nguyen: Update user setting [Redmine: #232270]
*/

    BEGIN
        SET NOCOUNT ON;
        
        -- Check if user setting already exists for this user and key
        IF EXISTS (SELECT 1 FROM UserSetting WHERE UserId = @UserId AND [Key] = @Key)
        BEGIN
            -- Update existing setting
            UPDATE UserSetting 
            SET [Value] = @Value
            WHERE UserId = @UserId AND [Key] = @Key
        END
        ELSE
        BEGIN
            -- Insert new setting if not existing
            INSERT INTO UserSetting (
                UserId,
                [Key],
                [Value]
            )
            VALUES (
                @UserId,
                @Key,
                @Value
            )
        END
    END;