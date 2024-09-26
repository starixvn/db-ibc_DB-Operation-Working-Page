
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE OWP_API_SyncWorkingShift_To_HRPP @FromDate DATE, 
                                                 @ToDate   DATE

/*
Created: 20220523@Luca.Duong
Task: sync working shift to hrpp
DB: bodb_OWP

Revisions:
	20220523@Luca.Duong: get WorkingShift To HRPP - [Redmine: #172970]
	20230810@Liam: get IsPublicHoliday - [Redmine: #191783]
	20230821@Liam: get correct IsPublicHoliday   - [Redmine: #192954]
*/

AS
    BEGIN
        SET NOCOUNT ON;
        --
        DECLARE @TEMP TABLE
        (EmployeeID      VARCHAR(30), 
         ScheduleDate    DATE, 
         ShiftStartTime  DATETIME, 
         ShiftEndTime    DATETIME, 
         LastUpdated     DATETIME, 
         IsDayOff        BIT, 
         IsPublicHoliday BIT, 
         RefShiftId      INT, 
         ShiftId         INT
        );
        --
        INSERT INTO @TEMP
               SELECT u.EmployeeId AS EmployeeID, 
                      ew.ShiftDate AS ScheduleDate, 
                      ew.ShiftStartTime, 
                      ew.ShiftEndTime, 
                      ew.LastUpdated,
                      CASE
                          WHEN ew.RefShiftId = 190 --Working OT shift
                               OR ew.ShiftId = 190 --Off shift
                               OR ew.ShiftId = 293 --Off (R) shift
                          THEN 1
                          ELSE 0
                      END AS IsDayOff,
                      CASE
                          WHEN ew.RefShiftId = 192
                               OR ew.ShiftId = 192
                          THEN 1
                          ELSE 0
                      END AS IsPublicHoliday, 
                      ew.RefShiftId, 
                      ew.ShiftId
               FROM EmployeeWorkingShift ew WITH(NOLOCK)
                    INNER JOIN [User] u WITH(NOLOCK) ON ew.EmployeeId = u.UserId
                    INNER JOIN EmployeeWorkingShiftPublish AS ewp WITH(NOLOCK) ON ew.ShiftDate BETWEEN ewp.FromDate AND ewp.ToDate
                                                                                  AND ewp.SectionId = u.SectionId
               WHERE u.LocationCode = N'CTI'
                     AND ewp.IsPublished = 1
                     AND CONVERT(DATE, ew.ShiftDate) BETWEEN @FromDate AND @ToDate
                     AND u.EmployeeId IS NOT NULL;
        --
        SELECT EmployeeID, 
               ScheduleDate, 
               ShiftStartTime, 
               ShiftEndTime, 
               LastUpdated, 
               IsDayOff, 
               IsPublicHoliday
        FROM @TEMP
        WHERE(ShiftStartTime IS NOT NULL
              AND ShiftEndTime IS NOT NULL)
             OR IsDayOff = 1
             OR IsPublicHoliday = 1;
    END;