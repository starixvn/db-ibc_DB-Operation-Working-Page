
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_AccountSetting_SaveUserProfile] @UserId INT, 
                                                            @FileId INT
AS

/*      
 Created: 20250521@Mira
 Task : Account Setting page
 DB: bodb_OWP      
 
 Revisions:
    20250521@Mira: save avatar - [Redmine: #201603]
*/

    BEGIN
        SET NOCOUNT ON;
        IF EXISTS
        (
            SELECT 1
            FROM dbo.UserProfile WITH(NOLOCK)
            WHERE UserId = @UserId
        )
            BEGIN
                UPDATE dbo.UserProfile
                  SET 
                      FileId = @FileId
                WHERE UserId = @UserId;
        END;
            ELSE
            BEGIN
                INSERT INTO dbo.UserProfile
                (UserId, 
                 FileId
                )
                VALUES
                (@UserId, 
                 @FileId
                );
        END;
    END;