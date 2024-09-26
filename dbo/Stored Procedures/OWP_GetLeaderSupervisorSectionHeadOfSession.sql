
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_GetLeaderSupervisorSectionHeadOfSession] @UserIds VARCHAR(MAX)
AS

/*
Created: 20200727@Esther.Nguyen
Task : Ready to Trade Status
DB: bodb_OWP

Revisions:
	20200810@Mira.Nguyen: Staff's readiness notification - [Redmine: #137751]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @allUserIds TABLE(UserId INT);
        INSERT INTO @allUserIds
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@UserIds, ',') u OPTION(MAXRECURSION 0);
        SELECT r.UserId, 
               u.UserId 'ReceivedUserId', 
               u.Username 'ReceivedUserName'
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
                                                        AND (a.Value = 'Leader'
                                                             OR a.Value = 'Supervisor'
                                                             OR a.Value = 'Section Head');
    END;