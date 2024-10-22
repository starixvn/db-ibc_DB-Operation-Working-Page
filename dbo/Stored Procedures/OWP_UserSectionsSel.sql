
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_UserSectionsSel]
AS

/*    
 Created: 20200715@Jacob
 Task : LA Reports
 DB: bodb_OWP    
    
 Revisions:
	20200715@Jacob: Initial SP - [Redmine: #137210]	
	20200815@Jacob: Archive plan for OWP tables - [Redmine: #137757]	
*/

     SET NOCOUNT ON;
     SELECT DISTINCT 
            u.UserId, 
            u.Username, 
            u.Nickname, 
            r.[Value] AS Section,
			u.SectionId
     FROM dbo.[User] u WITH(NOLOCK)
          LEFT JOIN dbo.RefResource r WITH(NOLOCK) ON u.SectionId = r.ResourceId
                                                       AND r.RefName = 'Section';