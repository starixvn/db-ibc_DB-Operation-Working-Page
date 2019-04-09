
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryWeeklyByUser] @EmployeeId INT
	,@FromDate DATE
	,@ToDate DATE
AS
/*      
 Created: 20190204@leo.vo  
 Task : Working Shift Management
 DB: bodb_OWP      
 
 Revisions:
     20190204@leo.vo: Initial SP  - [Redmine: #111068]
*/
BEGIN
	SET NOCOUNT ON;

	SELECT EmployeeId
		,ShiftId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,RefShiftId
	FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
	WHERE EmployeeId = @EmployeeId
		AND ShiftDate >= @FromDate
		AND ShiftDate <= @ToDate
END;