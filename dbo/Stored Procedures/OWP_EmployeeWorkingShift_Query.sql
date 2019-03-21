/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_Query] @UserId INT = 0
	,@FromDate DATE
	,@ToDate DATE
	,@User VARCHAR(2000) = ''
	,@SectionId VARCHAR(2000) = ''
	,@CategoryId VARCHAR(2000) = ''
	,@LocationCode VARCHAR(2000) = ''
	,@ExcludeClosedAccount BIT = 1
	,@IsGetDefaultShift BIT = 0
	,@IsReadWeeklySection BIT = 0
AS
/*      
 Created: 20180312@leo.vo  
 Task : Working Shift Management
 DB: bodb_OWP      
 
 Revisions:
     20180510@leo.vo: add filter @ShiftCode
     20180912@Kane: show user has no WS
     20180913@Leo: show WS note
     20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
     20181009@Leo.Vo: Filter WS - [Redmine: #102867]
     20181218@Leo.Vo: Exclude inactive site - [Redmine: #106196]
     20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
     20190215@Leo.Vo: Default shift - [Redmine: #108723]
	 20190311@Kane.Le: Get RefShiftId output - [Redmine: #109560]
	 20190319@Raymond.Le: Customize employee order of weekly WS - [Redmine: #110322]

-- @Note:    
EXEC OWP_EmployeeWorkingShift_Query @FromDate = '2018/03/12', @ToDate = '2018/03/13', @UserId = '8,9,10', @SectionId = N'1,2,3,4';
EXEC OWP_EmployeeWorkingShift_Query @FromDate = '2018/03/12', @ToDate = '2018/05/13', @UserId=NULL, @SectionId = N'1,2,3,4,9,0', @ShiftId = N'1';
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @SiteId INT
			,@OrderBySectionId INT
	DECLARE @TimezoneOffset INT = dbo.fnc_GetWorkingShiftTimezoneOffset(@UserId)

	-- get Order Section of current User querying

	IF (@IsReadWeeklySection = 1)
	BEGIN
		SELECT @OrderBySectionId = 0
	END
	ELSE
	BEGIN
		SELECT @OrderBySectionId = u.SectionId
		FROM dbo.[User] AS u WITH (NOLOCK)
		WHERE u.UserId = @UserId
	END

	SELECT @SiteId = SiteId
	FROM DBPOL.NAP_UserControl.dbo.NAP_Sites WITH (NOLOCK)
	WHERE SiteName = 'Operation Working Page'
		AND IsActive = 1
		AND Environment = 'LIVE'

	-- table of sections
	DECLARE @tblSection TABLE (
		SectionId INT
		,SectionName VARCHAR(50)
		);

	IF LEN(ISNULL(@SectionId, '')) = 0
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
		FROM dbo.strSplit(@SectionId, ',')
			LEFT JOIN dbo.RefResource WITH (NOLOCK) ON RefName = 'Section'
			AND val = ResourceId
	END;

	-- table of categories
	DECLARE @tblCategory TABLE (
		CategoryId INT
		,CategoryName VARCHAR(50)
		);

	IF LEN(ISNULL(@CategoryId, '')) = 0
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
		FROM dbo.strSplit(@CategoryId, ',')
			LEFT JOIN dbo.RefResource WITH (NOLOCK) ON RefName = 'UserCategory'
			AND val = ResourceId
	END;

	-- table of locations
	DECLARE @tblLocation TABLE (LocationCode VARCHAR(10));

	INSERT INTO @tblLocation
	SELECT val
	FROM dbo.strSplit(@LocationCode, ',')

	-- table of users
	DECLARE @tblUser TABLE (
		UserId INT
		,Nickname NVARCHAR(30)
		,UserName NVARCHAR(30)
		,ProfilePic NVARCHAR(500)
		,SectionId SMALLINT
		,CategoryId SMALLINT
		,LocationCode VARCHAR(10)
		);

	INSERT INTO @tblUser
	SELECT u.UserId
		,u.Nickname
		,u.Username
		,u.ProfilePic
		,ISNULL(u.SectionId, 0)
		,ISNULL(u.CategoryId, 0)
		,ISNULL(u.LocationCode, 'None')
	FROM dbo.[User] AS u WITH (NOLOCK)
		INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON u.UserId = ci.custid
		INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH (NOLOCK) ON us.UserId = u.UserId
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

	SELECT u.UserId AS EmployeeId
		,u.SectionId
		,ts.SectionName
		,ISNULL(u.Nickname, u.Username) AS [Name]
		,u.ProfilePic AS Avatar
		,tc.CategoryName
		,n.Note
	FROM @tblUser AS u
		INNER JOIN @tblSection AS ts ON ts.SectionId = u.SectionId
		INNER JOIN @tblCategory AS tc ON tc.CategoryId = u.CategoryId
		INNER JOIN @tblLocation AS tl ON tl.LocationCode = u.LocationCode
		LEFT JOIN dbo.EmployeeWorkingShiftNote AS n WITH (NOLOCK) ON u.UserId = n.UserId
		LEFT JOIN dbo.EmployeeWorkingShiftOrder AS od WITH (NOLOCK) ON u.UserId = od.EmployeeId AND od.SectionId = @OrderBySectionId
	ORDER BY od.OrderId
		,ts.SectionName
		,[Name];

	SELECT u.UserId AS EmployeeId
		,ISNULL(s.ShiftDate, @ToDate) AS ShiftDate
		,s.ShiftId
		,s.RefShiftId
	FROM @tblUser AS u
		INNER JOIN dbo.EmployeeWorkingShift AS s WITH (NOLOCK) ON u.UserId = s.EmployeeId
		AND ShiftDate >= @FromDate
		AND ShiftDate <= @ToDate

	IF @IsGetDefaultShift = 1
	BEGIN
		SELECT s.UserId, s.DayOfTheWeek, s.ShiftId
		FROM dbo.EmployeeWorkingShiftDefault AS s WITH (NOLOCK)
		INNER JOIN @tblUser AS u
		ON s.UserId = u.UserId
	END
END;