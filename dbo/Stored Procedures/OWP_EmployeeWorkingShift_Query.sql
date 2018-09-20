/*      
 Created: 20180312@leo.vo  
 Task : Working Shift Management
 DB: bodb_OWP      
      
 Revisions:
     â€¢ 20180510@leo.vo: add filter @ShiftCode

-- @Note:    
EXEC OWP_EmployeeWorkingShift_Query @FromDate = '2018/03/12', @ToDate = '2018/03/13', @UserId = '8,9,10', @SectionId = N'1,2,3,4';
EXEC OWP_EmployeeWorkingShift_Query @FromDate = '2018/03/12', @ToDate = '2018/05/13', @UserId=NULL, @SectionId = N'1,2,3,4,9,0', @ShiftCode = N'';
*/

CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_Query] 
    @FromDate  date, 
    @ToDate    date, 
    @UserId    varchar(max) = '', 
    @SectionId varchar(max) = '',
	@ShiftCode varchar(max) = ''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tblSection TABLE
    ( 
        SectionId int
    );

    IF LEN(ISNULL(@SectionId, '')) = 0
    BEGIN
        INSERT INTO @tblSection
               SELECT ResourceId
               FROM dbo.RefResource WITH (NOLOCK)
               WHERE RefName = 'Section';
        INSERT INTO @tblSection( SectionId )
        VALUES(0);
    END;
    ELSE
    BEGIN
        INSERT INTO @tblSection
        SELECT val
        FROM dbo.strSplit(@SectionId, ',');
    END;

    DECLARE @tblUser TABLE
    ( 
        UserId int
    );
    IF LEN(ISNULL(@UserId, '')) = 0
    BEGIN
        INSERT INTO @tblUser
               SELECT UserId
               FROM dbo.[User] AS u WITH (NOLOCK)
                    INNER JOIN
                    @tblSection AS s
                    ON ISNULL(u.SectionId, 0) = s.SectionId;
    END;
    ELSE
    BEGIN
        INSERT INTO @tblUser
        SELECT val
        FROM dbo.strSplit(@UserId, ',') u1
             INNER JOIN
             dbo.[User] AS u WITH (NOLOCK)
             ON u1.val = u.UserId
             INNER JOIN
             @tblSection s
             ON ISNULL(u.SectionId, 0) = s.SectionId
    END;

	DECLARE @tblShift TABLE
    ( 
        ShiftCode varchar(50)
    );
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

    SELECT s.EmployeeId, 
           s.ShiftCode, 
           s.ShiftDate, 
           ISNULL(u2.SectionId, 0) AS SectionId, 
           ISNULL(u2.Nickname, u2.Username) AS [Name], 
           u2.ProfilePic AS Avatar, 
           ISNULL(r.[Value], 'None') AS SectionName, 
           c.Background, 
           c.Color
    FROM dbo.EmployeeWorkingShift AS s WITH (NOLOCK)
         INNER JOIN @tblUser AS u1 ON s.EmployeeId = u1.UserId
		 INNER JOIN dbo.[User] AS u2 WITH (NOLOCK) ON s.EmployeeId = u2.UserId
		 INNER JOIN @tblShift sc ON s.ShiftCode = sc.ShiftCode
         LEFT JOIN dbo.RefResource AS r WITH (NOLOCK) ON r.RefName = 'Section' AND u2.SectionId = r.ResourceId
         LEFT JOIN dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK) ON s.ShiftCode = c.[Name]
    WHERE ShiftDate >= @FromDate AND ShiftDate <= @ToDate
    ORDER BY SectionName, [Name];

END;