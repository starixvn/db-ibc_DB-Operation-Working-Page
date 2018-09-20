/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_Query] @FromDate DATE
	,@ToDate DATE
	,@UserId VARCHAR(2000) = ''
	,@SectionId VARCHAR(2000) = ''
	,@ShiftCode VARCHAR(2000) = ''
	,@CategoryId VARCHAR(2000) = ''
AS
/*      
 Created: 20180312@leo.vo  
 Task : Working Shift Management
 DB: bodb_OWP      
 
 Revisions:
     20180510@leo.vo: add filter @ShiftCode
     20180912@Kane: show user has no WS
     20180913@Leo: show WS note

-- @Note:    
EXEC OWP_EmployeeWorkingShift_Query @FromDate = '2018/03/12', @ToDate = '2018/03/13', @UserId = '8,9,10', @SectionId = N'1,2,3,4';
EXEC OWP_EmployeeWorkingShift_Query @FromDate = '2018/03/12', @ToDate = '2018/05/13', @UserId=NULL, @SectionId = N'1,2,3,4,9,0', @ShiftCode = N'';
*/
BEGIN
	SET NOCOUNT ON;

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

	-- table of users
	DECLARE @tblUser TABLE (
		UserId INT
		,Nickname NVARCHAR(30)
		,UserName NVARCHAR(30)
		,ProfilePic NVARCHAR(500)
		,SectionId SMALLINT
		,CategoryId SMALLINT
		);

	IF LEN(ISNULL(@UserId, '')) = 0
	BEGIN
		INSERT INTO @tblUser
		SELECT u.UserId
			,u.Nickname
			,u.Username
			,u.ProfilePic
			,ISNULL(u.SectionId, 0)
			,ISNULL(u.CategoryId, 0)
		FROM dbo.[User] AS u WITH (NOLOCK)
			LEFT JOIN @tblSection AS s ON u.SectionId = s.SectionId
			LEFT JOIN @tblCategory AS c ON u.CategoryId = c.CategoryId;
	END;
	ELSE
	BEGIN
		INSERT INTO @tblUser
		SELECT u.UserId
			,u.Nickname
			,u.Username
			,u.ProfilePic
			,ISNULL(u.SectionId, 0)
			,ISNULL(u.CategoryId, 0)
		FROM dbo.strSplit(@UserId, ',') u1
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u1.val = u.UserId
			LEFT JOIN @tblSection s ON u.SectionId = s.SectionId
			LEFT JOIN @tblCategory AS c ON u.CategoryId = c.CategoryId
	END;

	-- table of shift codes
	DECLARE @tblShift TABLE (ShiftCode VARCHAR(50));

	IF LEN(ISNULL(@ShiftCode, '')) = 0
	BEGIN
		INSERT INTO @tblShift
		SELECT DISTINCT ShiftCode
		FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
	END;
	ELSE
	BEGIN
		INSERT INTO @tblShift
		SELECT val
		FROM dbo.strSplit(@ShiftCode, ',');
	END;
	
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
		LEFT JOIN dbo.EmployeeWorkingShiftNote AS n WITH (NOLOCK) ON u.UserId = n.UserId
	ORDER BY SectionName
		,[Name];

	SELECT u.UserId AS EmployeeId
		,s.ShiftCode
		,ISNULL(s.ShiftDate, @ToDate) AS ShiftDate
		,c.Background
		,c.Color
	FROM @tblUser AS u
		INNER JOIN dbo.EmployeeWorkingShift AS s WITH (NOLOCK) ON u.UserId = s.EmployeeId
		AND ShiftDate >= @FromDate
			AND ShiftDate <= @ToDate
		LEFT JOIN dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK) ON s.ShiftCode = c.[Name]
END;