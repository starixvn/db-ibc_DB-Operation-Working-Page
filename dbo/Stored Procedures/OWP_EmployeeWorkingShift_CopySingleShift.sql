
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_EmployeeWorkingShift_CopySingleShift] @ActorId INT
	,@UserId INT
	,@ShiftDate DATE
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
	20190531@Leo.Vo: Refactor SP [Redmine: #114442]
	20210608@Carlos.nguyen: Insert lastupdate => API sync Working Shifts to HRM - [Redmine: #156338]	
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML
		,@OldShiftId INT
		,@OldRefShiftId INT
		,@OldShiftStartTime DATETIME
		,@OldShiftEndTime DATETIME
		,@ShiftStartTime DATETIME
		,@ShiftEndTime DATETIME

	SET @StartRun = GETDATE()

	-- select old data to write log
	SELECT @OldShiftStartTime = ws.ShiftStartTime
		,@OldShiftEndTime = ws.ShiftEndTime
		,@OldShiftId = ws.ShiftId
		,@OldRefShiftId = ws.RefShiftId
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
	WHERE ws.EmployeeId = @UserId
		AND ws.ShiftDate = @ShiftDate

	-- select new data to write log
	SELECT @ShiftStartTime = st.ShiftStartTime
		,@ShiftEndTime = st.ShiftEndTime
	FROM dbo.fnc_GetShiftTime(@ShiftDate, @ShiftId) AS st

	IF @OldShiftId IS NULL
	BEGIN
		INSERT INTO dbo.EmployeeWorkingShift (
			EmployeeId
			,ShiftDate
			,ShiftStartTime
			,ShiftEndTime
			,ShiftId
			,RefShiftId
			,LastUpdated
			)
		VALUES (
			@UserId
			,@ShiftDate
			,@ShiftStartTime
			,@ShiftEndTime
			,@ShiftId
			,@RefShiftId
			,DATEADD(HOUR, 12, GETDATE())
			)
	END
	ELSE
	BEGIN
		UPDATE dbo.EmployeeWorkingShift WITH (ROWLOCK, UPDLOCK)
		SET ShiftStartTime = @ShiftStartTime
			,ShiftEndTime = @ShiftEndTime
			,ShiftId = @ShiftId
			,RefShiftId = @RefShiftId
			,LastUpdated = DATEADD(HOUR, 12, GETDATE())
		WHERE EmployeeId = @UserId
			AND ShiftDate = @ShiftDate
	END

	-- write log
	SET @Xml = (
			SELECT @UserId AS '@eid'
				,@ShiftDate AS '@sd'
				,@OldShiftStartTime AS '@st'
				,@OldShiftEndTime AS '@et'
				,@OldShiftId AS '@sid'
				,@OldRefShiftId AS '@rsid'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @Xml = (
			SELECT @UserId AS '@eid'
				,@ShiftDate AS '@sd'
				,@ShiftStartTime AS '@st'
				,@ShiftEndTime AS '@et'
				,@ShiftId AS '@sid'
				,@RefShiftId AS '@rsid'
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
		,@ObjectId = @UserId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END