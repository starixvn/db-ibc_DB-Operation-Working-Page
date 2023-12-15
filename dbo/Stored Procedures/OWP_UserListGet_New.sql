USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_UserListGet_New]    Script Date: 12/15/2023 1:11:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_UserListGet_New] @User                 VARCHAR(30), 
                                        @RoleId               VARCHAR(200), 
                                        @SectionId            VARCHAR(200), 
                                        @DepartmentId         VARCHAR(200), 
                                        @CategoryId           VARCHAR(200), 
                                        @LocationCode         VARCHAR(200), 
                                        @ExcludeClosedAccount BIT          = 1, 
                                        @SiteId               INT
AS

/*
Created: 20230112@Los
Task : User Management
DB: bodb_OWP

Revisions:
	20230112@Los: Query user - [Redmine: #196814]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @UserName VARCHAR(30);
        DECLARE @tblUser TABLE(Id INT);
        DECLARE @tblRoleId TABLE(Id INT);
        DECLARE @tblSectionId TABLE(Id INT);
        DECLARE @tblDepartmentId TABLE(Id INT);
        DECLARE @tblCategoryId TABLE(Id INT);
        DECLARE @tblLocationCode TABLE(Id VARCHAR(30));
        SELECT @UserName = RTRIM(LTRIM(@User));
        INSERT INTO @tblRoleId
               SELECT VALUE
               FROM STRING_SPLIT(@RoleId, ',');
        INSERT INTO @tblSectionId
               SELECT VALUE
               FROM STRING_SPLIT(@SectionId, ',');
        INSERT INTO @tblDepartmentId
               SELECT VALUE
               FROM STRING_SPLIT(@DepartmentId, ',');
        INSERT INTO @tblCategoryId
               SELECT VALUE
               FROM STRING_SPLIT(@CategoryId, ',');
        INSERT INTO @tblLocationCode
               SELECT VALUE
               FROM STRING_SPLIT(@LocationCode, ',');
        CREATE TABLE #tblUserId(UserId INT);
        INSERT INTO #tblUserId(UserId)
               SELECT DISTINCT 
                      u.UserId
               FROM dbo.[User] AS u WITH(NOLOCK)
                    INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
                    INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH(NOLOCK) ON us.UserId = u.UserId
                                                                                            AND us.SiteId = @SiteId
                    LEFT JOIN dbo.UserRole AS r WITH(NOLOCK) ON r.UserId = u.UserId
                    INNER JOIN @tblRoleId AS tblr ON(tblr.Id = r.RoleId)
                                                    OR (tblr.Id = 0
                                                        AND r.RoleId IS NULL)
                    INNER JOIN @tblSectionId AS tbls ON u.SectionId = tbls.Id
                                                        OR (tbls.Id = 0
                                                            AND u.SectionId IS NULL)
                    INNER JOIN @tblDepartmentId AS tbld ON u.DepartmentId = tbld.Id
                                                           OR (tbld.Id = 0
                                                               AND u.DepartmentId IS NULL)
                    INNER JOIN @tblCategoryId AS tblc ON u.CategoryId = tblc.Id
                                                         OR (tblc.Id = 0
                                                             AND u.CategoryId IS NULL)
                    INNER JOIN @tblLocationCode AS tblcode ON u.LocationCode = tblcode.Id
                                                              OR (tblcode.Id = 'None'
                                                                  AND u.LocationCode IS NULL)
               WHERE(@ExcludeClosedAccount = 0
                     OR (ci.closed = 0
                         AND ci.reject = 0
                         AND ci.[Enabled] = 1
                         AND us.IsActive = 1))
                    AND (ISNULL(u.Username, '') LIKE '%' + ISNULL(@UserName, '') + '%'
                         OR ISNULL(u.Nickname, '') LIKE '%' + ISNULL(@UserName, '') + '%')
                    AND (u.SectionId NOT IN(17, 23, 28)
               OR u.SectionId IS NULL);
        SELECT u.UserId, 
               u.Username, 
               u.ProfilePic, 
               u.FullName, 
               u.Nickname, 
               u.EmployeeId, 
               u.CategoryId, 
               uc.Value AS 'CategoryName', 
               u.Extension, 
               u.Phone, 
               u.Email, 
               u.Skype, 
               u.DepartmentId, 
               dept.Value AS 'DepartmentName', 
               u.SectionId, 
               sec.Value AS 'SectionName', 
               ur.RoleId, 
               r.Value 'RoleName', 
               u.LocationCode,
               CASE
                   WHEN u.Pickup IS NULL
                   THEN 'none'
                   WHEN u.Pickup = 1
                   THEN 'true'
                   ELSE 'false'
               END AS Pickup, 
               u.[Address], 
               u.[Level], 
               ucl.[Value] AS 'LevelName', 
               u.GroupId, 
               ugr.[Value] AS 'GroupName',
               CASE
                   WHEN u.IsSecondAccount = 1
                   THEN 'true'
                   ELSE 'false'
               END AS IsSecondAccount, 
               u.LanguageId
        FROM dbo.[User] AS u WITH(NOLOCK)
             INNER JOIN #tblUserId AS ul ON ul.UserId = u.UserId
             LEFT JOIN dbo.UserRole AS ur WITH(NOLOCK) ON ur.UserId = u.UserId
             LEFT JOIN dbo.RefResource AS dept WITH(NOLOCK) ON u.DepartmentId = dept.ResourceId
                                                               AND dept.RefName = 'Department'
             LEFT JOIN dbo.RefResource AS sec WITH(NOLOCK) ON u.SectionId = sec.ResourceId
                                                              AND sec.RefName = 'Section'
             LEFT JOIN dbo.RefResource AS uc WITH(NOLOCK) ON u.CategoryId = uc.ResourceId
                                                             AND uc.RefName = 'UserCategory'
             LEFT JOIN dbo.RefResource AS ucl WITH(NOLOCK) ON u.[Level] = ucl.ResourceId
                                                              AND ucl.RefName = 'UserLevel'
             LEFT JOIN dbo.RefResource AS ugr WITH(NOLOCK) ON u.GroupId = ugr.ResourceId
                                                              AND ugr.RefName = 'UserGroup'
             LEFT JOIN dbo.RefResource AS r WITH(NOLOCK) ON ur.RoleId = r.ResourceId
                                                            AND r.RefName = 'UserRole';
        DROP TABLE #tblUserId;
    END;