
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AccountSetting_GetUserProfile] @UserId INT
AS

/*      
 Created: 20250521@Mira
 Task : Account Setting page
 DB: bodb_OWP      
 
 Revisions:
    20250521@Mira: get quick message - [Redmine: #201603]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT u.Username, 
               f.SavedFileName
        FROM [User] AS u
             LEFT JOIN dbo.UserProfile up ON up.UserId = u.UserId
             LEFT JOIN dbo.FileUpload f WITH(NOLOCK) ON f.FileId = up.FileId
        WHERE u.UserId = @UserId;
    END;