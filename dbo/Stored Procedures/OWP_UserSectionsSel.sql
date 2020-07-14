
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_UserSectionsSel]
AS

/*    
 Created: 20200715@Jacob
 Task : LA Reports
 DB: bodb_OWP    
    
 Revisions:
	20200715@Jacob: Initial SP - [Redmine: #137210]	
*/

     SET NOCOUNT ON;
     SELECT DISTINCT 
            u.UserId, 
            u.Username, 
            u.Nickname, 
            r.[Value] AS Section
     FROM dbo.[User] u WITH(NOLOCK)
          INNER JOIN dbo.RefResource r WITH(NOLOCK) ON u.SectionId = r.ResourceId
                                                       AND r.RefName = 'Section';