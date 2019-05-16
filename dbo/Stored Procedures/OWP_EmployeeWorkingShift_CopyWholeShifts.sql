
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
	20190514@Lita.Tang: Save data to DB when pasting Default shift - [Redmine: #112737] 
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
	
	DECLARE @GetCurrentWeek INT
		,@GetNextWeek INT	
		
	SELECT @GetCurrentWeek = DATEPART(wk, GETUTCDATE())	
	SELECT @GetNextWeek= DATEPART(wk,  DATEADD(dd, 0 - (@@DATEFIRST + 5 + DATEPART(dw, @FromDate)) % 7, @FromDate))

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
	
	---If in future week
	IF @GetNextWeek > @GetCurrentWeek
	BEGIN
		
		--create table date 
		declare @tblDays table (day_id int, [day] date)

		;with cte_day as
		(
		select @fromdate as [day]
		union all
		select dateadd(day, 1, [day])
		from cte_day
		where [day] < @todate
		)
		insert into @tblDays (day_id, [day])
		select
		row_number () over (order by [day] asc)
		,[day]

		from cte_day
		option (maxrecursion 0)

		SELECT * FROM @tblDays
		-- 
		DECLARE @tmpDefault TABLE  (UserId INT, ShiftId INT, ShiftDate DATE )
		INSERT INTO @tmpDefault (UserId,  ShiftId, ShiftDate)
		SELECT @FromUserId 
			, ISNULL(ds.ShiftId,0)
			, d.day
		FROM @tblDays AS d 
		LEFT JOIN dbo.EmployeeWorkingShiftDefault as ds WITH(NOLOCK)
				ON d.day_id = ds.DayOfTheWeek AND ds.UserId = @FromUserId 
		-----
		DECLARE @tmpWS TABLE (UserId INT, ShiftId INT, ShiftDate DATE, RefShiftId INT)
		INSERT INTO @tmpWS (UserId, ShiftId, ShiftDate,RefShiftId)
		SELECT t.UserId
		,ISNULL( ws.ShiftId, t.ShiftId)
		,t.ShiftDate
		, ISNULL(ws.RefShiftId,NULL ) 
		FROM  @tmpDefault AS t 
		LEFT JOIN dbo.EmployeeWorkingShift AS ws ON t.UserId = ws.EmployeeId AND t.ShiftDate = ws.ShiftDate

		--insert new data
		INSERT INTO	@tblNewWorkingShift (
		EmployeeId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,ShiftId
		,RefShiftId
		)
		SELECT @ToUserId
		,t.ShiftDate
		,t.ShiftDate + CAST(c.StartTime AS DATETIME)
		,t.ShiftDate + CAST(c.EndTime AS DATETIME)
		,t.ShiftId
		,t.RefShiftId
		FROM  @tmpWS AS t 
		INNER JOIN dbo.EmployeeWorkingShiftColor AS c ON c.ShiftId = t.ShiftId

		--update following Rule 1:00 -> 6:00 ( GMT+8)
		UPDATE @tblNewWorkingShift
		SET ShiftStartTime = DATEADD(DAY, 1, ShiftStartTime)	
			, ShiftEndTime = DATEADD(DAY, 1, ShiftEndTime)
		WHERE DATEPART(HOUR, ShiftStartTime) BETWEEN 1 AND 6

		UPDATE @tblNewWorkingShift
		SET ShiftEndTime = DATEADD(DAY, 1, ShiftEndTime)
		WHERE DATEPART(HOUR, ShiftStartTime) >DATEPART(HOUR, ShiftEndTime)
	END 
	ELSE ----in current week
	BEGIN 		
		INSERT INTO @tblNewWorkingShift(EmployeeId, ShiftDate, ShiftStartTime, ShiftEndTime, ShiftId, RefShiftId)
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
	END 
	
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
	SELECT EmployeeId, ShiftDate, ShiftStartTime, ShiftEndTime, ShiftId, RefShiftId
	FROM @tblNewWorkingShift 

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