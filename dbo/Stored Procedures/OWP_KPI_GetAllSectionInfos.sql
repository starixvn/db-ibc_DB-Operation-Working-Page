
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_KPI_GetAllSectionInfos] @UserId INT
AS

/*    
 Created: 20231012@Liam
 Task : get all section 
 DB: bodb_OWP    
    
 Revisions:
	20231012@Liam: get all sections  - [Redmine: #195223]	
*/

     SET NOCOUNT ON;
     DECLARE @SectionId INT;
     SELECT @SectionId = u.SectionId
     FROM [User] u WITH(NOLOCK)
     WHERE u.UserId = @UserId;

     SELECT r.ResourceId 'SectionId', 
            r.[Value] 'SectionName',
            CASE
                WHEN r.ResourceId = @SectionId
                THEN 1
                ELSE 0
            END 'IsContainUser'
     FROM dbo.RefResource r WITH(NOLOCK)
     WHERE r.RefName = 'Section';