
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_CopyWholeShifts] @ActorId INT
	,@FromUserId INT
	,@ToUserId INT
	,@FromDate DATE
	,@ToDate DATE
AS
/*      
 Created: 20190419@Lita.Tang
 Task : Copy whole shifts in week 
 DB: bodb_OWP  
   
Revisions:  
	20190419@Lita.Tang: Initial SP - [Redmine: #111840]  
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @tblFromUser TABLE (
		EmployeeId INT
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		,ShiftId INT
		,RefShiftId INT
		)
	DECLARE @tblToUser TABLE (
		EmployeeId INT
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		,ShiftId INT
		,RefShiftId INT
		)

	INSERT INTO @tblFromUser (
		EmployeeId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,ShiftId
		,RefShiftId
		)
	SELECT ws.EmployeeId
		,ws.ShiftDate
		,ws.ShiftStartTime
		,ws.ShiftEndTime
		,ws.ShiftId
		,ws.RefShiftId
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
	WHERE ws.EmployeeId = @FromUserId
		AND ws.ShiftDate BETWEEN @FromDate
			AND @ToDate

	INSERT INTO @tblToUser (
		EmployeeId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,ShiftId
		,RefShiftId
		)
	SELECT ws.EmployeeId
		,ws.ShiftDate
		,ws.ShiftStartTime
		,ws.ShiftEndTime
		,ws.ShiftId
		,ws.RefShiftId
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
	WHERE ws.EmployeeId = @ToUserId
		AND ws.ShiftDate BETWEEN @FromDate
			AND @ToDate

	-- delete current data of ToUser
	DELETE dbo.EmployeeWorkingShift WITH (ROWLOCK, UPDLOCK)
	WHERE EmployeeId = @ToUserId
		AND ShiftDate BETWEEN @FromDate
			AND @ToDate

	-- insert data from FromUser to ToUser
	INSERT INTO dbo.EmployeeWorkingShift (
		EmployeeId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,ShiftId
		,RefShiftId
		)
	SELECT @ToUserId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,ShiftId
		,RefShiftId
	FROM @tblFromUser
END