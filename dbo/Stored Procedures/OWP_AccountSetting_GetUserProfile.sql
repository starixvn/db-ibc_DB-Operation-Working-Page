
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AccountSetting_GetUserProfile] @UserId INT
AS

/*      
 Created: 20240521@Mira
 Task : Account Setting page
 DB: bodb_OWP      
 
 Revisions:
    20240521@Mira: get quick message - [Redmine: #201603]
	20240725@Mira: get nickname or username - [Redmine: #201603]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT COALESCE(u.Nickname, u.Username) AS Username, 
               f.SavedFileName
        FROM [User] AS u WITH(NOLOCK)
             LEFT JOIN dbo.UserProfile up WITH(NOLOCK) ON up.UserId = u.UserId
             LEFT JOIN dbo.FileUpload f WITH(NOLOCK) ON f.FileId = up.FileId
        WHERE u.UserId = @UserId;
    END;