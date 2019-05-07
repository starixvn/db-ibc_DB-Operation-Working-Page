
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

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	DECLARE @tblOldWorkingShift TABLE (
		EmployeeId INT
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		,ShiftId INT
		,RefShiftId INT
		)
	DECLARE @tblNewWorkingShift TABLE (
		EmployeeId INT
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		,ShiftId INT
		,RefShiftId INT
		)

	INSERT INTO @tblOldWorkingShift (
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
	OUTPUT inserted.EmployeeId
		,inserted.ShiftDate
		,inserted.ShiftStartTime
		,inserted.ShiftEndTime
		,inserted.ShiftId
		,inserted.RefShiftId
	INTO @tblNewWorkingShift(EmployeeId, ShiftDate, ShiftStartTime, ShiftEndTime, ShiftId, RefShiftId)
	SELECT @ToUserId
		,ws.ShiftDate
		,ws.ShiftStartTime
		,ws.ShiftEndTime
		,ws.ShiftId
		,ws.RefShiftId
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
	WHERE ws.EmployeeId = @FromUserId
		AND ws.ShiftDate BETWEEN @FromDate
			AND @ToDate

	-- write log
	SET @Xml = (
			SELECT EmployeeId AS '@eid'
				,ShiftDate AS '@sd'
				,ShiftStartTime AS '@st'
				,ShiftEndTime AS '@et'
				,ShiftId AS '@sid'
				,RefShiftId AS '@rsid'
			FROM @tblOldWorkingShift
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @Xml = (
			SELECT EmployeeId AS '@eid'
				,ShiftDate AS '@sd'
				,ShiftStartTime AS '@st'
				,ShiftEndTime AS '@et'
				,ShiftId AS '@sid'
				,RefShiftId AS '@rsid'
			FROM @tblNewWorkingShift
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShift_CopyWholeShifts'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @ToUserId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END