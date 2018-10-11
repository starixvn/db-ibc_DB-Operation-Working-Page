/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_UserListGet] @User VARCHAR(30) = NULL
	,@RoleId SMALLINT = 0
	,@SectionId SMALLINT = 0
	,@PageSize INT = NULL
	,@PageIndex INT = NULL
	,@TotalRecords INT = 0 OUTPUT
AS
/*
Created: 20170117@Julien
Task : User Management
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RowCount INT
		,@RowStart INT
		,@RowEnd INT

	CREATE TABLE #tblUserId (
		RowNumber INT
		,UserId INT
		)

	CREATE TABLE #tblFinalUserId (UserId INT)

	INSERT INTO #tblUserId (
		RowNumber
		,UserId
		)
	SELECT ROW_NUMBER() OVER (
			ORDER BY u.UserId
			) AS RowNumber
		,u.UserId
	FROM dbo.[User] AS u WITH (NOLOCK)
		LEFT JOIN dbo.UserRole AS r WITH (NOLOCK) ON r.UserId = u.UserId
	WHERE (
			ISNULL(u.Username, '') LIKE '%' + ISNULL(@User, '') + '%'
			OR ISNULL(u.Nickname, '') LIKE '%' + ISNULL(@User, '') + '%'
			)
		AND @RoleId = CASE @RoleId
			WHEN 0 THEN @RoleId
			ELSE r.RoleId
			END
		AND @SectionId = CASE @SectionId
			WHEN 0 THEN @SectionId
			ELSE u.SectionId
			END

	IF @PageIndex IS NOT NULL
		AND @PageSize IS NOT NULL
	BEGIN
		INSERT INTO #tblFinalUserId (UserId)
		SELECT UserId
		FROM #tblUserId WITH (NOLOCK)
		WHERE RowNumber BETWEEN ((@PageIndex - 1) * @PageSize + 1)
				AND (@PageIndex * @PageSize)
	END
	ELSE
	BEGIN
		INSERT INTO #tblFinalUserId (UserId)
		SELECT UserId
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
		,r.RoleName AS 'RoleName'
		,u.LocationCode
	FROM dbo.[User] AS u WITH (NOLOCK)
		INNER JOIN #tblFinalUserId AS ul ON ul.UserId = u.UserId
		LEFT JOIN dbo.UserRole AS ur WITH (NOLOCK) ON ur.UserId = u.UserId
		LEFT JOIN dbo.[Role] AS r WITH (NOLOCK) ON r.RoleId = ur.RoleId
		LEFT JOIN dbo.RefResource AS dept WITH (NOLOCK) ON u.DepartmentId = dept.ResourceId
		AND dept.RefName = 'Department'
		LEFT JOIN dbo.RefResource AS sec WITH (NOLOCK) ON u.SectionId = sec.ResourceId
		AND sec.RefName = 'Section'
		LEFT JOIN dbo.RefResource AS uc WITH (NOLOCK) ON u.CategoryId = uc.ResourceId
		AND uc.RefName = 'UserCategory'

	-- total item
	SELECT @TotalRecords = COUNT(1)
	FROM #tblUserId

	DROP TABLE #tblUserId

	DROP TABLE #tblFinalUserId
END