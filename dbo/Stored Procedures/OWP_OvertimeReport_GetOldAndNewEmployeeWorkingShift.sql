
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OvertimeReport_GetOldAndNewEmployeeWorkingShift] @EventDate DATETIME
AS

/*    
Created: 20220816@Mira
Task : Overtime Report
DB: bodb_OWP

Revisions:
	20220816@Mira: Get old, new data for re-generate data - [Redmine: #176629]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @SecionLiveTradingVN INT= 3, @SecionLiveTradingPH INT= 28;

        -- Select new working shift
        SELECT w.EmployeeId, 
               w.ShiftDate, 
               w.ShiftStartTime, 
               w.ShiftEndTime, 
               w.RefShiftId
        FROM dbo.EmployeeWorkingShift w WITH(NOLOCK)
             INNER JOIN dbo.EmployeeWorkingShiftColor c WITH(NOLOCK) ON c.ShiftId = w.ShiftId
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = w.EmployeeId
        WHERE ShiftDate = @EventDate
              AND c.IsTimeShift = 1
              AND w.ShiftStartTime IS NOT NULL
              AND w.ShiftEndTime IS NOT NULL
              AND u.SectionId IN(@SecionLiveTradingPH, @SecionLiveTradingVN)

        -- Select old working shift
        UNION
        SELECT w.EmployeeId, 
               w.ShiftDate, 
               w.ShiftStartTime, 
               w.ShiftEndTime, 
               w.RefShiftId
        FROM dbo.EmployeeWorkingShift_Old w WITH(NOLOCK)
             INNER JOIN dbo.EmployeeWorkingShiftColor c WITH(NOLOCK) ON c.ShiftId = w.ShiftId
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = w.EmployeeId
        WHERE ShiftDate = @EventDate
              AND c.IsTimeShift = 1
              AND w.ShiftStartTime IS NOT NULL
              AND w.ShiftEndTime IS NOT NULL
              AND u.SectionId IN(@SecionLiveTradingPH, @SecionLiveTradingVN);
    END;