
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_EmployeeWorkingShift_CopyWeekly] @ActorId INT
	,@UserId INT
	,@StartDateOfWeek DATE
AS
/*
Created: 20180913@Leo
Task : clone week from previous
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181126@Kane.Le: Select Column SectionId for check permisson [Redmine: #105043]
	20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
	20190215@Leo.Vo: Change output result - [Redmine: #108723]
	20190312@Leo.Vo: Add overtime - [Redmine: #109560]
	20190520@Leo.Vo: Write log - [Redmine: #113763]
	20190531@Leo.Vo: Refactor SP [Redmine: #114442]
	20210608@Carlos.nguyen: Insert lastupdate => API sync Working Shifts to HRM - [Redmine: #156338]	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @PreviousFromDate DATE = DATEADD(DAY, - 7, @StartDateOfWeek)
	DECLARE @PreviousToDate DATE = DATEADD(DAY, - 1, @StartDateOfWeek)
	DECLARE @CurrentFromDate DATE = @StartDateOfWeek
	DECLARE @CurrentToDate DATE = DATEADD(DAY, 6, @StartDateOfWeek)
	DECLARE @CopyWorkingShift TABLE (
		EmployeeId INT
		,ShiftId INT
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		,RefShiftId INT
		,LastUpdated DATETIME
		)
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT EmployeeId AS '@eid'
				,ShiftDate AS '@sd'
				,ShiftId AS '@sid'
				,ShiftStartTime AS '@sst'
				,ShiftEndTime AS '@set'
				,RefShiftId AS '@rsid'
			FROM dbo.EmployeeWorkingShift WITH (ROWLOCK)
			WHERE EmployeeId = @UserId
				AND ShiftDate >= @CurrentFromDate
				AND ShiftDate <= @CurrentToDate
			ORDER BY ShiftDate ASC
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	-- get working shift need to be copied
	INSERT INTO @CopyWorkingShift
	SELECT EmployeeId
		,ShiftId
		,DATEADD(DAY, 7, ShiftDate) AS ShiftDate
		,DATEADD(DAY, 7, ShiftStartTime) AS ShiftStartTime
		,DATEADD(DAY, 7, ShiftEndTime) AS ShiftEndTime
		,RefShiftId
		,LastUpdated =  DATEADD(HOUR, 12, GETDATE())
	FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
	WHERE EmployeeId = @UserId
		AND ShiftDate >= @PreviousFromDate
		AND ShiftDate <= @PreviousToDate

	-- delete current working shift
	DELETE dbo.EmployeeWorkingShift WITH (ROWLOCK)
	WHERE EmployeeId = @UserId
		AND ShiftDate >= @CurrentFromDate
		AND ShiftDate <= @CurrentToDate

	MERGE INTO dbo.EmployeeWorkingShift AS t
	USING (
		SELECT EmployeeId
			,ShiftId
			,ShiftDate
			,ShiftStartTime
			,ShiftEndTime
			,RefShiftId
			,LastUpdated
		FROM @CopyWorkingShift
		) AS s ON s.EmployeeId = t.EmployeeId
			AND s.ShiftDate = t.ShiftDate
	WHEN MATCHED THEN
			UPDATE
			SET t.ShiftId = s.ShiftId
				,t.ShiftStartTime = s.ShiftStartTime
				,t.ShiftEndTime = s.ShiftEndTime
				,t.RefShiftId = s.RefShiftId
				,t.LastUpdated=s.LastUpdated
	WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				EmployeeId
				,ShiftId
				,ShiftDate
				,ShiftStartTime
				,ShiftEndTime
				,RefShiftId
				,LastUpdated
				)
			VALUES (
				s.EmployeeId
				,s.ShiftId
				,s.ShiftDate
				,s.ShiftStartTime
				,s.ShiftEndTime
				,s.RefShiftId
				,s.LastUpdated
				);

	-- write log
	SET @Xml = (
			SELECT EmployeeId AS '@eid'
				,ShiftDate AS '@sd'
				,ShiftId AS '@sid'
				,ShiftStartTime AS '@sst'
				,ShiftEndTime AS '@set'
				,RefShiftId AS '@rsid'
			FROM @CopyWorkingShift
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShift_CopyWeekly'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @UserId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END