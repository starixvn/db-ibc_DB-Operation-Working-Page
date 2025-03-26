
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_QuickCreateGroupChat_QueryAllAssigneeByParentId] @ParentId INT
AS

/*    
 Created: 20250319@Los
 Task : LA Reports
 DB: bodb_OWP    
    
 Revisions:
	20250319@Los: Query all assignee by parent Id - [Redmine: #217783]	
*/

     SET NOCOUNT ON;
     SELECT DISTINCT u.UserId 'RecipientId',
		u.Username,
		u.Nickname,
		1 'RecipientType'
	 FROM [User] AS u WITH (NOLOCk) 
	 INNER JOIN Assignment AS a WITH (NOLOCK) ON u.UserId=a.UserId
	 INNER JOIN MinorMatch AS mm WITH (NOLOCK) ON a.OWPMatchId=mm.MinorMatchId
	 WHERE mm.ParentMatchId=@ParentId
	 UNION  
	 SELECT u.UserId 'RecipientId',
		u.Username,
		u.Nickname,
		1 'recipientType'
	 FROM [User] AS u WITH (NOLOCk) 
	 INNER JOIN Assignment AS a WITH (NOLOCK) ON u.UserId=a.UserId
	  WHERE a.OWPMatchId=@ParentId
	 