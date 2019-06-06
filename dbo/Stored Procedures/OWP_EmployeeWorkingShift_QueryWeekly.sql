
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryWeekly] @SiteId INT
	,@FromDate DATE
	,@ToDate DATE
	,@User VARCHAR(2000) = ''
	,@SectionId VARCHAR(2000) = ''
	,@CategoryId VARCHAR(2000) = ''
	,@LocationCode VARCHAR(2000) = ''
	,@ExcludeClosedAccount BIT = 1
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
	 20190513@Kane.Le: Change rule get default shift - [Redmine: #112737]
	 20190521@Leo.Vo: Add Username value - [Feature: #113765]
	 20190524@Leo.Vo: Return OrderId - [Feature: #114073]
	 20190531@Leo.Vo: Refactor SP [Redmine: #114442]

-- @Note:    
EXEC OWP_EmployeeWorkingShift_QueryWeekly @FromDate = '2018/03/12', @ToDate = '2018/03/13', @SectionId = N'1,2,3,4';
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @tblSection TABLE (
		SectionId INT
		,SectionName VARCHAR(50)
		)
	DECLARE @tblCategory TABLE (
		CategoryId INT
		,CategoryName VARCHAR(50)
		)
	DECLARE @tblLocation TABLE (LocationCode VARCHAR(10))

	-- Get Section filter
	INSERT INTO @tblSection (
		SectionId
		,SectionName
		)
	SELECT SectionId
		,SectionName
	FROM dbo.fnc_GetSectionByIds(@SectionId)

	-- Get Category filter
	INSERT INTO @tblCategory (
		CategoryId
		,CategoryName
		)
	SELECT CategoryId
		,CategoryName
	FROM dbo.fnc_GetCategoryByIds(@CategoryId)

	-- Get LocationCode filter
	INSERT INTO @tblLocation (LocationCode)
	SELECT val
	FROM dbo.fnc_SplitStrings(@LocationCode, ',')

	-- table of users
	DECLARE @tblUser TABLE (
		UserId INT
		,SectionId SMALLINT
		);

	INSERT INTO @tblUser (
		UserId
		,SectionId
		)
	SELECT u.UserId
		,ISNULL(u.SectionId, 0)
	FROM dbo.[User] AS u WITH (NOLOCK)
		INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON u.UserId = ci.custid
		INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH (NOLOCK) ON us.UserId = u.UserId
		AND us.SiteId = @SiteId
	WHERE (
			@ExcludeClosedAccount = 0
			OR (
				ci.closed = 0
				AND ci.reject = 0
				AND ci.[Enabled] = 1
				AND us.IsActive = 1
				)
			)
		AND u.IsSecondAccount = 0
		AND (
			LEN(ISNULL(@User, '')) = 0
			OR u.Nickname LIKE '%' + @User + '%'
			OR u.Username LIKE '%' + @User + '%'
			)
		AND EXISTS (
			SELECT 1
			FROM @tblSection AS s
			WHERE u.SectionId = s.SectionId
				OR (
					u.SectionId IS NULL
					AND s.SectionId = 0
					)
			)
		AND EXISTS (
			SELECT 1
			FROM @tblLocation AS l
			WHERE u.LocationCode = l.LocationCode
				OR (
					u.LocationCode IS NULL
					AND l.LocationCode = 'None'
					)
			)
		AND EXISTS (
			SELECT 1
			FROM @tblCategory AS c
			WHERE u.CategoryId = c.CategoryId
				OR (
					u.CategoryId IS NULL
					AND c.CategoryId = 0
					)
			)

	SELECT u.UserId
		,u.Nickname
		,u.Username
		,u.[Address]
		,u.Pickup
		,u.Phone
		,u.Extension
		,u.Skype
		,u.SectionId
		,s.SectionName
		,u.CategoryId
		,od.OrderId
		,n.Note
	FROM @tblUser AS tmp
		INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON tmp.UserId = u.UserId
		INNER JOIN @tblSection AS s ON s.SectionId = tmp.SectionId
		LEFT JOIN dbo.EmployeeWorkingShiftNote AS n WITH (NOLOCK) ON u.UserId = n.UserId
		LEFT JOIN dbo.EmployeeWorkingShiftOrder AS od WITH (NOLOCK) ON od.EmployeeId = u.UserId
		AND od.SectionId = u.SectionId
END;