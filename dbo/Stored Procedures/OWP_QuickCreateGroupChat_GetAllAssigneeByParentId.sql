
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_QuickCreateGroupChat_QueryAllAssigneeByParentId] @ParentId INT
AS

/*    
 Created: 20250319@Los
 Task : LA Reports
 DB: bodb_OWP    
    
 Revisions:
	20250319@Los: Query all assignee by parent Id - [Redmine: #217783]	
	20250408@Los: Identify Main and Child Match Chat Groups - [Redmine: #221727]	
*/

     SET NOCOUNT ON;
     SELECT DISTINCT u.UserId 'recipientId',
		u.Username  'userName',
		u.Nickname 'nickName',
		1 'recipientType'
	 FROM [User] AS u WITH (NOLOCk) 
	 INNER JOIN Assignment AS a WITH (NOLOCK) ON u.UserId=a.UserId
	 INNER JOIN MinorMatch AS mm WITH (NOLOCK) ON a.OWPMatchId=mm.MinorMatchId
	 WHERE mm.ParentMatchId=@ParentId
	 UNION  
	 SELECT u.UserId 'recipientId',
		u.Username  'userName',
		u.Nickname 'nickName',
		1 'recipientType'
	 FROM [User] AS u WITH (NOLOCk) 
	 INNER JOIN Assignment AS a WITH (NOLOCK) ON u.UserId=a.UserId
	  WHERE a.OWPMatchId=@ParentId
	 