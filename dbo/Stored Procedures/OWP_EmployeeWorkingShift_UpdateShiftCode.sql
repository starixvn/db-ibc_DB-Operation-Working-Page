
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateShiftCode] @ActorId INT
	,@EmployeeId INT
	,@ShiftId INT
	,@ShiftDate DATE
	,@IsOvertime BIT = 0
AS
/*    
 Created: 20180914@Kane.Le
 Task : Edit working shift by date
 DB: bodb_OWP
 
Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
	20190215@Leo.Vo: Init default shift - [Redmine: #108723]
	20190312@Leo.Vo: Add overtime - [Redmine: #109560]
	20190409@Raymond.Le: Correct rule ShiftCode GMT+8 - [Redmine: #111068]
	20190515@Kane.Le: Change follow assign shift in next week - [Redmine: #112737]
	20190520@Leo.Vo: Write log - [Redmine: #113763]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartTime TIME(7)
		,@EndTime TIME(7)
		,@IsTimeShift BIT
		,@ShiftStartTime DATETIME
		,@ShiftEndTime DATETIME
		,@StartDate DATE
		,@EndDate DATE
		,@DayOfTheWeek INT
		,@IsJoinDefaultShift BIT
		,@GetCurrentWeek INT
		,@GetNextWeek INT
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
		,@OldIsOvertime BIT
		,@RefShiftId INT

	SET @StartRun = GETDATE()

	SELECT @OldShiftId = ShiftId
		,@OldShiftStartTime = ShiftStartTime
		,@OldShiftEndTime = ShiftEndTime
		,@OldRefShiftId = RefShiftId
		,@OldIsOvertime = (CASE 
			WHEN RefShiftId IS NULL THEN 0
			ELSE 1 END
			)
	FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
	WHERE EmployeeId = @EmployeeId
		AND ShiftDate = @ShiftDate

	SELECT @GetCurrentWeek = DATEPART(wk, GETUTCDATE())

	SELECT @GetNextWeek = DATEPART(wk, DATEADD(dd, 0 - (@@DATEFIRST + 5 + DATEPART(dw, @ShiftDate)) % 7, @ShiftDate))

	IF @GetNextWeek > @GetCurrentWeek
	BEGIN
		SET @IsJoinDefaultShift = 1
	END
	ELSE
	BEGIN
		SET @IsJoinDefaultShift = 0
	END

	DECLARE @DateOfWeek INT = 1
	DECLARE @TallyShiftDate AS TABLE (ShiftDate DATE)
	DECLARE @FromDate DATETIME = DATEADD(WEEK, DATEDIFF(DAY, 0, @ShiftDate) / 7, 0)
	DECLARE @ToDate DATETIME = DATEADD(WEEK, DATEDIFF(DAY, 0, @ShiftDate) / 7, 6)

	CREATE TABLE #tmpEmployeeWorkingShiftDefault (
		UserId INT
		,DateOfWeek INT
		,ShiftId INT
		,ShiftDate DATE
		);

	SELECT @StartTime = StartTime
		,@EndTime = EndTime
		,@IsTimeShift = IsTimeShift
	FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
	WHERE ShiftId = @ShiftId

	SELECT @ShiftStartTime = ShiftStartTime
		,@ShiftEndTime = ShiftEndTime
	FROM dbo.fnc_GetShiftTime(@ShiftDate, @ShiftId)

	SELECT @StartDate = StartDate
		,@EndDate = EndDate
	FROM dbo.fnc_CheckToInitDefaultShiftWeekly(@EmployeeId, @ShiftDate)

	IF @OldShiftId IS NOT NULL
	BEGIN
		IF @IsOvertime = 1
			SET @RefShiftId = @OldShiftId

		UPDATE dbo.EmployeeWorkingShift WITH (ROWLOCK)
		SET RefShiftId = (CASE 
				WHEN @IsOvertime = 1 THEN CASE 
						WHEN RefShiftId IS NULL THEN ShiftId
						ELSE RefShiftId
						END
				ELSE NULL END
				)
			,ShiftId = @ShiftId
			,ShiftStartTime = @ShiftStartTime
			,ShiftEndTime = @ShiftEndTime
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate = @ShiftDate
	END
	ELSE
	BEGIN
		IF @IsJoinDefaultShift = 1
			AND @IsOvertime = 1
		BEGIN
			SET DATEFIRST 1;

			WITH cte
			AS (
				SELECT [rn] = ROW_NUMBER() OVER (
						ORDER BY (
								SELECT NULL
								)
						) - 1
				FROM (
					VALUES (0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
					) x10(n)
				)
			INSERT INTO @TallyShiftDate (ShiftDate)
			SELECT [ShiftDate] = DATEADD(DAY, cte.rn, @FromDate)
			FROM cte
			WHERE cte.rn <= DATEDIFF(DAY, @FromDate, @ToDate)

			INSERT INTO #tmpEmployeeWorkingShiftDefault
			SELECT u.UserId
				,ep.DayOfTheWeek
				,[ShiftId] = ISNULL(ep.ShiftId, 0)
				,tally.ShiftDate
			FROM @TallyShiftDate AS tally
				CROSS JOIN dbo.[User] AS u WITH (NOLOCK)
				LEFT JOIN dbo.EmployeeWorkingShiftDefault AS ep ON ep.DayOfTheWeek = DATEPART(WEEKDAY, tally.ShiftDate)
				AND u.UserId = ep.UserId
			WHERE u.UserId = @EmployeeId

			SELECT @RefShiftId = tmp.ShiftId
			FROM #tmpEmployeeWorkingShiftDefault AS tmp
			WHERE tmp.ShiftDate = @ShiftDate
				AND tmp.UserId = @EmployeeId
		END

		INSERT INTO dbo.EmployeeWorkingShift (
			EmployeeId
			,ShiftId
			,ShiftDate
			,ShiftStartTime
			,ShiftEndTime
			,RefShiftId
			)
		VALUES (
			@EmployeeId
			,@ShiftId
			,@ShiftDate
			,@ShiftStartTime
			,@ShiftEndTime
			,@RefShiftId
			);
	END

	IF @IsJoinDefaultShift = 1
	BEGIN
		SET DATEFIRST 1;

		WITH cte
		AS (
			SELECT [rn] = ROW_NUMBER() OVER (
					ORDER BY (
							SELECT NULL
							)
					) - 1
			FROM (
				VALUES (0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
					,(0)
				) x10(n)
			)
		INSERT INTO @TallyShiftDate (ShiftDate)
		SELECT [ShiftDate] = DATEADD(DAY, cte.rn, @FromDate)
		FROM cte
		WHERE cte.rn <= DATEDIFF(DAY, @FromDate, @ToDate)

		TRUNCATE TABLE #tmpEmployeeWorkingShiftDefault

		INSERT INTO #tmpEmployeeWorkingShiftDefault
		SELECT u.UserId
			,ep.DayOfTheWeek
			,[ShiftId] = ISNULL(ep.ShiftId, 0)
			,tally.ShiftDate
		FROM @TallyShiftDate AS tally
			CROSS JOIN dbo.[User] AS u WITH (NOLOCK)
			LEFT JOIN dbo.EmployeeWorkingShiftDefault AS ep WITH (NOLOCK) ON ep.DayOfTheWeek = DATEPART(WEEKDAY, tally.ShiftDate)
			AND u.UserId = ep.UserId
		WHERE u.UserId = @EmployeeId

		SELECT [EmployeeId] = df.UserId
			,[ShiftDate] = df.ShiftDate
			,[ShiftStartTime] = ISNULL(wk.ShiftStartTime, df.ShiftDate + CAST(wsc.StartTime AS DATETIME))
			,[ShiftEndTime] = ISNULL(wk.ShiftEndTime, df.ShiftDate + CAST(wsc.EndTime AS DATETIME))
			,[ShiftId] = ISNULL(wk.ShiftId, df.ShiftId)
			,[RefShiftId] = wk.RefShiftId
			,[IsDefaultShift] = CASE 
				WHEN wk.ShiftId IS NULL THEN 1
				ELSE 0
				END
		FROM #tmpEmployeeWorkingShiftDefault AS df WITH (NOLOCK)
			LEFT JOIN dbo.EmployeeWorkingShiftColor AS wsc WITH (NOLOCK) ON df.ShiftId = wsc.ShiftId
			LEFT JOIN dbo.EmployeeWorkingShift AS wk WITH (NOLOCK) ON df.UserId = wk.EmployeeId
			AND df.ShiftDate = wk.ShiftDate
	END
	ELSE
	BEGIN
		SELECT EmployeeId
			,ShiftId
			,ShiftDate
			,RefShiftId
			,[IsDefaultShift] = 0
		FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate BETWEEN @StartDate
				AND @EndDate
	END

	-- write log
	SET @Xml = (
			SELECT @EmployeeId AS '@eid'
				,@ShiftDate AS '@sd'
				,@OldShiftStartTime AS '@st'
				,@OldShiftEndTime AS '@et'
				,@OldShiftId AS '@sid'
				,@OldRefShiftId AS '@rsid'
				,@OldIsOvertime AS '@iot'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @Xml = (
			SELECT @EmployeeId AS '@eid'
				,@ShiftDate AS '@sd'
				,@ShiftStartTime AS '@st'
				,@ShiftEndTime AS '@et'
				,@ShiftId AS '@sid'
				,@RefShiftId AS '@rsid'
				,@IsOvertime AS '@iot'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShift_UpdateShiftCode'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @EmployeeId
		,@Data = @LogData
		,@DataOld = @LogDataOld

	SET DATEFIRST 7

	DROP TABLE #tmpEmployeeWorkingShiftDefault
END