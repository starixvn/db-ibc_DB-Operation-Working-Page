
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AccountSetting_GetQuickMessage] @UserId INT
AS

/*      
 Created: 20240521@Mira
 Task : Account Setting page
 DB: bodb_OWP      
 
 Revisions:
    20240521@Mira: get quick message - [Redmine: #201603]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT q.Id, 
               q.Shortcut, 
               q.Message, 
               q.CreatorId
        FROM dbo.QuickMessage q WITH(NOLOCK)
        WHERE q.CreatorId = @UserId;
    END;