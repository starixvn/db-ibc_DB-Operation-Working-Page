
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OvertimeReport_GetEmployeeWorkingShift] @EventDate DATETIME
AS

/*    
Created: 20211014@Tyler
Task : Overtime Report
DB: bodb_OWP

Revisions:
	20211014@Tyler: init sp - [Redmine: #162821]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @SecionLiveTradingVN INT= 3, @SecionLiveTradingPH INT= 28;
        SELECT w.[EmployeeId], 
               [ShiftDate], 
               w.ShiftStartTime, 
               w.ShiftEndTime, 
               w.RefShiftId
        FROM [bodb_OWP].[dbo].[EmployeeWorkingShift] w WITH(NOLOCK)
             INNER JOIN dbo.EmployeeWorkingShiftColor c WITH(NOLOCK) ON c.ShiftId = w.ShiftId
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = w.EmployeeId
        WHERE ShiftDate = @EventDate
              AND c.IsTimeShift = 1
              AND w.ShiftStartTime IS NOT NULL
              AND w.ShiftEndTime IS NOT NULL
              AND u.SectionId IN(@SecionLiveTradingPH, @SecionLiveTradingVN);
    END;