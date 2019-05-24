
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_CopySingleShift] @ActorId INT
	,@FromUserId INT
	,@ToUserId INT
	,@FromDate DATE
	,@ToDate DATE
	,@ShiftId INT
	,@RefShiftId INT = NULL
AS
/*      
 Created: 20190503@Lita.Tang
 Task : Copy single shift 
 DB: bodb_OWP  
   
Revisions:  
	20190419@Lita.Tang: Initial SP - [Redmine: #112737]  
	20190514@Lita.Tang: Save data to DB when pasting Default shift [Redmine: #112737]
	20190520@Kane.Le: Refactor SP [Redmine: #112737]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML
		,@OldEmployeeId INT
		,@OldShiftId INT
		,@OldRefShiftId INT
		,@OldShiftDate DATETIME
		,@OldShiftStartTime DATETIME
		,@OldShiftEndTime DATETIME
		,@NewEmployeeId INT
		,@NewShiftId INT
		,@NewRefShiftId INT
		,@NewShiftDate DATETIME
		,@NewShiftStartTime DATETIME
		,@NewShiftEndTime DATETIME

	SET @StartRun = GETDATE()

	-- select old data to write log
	SELECT TOP 1 @OldEmployeeId = @ToUserId
		,@OldShiftDate = @ToDate
		,@OldShiftStartTime = ws.ShiftStartTime
		,@OldShiftEndTime = ws.ShiftEndTime
		,@OldShiftId = ws.ShiftId
		,@OldRefShiftId = ws.RefShiftId
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
	WHERE ws.EmployeeId = @ToUserId
		AND ws.ShiftDate = @ToDate

	-- select new data to write log
	SELECT @NewShiftStartTime = st.ShiftStartTime
		,@NewShiftEndTime = st.ShiftEndTime
	FROM dbo.fnc_GetShiftTime(@ToDate, @ShiftId) AS st

	SELECT @NewEmployeeId = @ToUserId
		,@NewShiftDate = @ToDate
		,@NewShiftId = @ShiftId
		,@NewRefShiftId = @RefShiftId

	IF @OldEmployeeId = @NewEmployeeId
		AND @OldShiftId = @NewShiftId
		AND @OldShiftDate = @NewShiftDate
		AND @OldRefShiftId = @NewRefShiftId
	BEGIN
		-- SELECT TO OUTPUT	
		SELECT TOP 1 ws.EmployeeId
			,ws.ShiftDate
			,ws.ShiftId
			,ws.RefShiftId
		FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
		WHERE ws.ShiftDate = @ToDate
			AND ws.EmployeeId = @ToUserId

		RETURN
	END

	UPDATE dbo.EmployeeWorkingShift
	WITH (
			ROWLOCK
			,UPDLOCK
			)

	SET EmployeeId = @NewEmployeeId
		,ShiftDate = @NewShiftDate
		,ShiftStartTime = @NewShiftStartTime
		,ShiftEndTime = @NewShiftEndTime
		,ShiftId = @NewShiftId
		,RefShiftId = @NewRefShiftId
	WHERE EmployeeId = @OldEmployeeId
		AND ShiftId = @OldShiftId
		AND ShiftDate = @OldShiftDate

	IF @@ROWCOUNT = 0
	BEGIN
		--- insert data from FromUser to ToUser
		INSERT INTO dbo.EmployeeWorkingShift (
			EmployeeId
			,ShiftDate
			,ShiftStartTime
			,ShiftEndTime
			,ShiftId
			,RefShiftId
			)
		VALUES (
			@NewEmployeeId
			,@NewShiftDate
			,@NewShiftStartTime
			,@NewShiftEndTime
			,@NewShiftId
			,@NewRefShiftId
			)
	END

	-- SELECT TO OUTPUT	
	SELECT TOP 1 ws.EmployeeId
		,ws.ShiftDate
		,ws.ShiftId
		,ws.RefShiftId
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
	WHERE ws.ShiftDate = @ToDate
		AND ws.EmployeeId = @ToUserId

	-- write log
	SET @Xml = (
			SELECT @OldEmployeeId AS '@eid'
				,@OldShiftDate AS '@sd'
				,@OldShiftStartTime AS '@st'
				,@OldShiftEndTime AS '@et'
				,@OldShiftId AS '@sid'
				,@OldRefShiftId AS '@rsid'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @Xml = (
			SELECT @NewEmployeeId AS '@eid'
				,@NewShiftDate AS '@sd'
				,@NewShiftStartTime AS '@st'
				,@NewShiftEndTime AS '@et'
				,@NewShiftId AS '@sid'
				,@NewRefShiftId AS '@rsid'
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