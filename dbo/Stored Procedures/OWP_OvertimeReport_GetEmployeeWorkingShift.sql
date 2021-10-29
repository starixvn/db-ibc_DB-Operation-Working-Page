
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

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
               c.StartTime, 
               c.EndTime, 
               c.[ShiftId], 
               w.RefShiftId, 
               c.Extension
        FROM [bodb_OWP].[dbo].[EmployeeWorkingShift] w WITH(NOLOCK)
             INNER JOIN dbo.EmployeeWorkingShiftColor c WITH(NOLOCK) ON c.ShiftId = w.ShiftId
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = w.EmployeeId
        WHERE ShiftDate = @EventDate
              AND c.IsTimeShift = 1
              AND c.StartTime IS NOT NULL
              AND c.EndTime IS NOT NULL
        --AND u.SectionId IN(@SecionLiveTradingPH, @SecionLiveTradingVN);
    END;