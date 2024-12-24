/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_API_SyncEmployeeWorkingShift] @LocationCode VARCHAR(10)
    ,@FromDate DATE
    ,@ToDate DATE
    ,@AllUserJson VARCHAR(MAX)
AS
/*
Created: 20241220@Tim
Task : API sync working shifts
DB: bodb_OWP

Revisions:
	20241220@Tim: initial - [Redmine: #215579]
*/
BEGIN
    SET NOCOUNT ON;

    DECLARE @tblAllUser TABLE (UserId INT NOT NULL, IsActive BIT);

    INSERT INTO @tblAllUser(UserId, IsActive)
    SELECT UserId, IsActive
    FROM OPENJSON(@AllUserJson) WITH(UserId INT, IsActive BIT);

     SELECT u.EmployeeId
        ,ew.ShiftDate
        ,UPPER(sc.ShiftCode) AS ShiftCode
        ,ew.ShiftStartTime
        ,ew.ShiftEndTime
        ,ew.LastUpdated
        ,sc.IsTimeShift
        ,sc.Extension
        ,CASE
            WHEN ew.RefShiftId = 190 -- Working OT shift
                OR ew.ShiftId = 190 -- Off shift
                OR ew.ShiftId = 293 -- Off (R) shift
            THEN 1
            ELSE 0
        END AS IsDayOff
        ,CASE
            WHEN ew.RefShiftId = 192
                OR ew.ShiftId = 192
            THEN 1
            ELSE 0
        END AS IsPublicHoliday
     FROM dbo.EmployeeWorkingShift AS ew WITH(NOLOCK)
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.UserId = ew.EmployeeId
        INNER JOIN @tblAllUser AS us ON us.UserId = u.UserId
        INNER JOIN dbo.EmployeeWorkingShiftPublish AS ewp WITH(NOLOCK) ON ew.ShiftDate BETWEEN ewp.FromDate AND ewp.ToDate
        AND ewp.SectionId = u.SectionId
        LEFT JOIN dbo.EmployeeWorkingShiftColor AS sc WITH(NOLOCK) ON ew.ShiftId = sc.ShiftId
     WHERE u.LocationCode = @LocationCode
        AND ew.ShiftDate BETWEEN @FromDate AND @ToDate
        AND ewp.IsPublished = 1
        AND us.IsActive = 1;
END