
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Task_OWP_SyncDefaultWorkingShift]
	@CurrentDate DATETIME = NULL,
	@SectionId INT=NULL,
	@ActorId INT = 0
AS
/*
Created: 20190213@Raymond.Le
Task : Auto insert default shift data to table EmployeeWorkingShift
DB: bodb_OWP

Revisions:
	20190213@Raymond.Le: Initial SP - [Redmine: #108723]
	20190409@Raymond.Le: Correct rule GMT+8 ShiftCode - [Redmine: #111068]
	20190513@Leo.Vo: Change rule get default shift - [Redmine: #112737]
	20190520@Leo.Vo: Write log - [Redmine: #113763]
	20191003@Leo.Vo: Add WS extension - [Redmine: #121272]
	20191025@Carlos.Nguyen: Manual public working shift - [Redmine: #122661]
	20200529@Tyler.Dang: Change week from Tuesday to next Monday - [Redmine: #134337]	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @CurrentDateGMTplus8 DATETIME
		,@NextWeekStartDate DATE
		,@NextWeekEndDate DATE
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@ActionId INT
		,@Extension_Real INT = 1
		,@Extension_Special INT = 2

	SET @StartRun = GETDATE()
	SET @CurrentDate = ISNULL(@CurrentDate, GETDATE())
	SET @CurrentDateGMTplus8 = DATEADD(HOUR, 12, @CurrentDate)
	SET @NextWeekStartDate = DATEADD(DAY, 7 + 3 - DATEPART(WEEKDAY, @CurrentDateGMTplus8), CAST(@CurrentDateGMTplus8 AS DATE))
	SET @NextWeekEndDate = DATEADD(DAY, 6, @NextWeekStartDate)

	CREATE TABLE #tblDefaultWorkingShift (
		UserId INT
		,ShiftId INT
		,ShiftDate DATE
		,ShiftStartDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndDate DATE
		,ShiftEndTime DATETIME
		,IsTimeShift BIT
		,Extension INT
		)

	CREATE TABLE #tblInsertWorkingShift (
		EmployeeId INT
		,ShiftId INT
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		,RefShiftId INT
		)

	CREATE TABLE #tblUserLog (
		UserId INT
		,LogData NVARCHAR(MAX)
		)

	-- Insert default working shift from Tuesday to Monday for all user (must ignore disable... user)
	INSERT INTO #tblDefaultWorkingShift (
		UserId
		,ShiftId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,IsTimeShift
		,Extension
		)
	SELECT u.UserId
		,ds.ShiftId
		,CASE 
			WHEN ds.DayOfTheWeek = 1 THEN @NextWeekEndDate
			WHEN ds.DayOfTheWeek = 2 THEN @NextWeekStartDate
			WHEN ds.DayOfTheWeek = 3 THEN DATEADD(DAY, 1, @NextWeekStartDate)
			WHEN ds.DayOfTheWeek = 4 THEN DATEADD(DAY, 2, @NextWeekStartDate)
			WHEN ds.DayOfTheWeek = 5 THEN DATEADD(DAY, 3, @NextWeekStartDate)
			WHEN ds.DayOfTheWeek = 6 THEN DATEADD(DAY, 4, @NextWeekStartDate)
			WHEN ds.DayOfTheWeek = 7 THEN DATEADD(DAY, 5, @NextWeekStartDate)
			END AS ShiftDate
		,sc.StartTime
		,sc.EndTime
		,sc.IsTimeShift
		,sc.Extension
	FROM dbo.[User] AS u WITH (NOLOCK)
		INNER JOIN dbo.EmployeeWorkingShiftDefault AS ds WITH (NOLOCK) ON u.UserId = ds.UserId
		LEFT JOIN dbo.EmployeeWorkingShiftColor AS sc WITH (NOLOCK) ON ds.ShiftId = sc.ShiftId
	WHERE (@SectionId IS NULL OR u.SectionId=@SectionId)

	--Update shift start date
	UPDATE ds WITH (ROWLOCK, UPDLOCK)
	SET ds.ShiftStartDate = CASE ds.Extension
		WHEN @Extension_Real THEN ds.ShiftDate
		WHEN @Extension_Special THEN DATEADD(DAY, 1, ds.ShiftDate)
		ELSE CASE 
			WHEN DATEPART(HOUR, ds.ShiftStartTime) BETWEEN 0
					AND 6 THEN DATEADD(DAY, 1, ds.ShiftDate)
			ELSE ds.ShiftDate
			END
		END
	FROM #tblDefaultWorkingShift AS ds
	WHERE ds.IsTimeShift = 1

	--Update shift end date
	UPDATE ds WITH (ROWLOCK, UPDLOCK)
	SET ds.ShiftEndDate = CASE 
			WHEN DATEPART(HOUR, ds.ShiftEndTime) < DATEPART(HOUR, ds.ShiftStartTime) THEN DATEADD(DAY, 1, ds.ShiftStartDate)
			ELSE ds.ShiftStartDate
			END
	FROM #tblDefaultWorkingShift AS ds
	WHERE ds.IsTimeShift = 1

	INSERT INTO dbo.EmployeeWorkingShift (
		EmployeeId
		,ShiftId
		,ShiftDate
		,ShiftStartTime
		,ShiftEndTime
		,LastUpdated
		)
	OUTPUT inserted.EmployeeId
		,inserted.ShiftId
		,inserted.ShiftDate
		,inserted.ShiftStartTime
		,inserted.ShiftEndTime
	INTO #tblInsertWorkingShift(EmployeeId, ShiftId, ShiftDate, ShiftStartTime, ShiftEndTime)
	SELECT ds.UserId
		,ds.ShiftId
		,ds.ShiftDate
		,ds.ShiftStartDate + ds.ShiftStartTime
		,ds.ShiftEndDate + ds.ShiftEndTime
		,DATEADD(HOUR, 12, GETDATE())
	FROM #tblDefaultWorkingShift AS ds WITH (NOLOCK)
	WHERE ds.IsTimeShift = 1
		AND NOT EXISTS (
			SELECT 1
			FROM dbo.EmployeeWorkingShift AS s WITH (NOLOCK)
			WHERE s.EmployeeId = ds.UserId
				AND s.ShiftDate = ds.ShiftDate
			)
	
	UNION
	SELECT ds.UserId
		,ds.ShiftId
		,ds.ShiftDate
		,NULL
		,NULL
		,DATEADD(HOUR, 12, GETDATE())
	FROM #tblDefaultWorkingShift AS ds WITH (NOLOCK)
	WHERE ds.IsTimeShift = 0
		AND NOT EXISTS (
			SELECT 1
			FROM dbo.EmployeeWorkingShift AS s WITH (NOLOCK)
			WHERE s.EmployeeId = ds.UserId
				AND s.ShiftDate = ds.ShiftDate
			)

	-- write log
	INSERT INTO #tblUserLog (UserId)
	SELECT DISTINCT EmployeeId
	FROM #tblInsertWorkingShift

	UPDATE ul
	SET LogData = REPLACE(CONVERT(NVARCHAR(MAX), (
					SELECT s.EmployeeId AS '@eid'
						,s.ShiftDate AS '@sd'
						,s.ShiftId AS '@sid'
						,s.ShiftStartTime AS '@sst'
						,s.ShiftEndTime AS '@set'
					FROM #tblInsertWorkingShift AS s
					WHERE ul.UserId = s.EmployeeId
					ORDER BY s.ShiftDate ASC
					FOR XML PATH('z')
						,ROOT('r')
					)), '" />', '"/"')
	FROM #tblUserLog AS ul

	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	SELECT @ActionId = ActionId
	FROM dbo.LogAction WITH (NOLOCK)
	WHERE SPName = 'Task_OWP_SyncDefaultWorkingShift'

	INSERT INTO dbo.UserLog (
		CreatorId
		,LoggedDate
		,ObjectId
		,ActionId
		,Duration
		,Data
		,DataOld
		)
	SELECT @ActorId
		,@StartRun
		,UserId
		,@ActionId
		,@Duration
		,LogData
		,NULL
		
	FROM #tblUserLog
	
	DROP TABLE #tblDefaultWorkingShift

	DROP TABLE #tblInsertWorkingShift

	DROP TABLE #tblUserLog
END