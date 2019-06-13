
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryWeeklyByUser] @UserIds VARCHAR(MAX)
	,@FromDate DATE
	,@ToDate DATE
AS
/*      
 Created: 20190204@leo.vo  
 Task : Working Shift Management
 DB: bodb_OWP      
 
 Revisions:
     20190204@leo.vo: Initial SP  - [Redmine: #111068]
	 20190522@Kane.Le: Select default shift  - [Redmine: #113763]
	 20190531@Leo.Vo: Refactor SP [Redmine: #114442]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @tblUser TABLE (UserId INT)

	INSERT INTO @tblUser (UserId)
	SELECT t.val
	FROM dbo.fnc_SplitStrings(@UserIds, ',') AS t
	OPTION (MAXRECURSION 0)

	SELECT u.UserId
		,ShiftId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,RefShiftId
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
		INNER JOIN @tblUser AS u ON ws.EmployeeId = u.UserId
	WHERE EmployeeId = u.UserId
		AND ShiftDate >= @FromDate
		AND ShiftDate <= @ToDate
END;