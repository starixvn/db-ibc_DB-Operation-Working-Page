/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_API_SyncUsers_Get_Change_From_AdminSite]
/*
 Created: 20190418@Kane.Le
 Task : Sync UserName from AdminSite
 DB: bodb_OWP

 Revisions:
    20190104@Kane.Le: Initial SP - [Redmine: #111840]
    20240925@Los: customer -> custInfo [Redmine: #209152]
    20241024@Tim.Trinh: fix bug sync username [Redmine: #212657]
*/
AS
BEGIN
    SELECT u.Username AS 'OldUserName', c.username AS 'NewUserName'
    FROM dbo.[user] u WITH (NOLOCK)
        INNER JOIN bodb02.dbo.custInfo c WITH (NOLOCK) ON c.custid = u.userid
    WHERE c.roleid > 4
        AND c.username <> ISNULL(u.Username, '')
END