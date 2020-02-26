
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LSTReport_ListTraderWorkingShifts] @FromDate DATETIME = '2020-01-03', 
                                                               @ToDate   DATETIME = '2020-01-05'
AS

/*    
 Created: 20200205@Kane.Le
 Task : Caculate report MultipleMatches of LST Report
 DB: bodb_OWP    
    
 Revisions:
	20200226@Kane.Le: Initial SP - [Redmine: #124448]	
*/

     SET NOCOUNT ON;
     SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
     SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');
     SELECT DISTINCT 
            ws.EmployeeId AS UserId, 
            ws.ShiftDate, 
            ws.ShiftStartTime, 
            ws.ShiftEndTime
     FROM dbo.[EmployeeWorkingShift] ws WITH(NOLOCK)
          JOIN dbo.[EmployeeWorkingShiftColor] wsc WITH(NOLOCK) ON ws.ShiftId = wsc.ShiftId
                                                                   OR ws.ShiftId = ws.RefShiftId
     WHERE wsc.IsTimeShift = 1
           AND ws.ShiftDate BETWEEN @FromDate AND @ToDate
     ORDER BY UserId ASC;