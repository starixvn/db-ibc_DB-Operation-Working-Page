USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_UserListGet]    Script Date: 12/6/2023 3:43:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_UserListGet] @User                 VARCHAR(30), 
                                        @RoleId               VARCHAR(200), 
                                        @SectionId            VARCHAR(200), 
                                        @DepartmentId         VARCHAR(200), 
                                        @CategoryId           VARCHAR(200), 
                                        @LocationCode         VARCHAR(200), 
                                        @ExcludeClosedAccount BIT          = 1, 
                                        @SiteId               INT
AS

/*
Created: 20170117@Julien
Task : User Management
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181120@Kane.Le: Get Pickup, Address, Level [Redmine: #105043]
	20181218@Leo.Vo: Exclude inactive site - [Redmine: #106196]
	20190402@Kane.Le: Get IsSecondAccount - [Redmine: #11068]
	20190426@Kane.Le: Remove space whene search username - [Redmine: #111840]
	20190718@Tyler.Dang: Reorder User Management by Username - [Redmine: #117125]
	20190719@Tyler.Dang: Reorder User Management by Username - [Redmine: #117125]
	20191011@Kane.Le: Get User Group - [Redmine: #121765]
	20191206@Carlos.Nguyen:  Update language - [Redmine: #124940]
	20220531@Liam.Pham: Hide section [Redmine: #173255]
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
               SELECT val
               FROM fnc_SplitStrings(@RoleId, ',') u OPTION(MAXRECURSION 0);
        INSERT INTO @tblSectionId
               SELECT val
               FROM dbo.fnc_SplitStrings(@SectionId, ',') AS t OPTION(MAXRECURSION 0);
        INSERT INTO @tblDepartmentId
               SELECT val
               FROM dbo.fnc_SplitStrings(@DepartmentId, ',') AS t OPTION(MAXRECURSION 0);
        INSERT INTO @tblCategoryId
               SELECT val
               FROM dbo.fnc_SplitStrings(@CategoryId, ',') AS t OPTION(MAXRECURSION 0);
        INSERT INTO @tblLocationCode
               SELECT val
               FROM dbo.fnc_SplitStrings(@LocationCode, ',') AS t OPTION(MAXRECURSION 0);
        CREATE TABLE #tblUserId(UserId INT);
        INSERT INTO #tblUserId(UserId)
               SELECT u.UserId
               FROM dbo.[User] AS u WITH(NOLOCK)
                    INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
                    INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH(NOLOCK) ON us.UserId = u.UserId
                                                                                            AND us.SiteId = @SiteId
                    LEFT JOIN dbo.UserRole AS r WITH(NOLOCK) ON r.UserId = u.UserId
                    LEFT JOIN @tblRoleId AS tblr ON tblr.Id = r.RoleId
                    LEFT JOIN @tblSectionId AS tbls ON u.SectionId = tbls.Id
                    LEFT JOIN @tblDepartmentId AS tbld ON u.DepartmentId = tbld.Id
                    LEFT JOIN @tblCategoryId AS tblc ON u.CategoryId = tblc.Id
                    LEFT JOIN @tblLocationCode AS tblcode ON u.LocationCode = tblcode.Id
               WHERE(@ExcludeClosedAccount = 0
                     OR (ci.closed = 0
                         AND ci.reject = 0
                         AND ci.[Enabled] = 1
                         AND us.IsActive = 1))
                    AND (ISNULL(u.Username, '') LIKE '%' + ISNULL(@UserName, '') + '%'
                         OR ISNULL(u.Nickname, '') LIKE '%' + ISNULL(@UserName, '') + '%')
             AND tblr.Id = ISNULL(r.RoleId, 0)
             AND tbls.Id = ISNULL(u.SectionId, 0)
             AND tbld.Id = ISNULL(u.DepartmentId, 0)
             AND tblc.Id = ISNULL(u.CategoryId, 0)
             AND tblcode.Id = ISNULL(u.LocationCode, 'None')
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