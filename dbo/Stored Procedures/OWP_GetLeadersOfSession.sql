
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_GetLeadersOfSession] @UserIds VARCHAR(MAX)
AS

/*
Created: 20200727@Esther.Nguyen
Task : Ready to Trade Status  
DB: bodb_OWP

Revisions:
	20200727@Esther.Nguyen: Staff's readiness notification - [Redmine: #137751]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @allUserIds TABLE(UserId INT);
        INSERT INTO @allUserIds
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@UserIds, ',') u OPTION(MAXRECURSION 0);
        SELECT r.UserId, 
               u.UserId 'LeaderId', 
               u.Username 'LeaderName'
        FROM
        (
            SELECT t.UserId, 
                   u.SectionId
            FROM dbo.[User] AS u WITH(NOLOCK)
                 INNER JOIN @allUserIds t ON t.UserId = u.UserId
        ) AS r
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.SectionId = r.SectionId
        INNER JOIN dbo.UserRole AS ur WITH(NOLOCK) ON u.UserId = ur.UserId
        INNER JOIN dbo.RefResource AS a WITH(NOLOCK) ON ur.RoleId = a.ResourceId
                                                        AND a.RefName = 'UserRole'
                                                        AND a.Value = 'Leader';
    END;