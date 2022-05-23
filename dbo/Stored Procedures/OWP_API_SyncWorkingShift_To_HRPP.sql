/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROC OWP_API_SyncWorkingShift_To_HRPP @FromDate DATE, 
                                        @ToDate   DATE

/*
Created: 20220523@Luca.Duong
Task: sync working shift to hrpp
DB: bodb_OWP

Revisions:
	20220523@Luca.Duong: get WorkingShift To HRPP - [Redmine: #172970]
*/

AS
    BEGIN
        SET NOCOUNT ON;
        SELECT ew.EmployeeId AS EmployeeID, 
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
               END AS IsDayOff
        FROM EmployeeWorkingShift ew
             INNER JOIN [User] u ON ew.EmployeeId = u.UserId
             INNER JOIN EmployeeWorkingShiftPublish AS ewp WITH(NOLOCK) ON ew.ShiftDate BETWEEN ewp.FromDate AND ewp.ToDate
                                                                           AND ewp.SectionId = u.SectionId
        WHERE u.LocationCode = N'CTI'
              AND ewp.IsPublished = 1
              AND CONVERT(DATE, ew.ShiftDate) BETWEEN @FromDate AND @ToDate
        ORDER BY ew.ShiftStartTime;
    END;