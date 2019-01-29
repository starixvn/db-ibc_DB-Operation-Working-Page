
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_ExportForBusPickup] @FromDate DATE
	,@ToDate DATE
	,@User VARCHAR(2000) = ''
	,@UserId INT
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
	 20190121@Kane.Le: Change shift code to shiftId

-- @Note:    
EXEC [OWP_EmployeeWorkingShift_ExportForBusPickup] @FromDate = '2018/03/12', @ToDate = '2018/03/13', @UserId = '8,9,10', @SectionId = N'1,2,3,4';
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @TimeZoneOffsetOfUser INT = dbo.fnc_GetWorkingShiftTimezoneOffset(@UserId)
	DECLARE @ExcludeClosedAccount INT
	DECLARE @SiteId INT

	SET @ExcludeClosedAccount = 1

	--SET @FromDate = CAST(DATEADD(MINUTE, @TimeZoneOffsetOfUser, @FromDate) AS DATETIME)
	--SET @ToDate = CAST(DATEADD(MINUTE, @TimeZoneOffsetOfUser, @ToDate) AS DATETIME)
	SELECT @SiteId = SiteId
	FROM DBCUST.NAP_UserControl.dbo.NAP_Sites WITH (NOLOCK)
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

	-- convert to GMT by setting table WorkingShiftColor 
	DECLARE @tblEmployeeWorkingShiftColor TABLE (
		ShiftId INT
		,ShiftCode NVARCHAR(50)
		,Background NVARCHAR(50)
		,Color NVARCHAR(50)
		,StartTime TIME
		,EndTime TIME
		,StartTimeText NVARCHAR(5)
		,EndTimeText NVARCHAR(5)
		,IsTimeShift BIT
		)

	INSERT INTO @tblEmployeeWorkingShiftColor
	SELECT wsc.ShiftId
		,wsc.ShiftCode
		,wsc.Background
		,wsc.Color
		,wsc.StartTime
		,wsc.EndTime
		,CASE 
			WHEN (
					(ISNULL(wsc.IsTimeShift, 0) = 1)
					AND (RIGHT(CONVERT(VARCHAR(5), DATEADD(MINUTE, @TimeZoneOffsetOfUser, wsc.StartTime), 108), 2) = '00')
					)
				THEN CONVERT(VARCHAR(2), DATEADD(MINUTE, @TimeZoneOffsetOfUser, wsc.StartTime), 108)
			ELSE CONVERT(VARCHAR(5), DATEADD(MINUTE, @TimeZoneOffsetOfUser, wsc.StartTime), 108)
			END AS StartTimeText
		,CASE 
			WHEN (
					(ISNULL(wsc.IsTimeShift, 0) = 1)
					AND (RIGHT(CONVERT(VARCHAR(5), DATEADD(MINUTE, @TimeZoneOffsetOfUser, wsc.EndTime), 108), 2) = '00')
					)
				THEN CONVERT(VARCHAR(2), DATEADD(MINUTE, @TimeZoneOffsetOfUser, wsc.EndTime), 108)
			ELSE CONVERT(VARCHAR(5), DATEADD(MINUTE, @TimeZoneOffsetOfUser, wsc.EndTime), 108)
			END AS StartTimeText
		,wsc.IsTimeShift
	FROM dbo.EmployeeWorkingShiftColor wsc WITH (NOLOCK)

	-- table WorkingShift
	DECLARE @tblEmpWorkingShift TABLE (
		EmployeeId INT
		,ShiftId INT
		,ShiftCode NVARCHAR(50)
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		)

	INSERT INTO @tblEmpWorkingShift
	SELECT emp.EmployeeId
		,wsc.ShiftId
		,CASE 
			WHEN (wsc.IsTimeShift = 1)
				THEN wsc.StartTimeText + ' > ' + wsc.EndTimeText
			ELSE wsc.ShiftCode
			END AS ShiftCode
		,emp.ShiftDate
		,DATEADD(MINUTE, @TimeZoneOffsetOfUser, emp.ShiftStartTime)
		,DATEADD(MINUTE, @TimeZoneOffsetOfUser, emp.ShiftEndTime)
	FROM dbo.EmployeeWorkingShift emp WITH (NOLOCK)
	JOIN @tblEmployeeWorkingShiftColor wsc ON emp.ShiftId = wsc.ShiftId
	WHERE ShiftDate >= @FromDate
		AND ShiftDate <= @ToDate

	-- table of users
	DECLARE @tblUser TABLE (
		UserId INT
		,Address NVARCHAR(500)
		,Nickname NVARCHAR(30)
		,UserName NVARCHAR(30)
		,ProfilePic NVARCHAR(500)
		,SectionId SMALLINT
		,CategoryId SMALLINT
		,LocationCode VARCHAR(10)
		);

	INSERT INTO @tblUser
	SELECT u.UserId
		,u.Address
		,u.Nickname
		,u.Username
		,u.ProfilePic
		,ISNULL(u.SectionId, 0)
		,ISNULL(u.CategoryId, 0)
		,ISNULL(u.LocationCode, 'None')
	FROM dbo.[User] AS u WITH (NOLOCK)
	INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON u.UserId = ci.custid
	INNER JOIN DBCUST.NAP_UserControl.dbo.NAP_UserSite AS us WITH (NOLOCK) ON us.UserId = u.UserId
		AND us.SiteId = @SiteId
	LEFT JOIN @tblSection AS s ON u.SectionId = s.SectionId
	LEFT JOIN @tblCategory AS c ON u.CategoryId = c.CategoryId
	LEFT JOIN @tblLocation AS l ON u.LocationCode = l.LocationCode
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

	DECLARE @tblUserOutput TABLE (
		UserId INT
		,SectionId SMALLINT
		,Address NVARCHAR(500)
		,SectionName NVARCHAR(500)
		,[Name] NVARCHAR(30)
		,Avatar NVARCHAR(500)
		,CategoryName NVARCHAR(500)
		);

	INSERT INTO @tblUserOutput
	SELECT u.UserId AS EmployeeId
		,u.SectionId
		,u.Address
		,ts.SectionName
		,ISNULL(u.Nickname, u.Username) AS [Name]
		,u.ProfilePic AS Avatar
		,tc.CategoryName
	FROM @tblUser AS u
	INNER JOIN @tblSection AS ts ON ts.SectionId = u.SectionId
	INNER JOIN @tblCategory AS tc ON tc.CategoryId = u.CategoryId
	INNER JOIN @tblLocation AS tl ON tl.LocationCode = u.LocationCode
	LEFT JOIN dbo.EmployeeWorkingShiftNote AS n WITH (NOLOCK) ON u.UserId = n.UserId
	ORDER BY SectionName
		,[Name];

	SELECT u.UserId AS EmployeeId
		,[Address]
		,SectionName
		,[Name]
	FROM @tblUserOutput u

	SELECT u.UserId AS EmployeeId
		,s.ShiftCode
		,ISNULL(s.ShiftDate, @ToDate) AS ShiftDate
		,s.ShiftStartTime
		,c.Background
		,c.Color
		,s.ShiftId
	FROM @tblUserOutput AS u
	INNER JOIN @tblEmpWorkingShift AS s ON u.UserId = s.EmployeeId
	LEFT JOIN @tblEmployeeWorkingShiftColor c ON s.ShiftId = c.ShiftId
	ORDER BY s.ShiftCode

	SELECT wsc.ShiftId
		,CASE 
			WHEN (wsc.IsTimeShift = 1)
				THEN wsc.StartTimeText + ' > ' + wsc.EndTimeText
			ELSE wsc.ShiftCode
			END AS ShiftCode
		,wsc.Background
		,wsc.Color
		,CASE 
			WHEN (wsc.IsTimeShift = 1)
				THEN DATEADD(MINUTE, @TimeZoneOffsetOfUser, wsc.StartTime)
			ELSE wsc.StartTime
			END AS StartTime
		,CASE 
			WHEN (wsc.IsTimeShift = 1)
				THEN DATEADD(MINUTE, @TimeZoneOffsetOfUser, wsc.EndTime)
			ELSE wsc.EndTime
			END AS EndTime
		,wsc.IsTimeShift
	FROM @tblEmployeeWorkingShiftColor wsc
	JOIN @tblEmpWorkingShift ws ON wsc.ShiftId = ws.ShiftId
	ORDER BY ShiftCode
END;