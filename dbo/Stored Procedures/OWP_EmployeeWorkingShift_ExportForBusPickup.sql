
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_ExportForBusPickup] @FromDate DATE
	,@ToDate DATE
	,@User VARCHAR(2000) = ''
	,@Section VARCHAR(2000) = ''
	,@Category VARCHAR(2000) = ''
	,@LocationCode VARCHAR(2000) = ''
AS
/*      
 Created: 20180312@leo.vo  
 Task : Working Shift Management
 DB: bodb_OWP      
 
 Revisions:
     20190107@Kane.Le: Init SP     

-- @Note:    
EXEC [OWP_EmployeeWorkingShift_ExportForBusPickup] @FromDate = '2018/03/12', @ToDate = '2018/03/13', @UserId = '8,9,10', @SectionId = N'1,2,3,4';
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @ExcludeClosedAccount INT

	SET @ExcludeClosedAccount = 1

	DECLARE @SiteId INT

	SELECT @SiteId = SiteId
	FROM DBCUST.NAP_UserControl.dbo.NAP_Sites
	WHERE SiteName = 'Operation Working Page'
		AND IsActive = 1
		AND Environment = 'LIVE'

	-- table of sections
	DECLARE @tblSection TABLE (
		SectionId INT
		,SectionName VARCHAR(50)
		);

	IF LEN(ISNULL(@Section, '')) = 0
	BEGIN
		INSERT INTO @tblSection
		SELECT ResourceId
			,Value
		FROM dbo.RefResource WITH (NOLOCK)
		WHERE RefName = 'Section';

		INSERT INTO @tblSection
		VALUES (
			0
			,'None'
			);
	END;
	ELSE
	BEGIN
		INSERT INTO @tblSection
		SELECT ISNULL(ResourceId, 0)
			,ISNULL(Value, 'None')
		FROM dbo.strSplit(@Section, ',')
		LEFT JOIN dbo.RefResource WITH (NOLOCK) ON RefName = 'Section'
			AND val = ResourceId
	END;

	-- table of categories
	DECLARE @tblCategory TABLE (
		CategoryId INT
		,CategoryName VARCHAR(50)
		);

	IF LEN(ISNULL(@Category, '')) = 0
	BEGIN
		INSERT INTO @tblCategory
		SELECT ResourceId
			,Value
		FROM dbo.RefResource WITH (NOLOCK)
		WHERE RefName = 'UserCategory';

		INSERT INTO @tblCategory
		VALUES (
			0
			,'None'
			);
	END;
	ELSE
	BEGIN
		INSERT INTO @tblCategory
		SELECT ISNULL(ResourceId, 0)
			,ISNULL(Value, 'None')
		FROM dbo.strSplit(@Category, ',')
		LEFT JOIN dbo.RefResource WITH (NOLOCK) ON RefName = 'UserCategory'
			AND val = ResourceId
	END;

	-- table of locations
	DECLARE @tblLocation TABLE (LocationCode VARCHAR(10));

	INSERT INTO @tblLocation
	SELECT val
	FROM dbo.strSplit(@LocationCode, ',')

	-- table WorkingShift
	DECLARE @tblEmpWorkingShift TABLE (
		EmployeeId INT
		,ShiftCode NVARCHAR(50)
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		)

	INSERT INTO @tblEmpWorkingShift
	SELECT emp.EmployeeId
		,emp.ShiftCode
		,emp.ShiftDate
		,emp.ShiftStartTime
		,emp.ShiftEndTime
	FROM EmployeeWorkingShift emp WITH (NOLOCK)
	WHERE ShiftDate >= @FromDate
		AND ShiftDate <= @ToDate

	-- table of users
	DECLARE @tblUser TABLE (
		UserId INT
		,Address NVARCHAR(500)
		,[Name] NVARCHAR(30)
		,ProfilePic NVARCHAR(500)
		,SectionId SMALLINT
		,SectionName NVARCHAR(30)
		,CategoryId SMALLINT
		,LocationCode VARCHAR(10)
		);

	INSERT INTO @tblUser
	SELECT u.UserId
		,u.Address
		,ISNULL(u.Nickname, u.Username) AS [Name]
		,u.ProfilePic
		,ISNULL(u.SectionId, 0)
		,ISNULL(s.SectionName, '') AS SectionName
		,ISNULL(u.CategoryId, 0)
		,ISNULL(u.LocationCode, 'None')
	FROM dbo.[User] AS u WITH (NOLOCK)
	INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON u.UserId = ci.custid
	INNER JOIN DBCUST.NAP_UserControl.dbo.NAP_UserSite AS us ON us.UserId = u.UserId
		AND us.SiteId = @SiteId
	INNER JOIN @tblSection AS s ON u.SectionId = s.SectionId
	INNER JOIN @tblCategory AS c ON u.CategoryId = c.CategoryId
	INNER JOIN @tblLocation AS l ON u.LocationCode = l.LocationCode
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
			LEN(ISNULL(@User, '')) = 0
			OR u.Nickname LIKE '%' + @User + '%'
			OR u.Username LIKE '%' + @User + '%'
			)
		AND u.Pickup = 1
		AND u.UserId IN (
			SELECT ep.EmployeeId
			FROM @tblEmpWorkingShift ep
			)

	SELECT u.UserId AS EmployeeId
		,[Address]
		,SectionName
		,[Name]
	FROM @tblUser u

	SELECT u.UserId AS EmployeeId
		,s.ShiftCode
		,ISNULL(s.ShiftDate, @ToDate) AS ShiftDate
		,s.ShiftStartTime
		,c.Background
		,c.Color
	FROM @tblUser AS u
	INNER JOIN @tblEmpWorkingShift AS s ON u.UserId = s.EmployeeId
	LEFT JOIN dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK) ON s.ShiftCode = c.[Name]
	ORDER BY s.ShiftStartTime
END;