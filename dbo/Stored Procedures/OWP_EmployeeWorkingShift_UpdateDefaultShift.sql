
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateDefaultShift] @Actor INT
	,@EmployeeId INT
	,@DefaultShiftIds VARCHAR(100)
	,@IsApplyCurrentWeek BIT
	,@FromDate DATE
	,@ToDate DATE
AS
/*    
 Created: 20190225@Leo.Vo
 Task : Update default working shift
 DB: bodb_OWP
 
Revisions:
	20190215@Leo.Vo: Initial SP - [Redmine: #108723]
	20190404@Leo.Vo: Add write log - [Redmine: #111068]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	DECLARE @tblDayOfTheWeek TABLE (DayOfTheWeek SMALLINT)
	DECLARE @DayOfTheWeek SMALLINT = 1
		,@OldDefaultShiftIds VARCHAR(100)

	WHILE @DayOfTheWeek <= 7
	BEGIN
		INSERT INTO @tblDayOfTheWeek (DayOfTheWeek)
		VALUES (@DayOfTheWeek)

		SET @DayOfTheWeek = @DayOfTheWeek + 1
	END

	SELECT @OldDefaultShiftIds = STUFF((
				SELECT ',' + ISNULL(CONVERT(VARCHAR(10), s.ShiftId), '')
				FROM @tblDayOfTheWeek AS w
					LEFT JOIN dbo.EmployeeWorkingShiftDefault AS s WITH (NOLOCK) ON w.DayOfTheWeek = s.DayOfTheWeek
					AND UserId = 26815597
				ORDER BY w.DayOfTheWeek ASC
				FOR XML PATH('')
				), 1, 1, '')

	CREATE TABLE #tblDefaultShift (
		DayOfTheWeek SMALLINT
		,ShiftId INT
		)

	INSERT INTO #tblDefaultShift (
		DayOfTheWeek
		,ShiftId
		)
	SELECT [rank]
		,val
	FROM dbo.strSplit(@DefaultShiftIds, ',')
	WHERE val IS NOT NULL

	-- update existed or insert if not existed when having update
	MERGE dbo.EmployeeWorkingShiftDefault AS t
	USING (
		SELECT DayOfTheWeek
			,ShiftId
		FROM #tblDefaultShift
		) AS s ON t.UserId = @EmployeeId
			AND t.DayOfTheWeek = s.DayOfTheWeek
	WHEN MATCHED
		AND t.ShiftId <> s.ShiftId THEN
			UPDATE
			SET t.ShiftId = s.ShiftId
	WHEN NOT MATCHED BY target THEN
			INSERT (
				UserId
				,DayOfTheWeek
				,ShiftId
				)
			VALUES (
				@EmployeeId
				,s.DayOfTheWeek
				,s.ShiftId
				);

	-- delete existed when not to have update
	DELETE t
	FROM dbo.EmployeeWorkingShiftDefault AS t WITH (ROWLOCK)
	WHERE t.UserId = @EmployeeId
		AND t.DayOfTheWeek NOT IN (
			SELECT DayOfTheWeek
			FROM #tblDefaultShift
			)

	IF @IsApplyCurrentWeek = 1
	BEGIN
		DECLARE @StartTime TIME(7)
			,@EndTime TIME(7)
			,@IsTimeShift BIT
			,@ShiftId INT
			,@ShiftStartTime DATETIME = NULL
			,@ShiftEndTime DATETIME = NULL
			,@ShiftDate DATE
			,@TimezoneOffset INT = dbo.[fnc_GetWorkingShiftTimezoneOffset](@Actor)
			,@ShiftStartHour INT

		SET @DayOfTheWeek = 1

		WHILE (@DayOfTheWeek <= 7)
		BEGIN
			SELECT @ShiftDate = DATEADD(DAY, @DayOfTheWeek - 1, @FromDate)
				,@ShiftId = NULL

			-- get default shift
			SELECT @StartTime = c.StartTime
				,@EndTime = c.EndTime
				,@IsTimeShift = c.IsTimeShift
				,@ShiftId = d.ShiftId
			FROM dbo.EmployeeWorkingShiftDefault AS d WITH (NOLOCK)
				INNER JOIN dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK) ON d.ShiftId = c.ShiftId
			WHERE d.UserId = @EmployeeId
				AND d.DayOfTheWeek = @DayOfTheWeek

			IF @ShiftId IS NULL
			BEGIN
				DELETE dbo.EmployeeWorkingShift WITH (ROWLOCK)
				WHERE EmployeeId = @EmployeeId
					AND ShiftDate = @ShiftDate
			END
			ELSE
			BEGIN
				SELECT @ShiftStartTime = NULL
					,@ShiftEndTime = NULL

				IF @IsTimeShift = 1
				BEGIN
					SELECT @ShiftStartTime = @ShiftDate + CAST(@StartTime AS DATETIME)
						,@ShiftEndTime = @ShiftDate + CAST(@EndTime AS DATETIME)

					SET @ShiftStartHour = DATEPART(HOUR, @StartTime) + @TimezoneOffset / 60

					IF @ShiftStartHour >= 1
						AND @ShiftStartHour < 7
					BEGIN
						SELECT @ShiftStartTime = DATEADD(DAY, 1, @ShiftStartTime)
							,@ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
					END

					IF @StartTime > @EndTime
					BEGIN
						SET @ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
					END
				END

				MERGE dbo.EmployeeWorkingShift AS t
				USING (
					SELECT @EmployeeId AS EmployeeId
						,@ShiftDate AS ShiftDate
						,@ShiftId AS ShiftId
						,@ShiftStartTime AS ShiftStartTime
						,@ShiftEndTime AS ShiftEndTime
					) AS s ON t.EmployeeId = s.EmployeeId
						AND t.ShiftDate = s.ShiftDate
				WHEN MATCHED
					AND (
						t.ShiftId <> s.ShiftId
						OR t.RefShiftId IS NOT NULL
						) THEN
						UPDATE
						SET t.ShiftId = s.ShiftId
							,t.ShiftStartTime = s.ShiftStartTime
							,t.ShiftEndTime = s.ShiftEndTime
							,t.RefShiftId = NULL
				WHEN NOT MATCHED BY target THEN
						INSERT (
							EmployeeId
							,ShiftId
							,ShiftDate
							,ShiftStartTime
							,ShiftEndTime
							)
						VALUES (
							s.EmployeeId
							,s.ShiftId
							,s.ShiftDate
							,s.ShiftStartTime
							,s.ShiftEndTime
							);
			END

			SET @DayOfTheWeek = @DayOfTheWeek + 1
		END
	END

	-- write log
	SET @Xml = (
			SELECT ISNULL(@EmployeeId, '') AS '@eid'
				,ISNULL(@OldDefaultShiftIds, '') AS '@sids'
				,'0' AS '@iacw'
				,ISNULL(@FromDate, '') AS '@fd'
				,ISNULL(@ToDate, '') AS '@td'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @Xml = (
			SELECT ISNULL(@EmployeeId, '') AS '@eid'
				,ISNULL(@DefaultShiftIds, '') AS '@sids'
				,ISNULL(@IsApplyCurrentWeek, '') AS '@iacw'
				,ISNULL(@FromDate, '') AS '@fd'
				,ISNULL(@ToDate, '') AS '@td'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @Actor
		,@SPName = 'OWP_EmployeeWorkingShift_UpdateDefaultShift'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @EmployeeId
		,@Data = @LogData
		,@DataOld = @LogDataOld

	DROP TABLE #tblDefaultShift
END