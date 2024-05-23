
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_AccountSetting_DeleteQuickMessage] @Id INT = 0
AS

/*      
 Created: 20250521@Mira
 Task : Account Setting page
 DB: bodb_OWP      
 
 Revisions:
    20250521@Mira: delete quick message - [Redmine: #201603]
*/

    BEGIN
        SET NOCOUNT ON;
        DELETE dbo.QuickMessage
        WHERE Id = @Id;
    END;