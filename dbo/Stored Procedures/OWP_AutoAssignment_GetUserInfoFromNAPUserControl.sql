
/*<info serverAlias="DBPOL-NAP_UserControl" executers="bodbAdminNet" isFunction="0"></info>*/

CREATE PROCEDURE OWP_AutoAssignment_GetUserInfoFromNAPUserControl @SiteId INT
AS

/*
Created: 20210225@Tyler
Task : Get users for auto assignment
DB: NAP_UserControl

Revisions:
	20210225@Tyler: Initial - [Redmine: #150268]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT us.UserId
        FROM dbo.NAP_UserSite AS us WITH(NOLOCK)
        WHERE us.SiteId = @SiteId
              AND us.IsActive = 1;
    END;
GO