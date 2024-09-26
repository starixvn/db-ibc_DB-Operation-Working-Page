/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_API_SyncUsers_Get_Change_From_AdminSite]
	/*    
 Created: 20190418@Kane.Le
 Task : Sync UserName from AdminSite
 DB: bodb_OWP    
    
 Revisions:
	20190104@Kane.Le: Initial SP - [Redmine: #111840] 
*/
	 
AS
BEGIN
	SELECT u.Username AS 'OldUserName', c.username AS 'NewUserName'
	FROM [user] u
	INNER JOIN bodb02.dbo.customer c WITH (NOLOCK) ON c.custid = u.userid
	WHERE c.roleid > 4
	AND c.username <> u.Username
END