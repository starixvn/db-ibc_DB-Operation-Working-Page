


CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_CopySingleShift] @ActorId INT
	,@FromUserId INT  
	,@ToUserId INT  
	,@FromDate DATE
	,@ToDate DATE  

AS
/*      
 Created: 20190503@Lita.Tang
 Task : Copy single shift 
 DB: bodb_OWP  
   
Revisions:  
	20190419@Lita.Tang: Initial SP - [Redmine: #112737]  
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
		AND ws.ShiftDate = @ToDate
		
	-- delete current data of ToUser
	DELETE dbo.EmployeeWorkingShift WITH (ROWLOCK, UPDLOCK)
	WHERE EmployeeId = @ToUserId
		AND ShiftDate = @ToDate
	
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
		,@ToDate
		,@ToDate + CAST(c.StartTime AS DATETIME)
		,@ToDate + CAST(c.EndTime AS DATETIME)
		,ws.ShiftId
		,ws.RefShiftId
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
	INNER JOIN dbo.EmployeeWorkingShiftColor AS c WITH(NOLOCK) ON c.ShiftId = ws.ShiftId
	WHERE ws.EmployeeId = @FromUserId
		AND ws.ShiftDate = @FromDate

	-- SELECT TO OUTPUT
	SELECT TOP 1 ws.EmployeeId, ws.ShiftDate,  ws.ShiftId, ws.RefShiftId
	FROM EmployeeWorkingShift AS ws WITH (NOLOCK)
	WHERE ws.ShiftDate=@ToDate AND ws.EmployeeId=@ToUserId

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
		,@SPName = 'OWP_EmployeeWorkingShift_CopySingleShift'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @ToUserId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END