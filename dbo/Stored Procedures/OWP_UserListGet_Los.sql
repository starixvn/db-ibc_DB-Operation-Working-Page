USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_UserListGet_Los]    Script Date: 12/7/2023 1:22:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OWP_UserListGet_Los] @User VARCHAR(30) = NULL
	,@RoleId SMALLINT = NULL
	,@SectionId SMALLINT = NULL
	,@DepartmentId SMALLINT = NULL
	,@CategoryId SMALLINT = NULL
	,@LocationCode VARCHAR(10) = NULL
	,@PageSize INT = NULL
	,@PageIndex INT = NULL
	,@TotalRecords INT = 0 OUTPUT
	,@ExcludeClosedAccount BIT = 1
	,@SiteId INT
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
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @UserName VARCHAR(30) 
	SELECT @UserName = RTRIM(LTRIM(@User))
	DECLARE @RowCount INT
		,@RowStart INT
		,@RowEnd INT
	
	CREATE TABLE #tblUserId (
		RowNumber INT
		,UserId INT
		)

	CREATE TABLE #tblFinalUserId (
		RowNumber INT
		,UserId INT
		)

	INSERT INTO #tblUserId (
		RowNumber
		,UserId
		)
	SELECT ROW_NUMBER() OVER (
			ORDER BY u.UserName
			) AS RowNumber
		,u.UserId
	FROM dbo.[User] AS u WITH (NOLOCK)
		INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON u.UserId = ci.custid
		INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH (NOLOCK) ON us.UserId = u.UserId
		AND us.SiteId = @SiteId
		LEFT JOIN dbo.UserRole AS r WITH (NOLOCK) ON r.UserId = u.UserId
	WHERE (
			@ExcludeClosedAccount = 0
			OR (
				ci.closed = 0
				AND ci.reject = 0
				AND ci.[Enabled] = 1
				AND us.IsActive = 1
				)
			)
		AND (
			ISNULL(u.Username, '') LIKE '%' + ISNULL(@UserName, '') + '%'
			OR ISNULL(u.Nickname, '') LIKE '%' + ISNULL(@UserName, '') + '%'
			)
		AND (
			@RoleId IS NULL
			OR @RoleId = ISNULL(r.RoleId, 0)
			)
		AND (
			@SectionId IS NULL
			OR @SectionId = ISNULL(u.SectionId, 0)
			)
		AND (
			@DepartmentId IS NULL
			OR @DepartmentId = ISNULL(u.DepartmentId, 0)
			)
		AND (
			@CategoryId IS NULL
			OR @CategoryId = ISNULL(u.CategoryId, 0)
			)
		AND (
			@LocationCode IS NULL
			OR @LocationCode = ISNULL(u.LocationCode, 'None')
			)
		AND ( u.SectionId NOT IN (17,23,28)
		   OR u.SectionId IS NULL )

	IF @PageIndex IS NOT NULL
		AND @PageSize IS NOT NULL
	BEGIN
		INSERT INTO #tblFinalUserId (RowNumber, UserId)
		SELECT RowNumber, UserId
		FROM #tblUserId WITH (NOLOCK)
		WHERE RowNumber BETWEEN ((@PageIndex - 1) * @PageSize + 1)
				AND (@PageIndex * @PageSize)
	END
	ELSE
	BEGIN
		INSERT INTO #tblFinalUserId (RowNumber, UserId)
		SELECT RowNumber, UserId
		FROM #tblUserId WITH (NOLOCK)
	END
	
	SELECT u.UserId
		,u.Username
		,u.ProfilePic
		,u.FullName
		,u.Nickname
		,u.EmployeeId
		,u.CategoryId
		,uc.Value AS 'CategoryName'
		,u.Extension
		,u.Phone
		,u.Email
		,u.Skype
		,u.DepartmentId
		,dept.Value AS 'DepartmentName'
		,u.SectionId
		,sec.Value AS 'SectionName'
		,ur.RoleId
		,r.Value 'RoleName'
		,u.LocationCode
		,u.Pickup
		,u.[Address]
		,u.[Level]		
		,ucl.[Value] AS 'LevelName'
		,u.GroupId
		,ugr.[Value] AS 'GroupName'
		,u.IsSecondAccount
		,u.LanguageId
	FROM dbo.[User] AS u WITH (NOLOCK)
		INNER JOIN #tblFinalUserId AS ul ON ul.UserId = u.UserId
		LEFT JOIN dbo.UserRole AS ur WITH (NOLOCK) ON ur.UserId = u.UserId
		LEFT JOIN dbo.RefResource AS dept WITH (NOLOCK) ON u.DepartmentId = dept.ResourceId
		AND dept.RefName = 'Department'
		LEFT JOIN dbo.RefResource AS sec WITH (NOLOCK) ON u.SectionId = sec.ResourceId
		AND sec.RefName = 'Section'
		LEFT JOIN dbo.RefResource AS uc WITH (NOLOCK) ON u.CategoryId = uc.ResourceId
		AND uc.RefName = 'UserCategory'
		LEFT JOIN dbo.RefResource AS ucl WITH (NOLOCK) ON u.[Level] = ucl.ResourceId
		AND ucl.RefName = 'UserLevel'
		LEFT JOIN dbo.RefResource AS ugr WITH (NOLOCK) ON u.GroupId = ugr.ResourceId
		AND ugr.RefName = 'UserGroup'
		LEFT JOIN dbo.RefResource AS r WITH (NOLOCK) ON ur.RoleId = r.ResourceId
		AND r.RefName = 'UserRole'
	ORDER BY ul.RowNumber

	-- total item
	SELECT @TotalRecords = COUNT(1)
	FROM #tblUserId	 
	DROP TABLE #tblUserId

	DROP TABLE #tblFinalUserId
END
/* End */
