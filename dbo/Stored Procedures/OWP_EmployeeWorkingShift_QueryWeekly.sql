/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryWeekly] @UserId INT = 0
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
	 20190513@Kane.Le: Change rule get default shift - [Redmine: #112737]

-- @Note:    
EXEC OWP_EmployeeWorkingShift_QueryWeekly @FromDate = '2018/03/12', @ToDate = '2018/03/13', @SectionId = N'1,2,3,4';
*/
BEGIN
	SET NOCOUNT ON;

	-- caculate is need get defaultShift
	DECLARE @IsJoinDefaultShift BIT
	DECLARE @GetCurrentWeek INT,
			@GetNextWeek INT
	
	SELECT @GetCurrentWeek = DATEPART(wk, GETUTCDATE())	
	SELECT @GetNextWeek= DATEPART(wk,  DATEADD(dd, 0 - (@@DATEFIRST + 5 + DATEPART(dw, @FromDate)) % 7, @FromDate))

	IF @GetNextWeek > @GetCurrentWeek
	BEGIN
	SET @IsJoinDefaultShift = 1
	END
	ELSE
	BEGIN
	SET @IsJoinDefaultShift = 0
	END
	DECLARE @SiteId INT
			,@OrderByUserId INT

	-- get Order Section of current User querying
	IF (@IsReadWeeklySection = 1)
	BEGIN
		SELECT @OrderByUserId = 0
	END
	ELSE
	BEGIN
		SELECT @OrderByUserId = @UserId
	END

	SELECT @SiteId = SiteId
	FROM DBPOL.NAP_UserControl.dbo.NAP_Sites WITH (NOLOCK)
	WHERE SiteName = 'Operation Working Page'
		AND IsActive = 1
		AND Environment = 'LIVE'

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
		,[Name] NVARCHAR(30)
		,SectionId SMALLINT
		,CategoryId SMALLINT
		,LocationCode VARCHAR(10)
		);

	INSERT INTO @tblUser
	SELECT u.UserId
		,ISNULL(u.Nickname, u.Username)
		,ISNULL(u.SectionId, 0)
		,ISNULL(u.CategoryId, 0)
		,ISNULL(u.LocationCode, 'None')
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

	-- return UserList
	SELECT u.UserId AS EmployeeId
		,u.SectionId
		,ts.SectionName
		,u.[Name]
		,tc.CategoryName
		,n.Note
	FROM @tblUser AS u
		INNER JOIN @tblSection AS ts ON ts.SectionId = u.SectionId
		INNER JOIN @tblCategory AS tc ON tc.CategoryId = u.CategoryId
		INNER JOIN @tblLocation AS tl ON tl.LocationCode = u.LocationCode
		LEFT JOIN dbo.EmployeeWorkingShiftNote AS n WITH (NOLOCK) ON u.UserId = n.UserId
		LEFT JOIN dbo.EmployeeWorkingShiftOrder AS od WITH (NOLOCK) ON od.EmployeeId = u.UserId AND od.SectionId = u.SectionId 
					AND od.UserId = @OrderByUserId
	ORDER BY ts.SectionName
		,CASE WHEN od.OrderId IS NOT NULL THEN 1
			ELSE 2 END
		,od.OrderId
		,[Name];

	-- return Shifts
	IF @IsJoinDefaultShift = 1
	BEGIN			
	SET DATEFIRST 1
	DECLARE @DateOfWeek INT = 1
	DECLARE	@TallyShiftDate AS TABLE (ShiftDate DATE)

	CREATE TABLE #tmpEmployeeWorkingShiftDefault (
		UserId INT
		,DateOfWeek INT
		,ShiftId INT
		,ShiftDate DATE
		);
		
WITH cte AS (
	SELECT	[rn] = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))- 1
	FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) x10(n) 
)
INSERT INTO @TallyShiftDate (ShiftDate)
SELECT	[ShiftDate] = DATEADD(DAY, cte.rn, @FromDate)
FROM	cte
WHERE	cte.rn <= DATEDIFF(DAY, @FromDate, @ToDate)

INSERT INTO #tmpEmployeeWorkingShiftDefault
SELECT u.UserId, ep.DayOfTheWeek, [ShiftId]=ISNULL(ep.ShiftId, 0), tally.ShiftDate from @TallyShiftDate AS tally 
CROSS JOIN @tblUser AS u
LEFT JOIN dbo.EmployeeWorkingShiftDefault AS ep
		ON  ep.DayOfTheWeek = DATEPART(WEEKDAY, tally.ShiftDate)
		AND u.UserId = ep.UserId

SELECT [EmployeeId] = df.UserId
		,[ShiftDate] = df.ShiftDate
		,[ShiftStartTime] = ISNULL(wk.ShiftStartTime, df.ShiftDate + CAST(wsc.StartTime AS DATETIME))
		,[ShiftEndTime] = ISNULL(wk.ShiftEndTime, df.ShiftDate + CAST(wsc.EndTime AS DATETIME))
		,[ShiftId] = ISNULL(wk.ShiftId, df.ShiftId)
		,[RefShiftId] = wk.RefShiftId
		,[IsDefaultShift] = CASE 
			WHEN wk.ShiftId IS NULL
				THEN 1
			ELSE 0
			END
	FROM #tmpEmployeeWorkingShiftDefault AS df WITH (NOLOCK)
	LEFT JOIN dbo.EmployeeWorkingShiftColor AS wsc WITH (NOLOCK) ON df.ShiftId = wsc.ShiftId
	LEFT JOIN dbo.EmployeeWorkingShift AS wk WITH (NOLOCK) ON df.UserId = wk.EmployeeId
		AND df.ShiftDate = wk.ShiftDate

	DROP TABLE #tmpEmployeeWorkingShiftDefault
	END 
	ELSE
	BEGIN
	SELECT u.UserId AS EmployeeId
		,ISNULL(s.ShiftDate, @ToDate) AS ShiftDate
		,s.ShiftId
		,s.RefShiftId
		,0 AS IsDefaultShift
	FROM @tblUser AS u
		INNER JOIN dbo.EmployeeWorkingShift AS s WITH (NOLOCK) ON u.UserId = s.EmployeeId
		AND ShiftDate >= @FromDate
		AND ShiftDate <= @ToDate
	END

	-- return Default Shift	 
	IF @IsGetDefaultShift = 1
	BEGIN
		SELECT s.UserId, s.DayOfTheWeek, s.ShiftId
		FROM dbo.EmployeeWorkingShiftDefault AS s WITH (NOLOCK)
		INNER JOIN @tblUser AS u
		ON s.UserId = u.UserId
	END
END;