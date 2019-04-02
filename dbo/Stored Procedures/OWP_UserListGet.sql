
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_UserListGet] @User VARCHAR(30) = NULL
	,@RoleId SMALLINT = 0
	,@SectionId SMALLINT = 0
	,@PageSize INT = NULL
	,@PageIndex INT = NULL
	,@TotalRecords INT = 0 OUTPUT
	,@ExcludeClosedAccount BIT = 1
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

	DECLARE @SiteId INT

	SELECT @SiteId = SiteId
	FROM DBPOL.NAP_UserControl.dbo.NAP_Sites WITH (NOLOCK)
	WHERE SiteName = 'Operation Working Page'
		AND IsActive = 1
		AND Environment = 'LIVE'

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
			ISNULL(u.Username, '') LIKE '%' + ISNULL(@User, '') + '%'
			OR ISNULL(u.Nickname, '') LIKE '%' + ISNULL(@User, '') + '%'
			)
		AND @RoleId = CASE @RoleId
			WHEN 0
				THEN @RoleId
			ELSE r.RoleId
			END
		AND @SectionId = CASE @SectionId
			WHEN 0
				THEN @SectionId
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
		,u.Pickup
		,u.[Address]
		,u.[Level]
		,ucl.[Value] AS 'LevelName'
		,ISNULL(u.IsSecondAccount, 0) AS IsSecondAccount
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
	LEFT JOIN dbo.RefResource AS ucl WITH (NOLOCK) ON u.[Level] = ucl.ResourceId
		AND ucl.RefName = 'UserLevel'

	-- total item
	SELECT @TotalRecords = COUNT(1)
	FROM #tblUserId

	DROP TABLE #tblUserId

	DROP TABLE #tblFinalUserId
END