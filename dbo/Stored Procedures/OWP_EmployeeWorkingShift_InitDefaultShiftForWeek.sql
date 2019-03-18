
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_InitDefaultShiftForWeek] @EmployeeId INT
	,@StartDate DATE
	,@EndDate DATE
AS
/*    
 Created: 20190215@Leo.Vo
 Task : Init default shift for week
 DB: bodb_OWP
 
Revisions:
	20190215@Leo.Vo: Initial SP - [Redmine: #108723]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartTime TIME(7)
		,@EndTime TIME(7)
		,@IsTimeShift BIT
		,@ShiftId INT
		,@ShiftStartTime DATETIME = NULL
		,@ShiftEndTime DATETIME = NULL
		,@DayOfTheWeek INT
		,@ShiftDate DATE

	SET @DayOfTheWeek = 1

	WHILE (@DayOfTheWeek <= 7)
	BEGIN
		SET @ShiftDate = DATEADD(DAY, @DayOfTheWeek - 1, @StartDate)

		SELECT @StartTime = c.StartTime
			,@EndTime = c.EndTime
			,@IsTimeShift = c.IsTimeShift
			,@ShiftId = d.ShiftId
		FROM dbo.EmployeeWorkingShiftDefault AS d WITH (NOLOCK)
			INNER JOIN dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK) ON d.ShiftId = c.ShiftId
		WHERE d.UserId = @EmployeeId
			AND d.DayOfTheWeek = @DayOfTheWeek

		IF (@@ROWCOUNT = 1)
		BEGIN
			IF @IsTimeShift = 1
			BEGIN
				SELECT @ShiftStartTime = @ShiftDate + CAST(@StartTime AS DATETIME)
					,@ShiftEndTime = @ShiftDate + CAST(@EndTime AS DATETIME)

				IF DATEPART(HOUR, @StartTime) < 6
				BEGIN
					SELECT @ShiftStartTime = DATEADD(DAY, 1, @ShiftStartTime)
						,@ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
				END

				IF @StartTime > @EndTime
				BEGIN
					SET @ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
				END
			END

			-- only insert if there is no shift
			IF NOT EXISTS (
					SELECT 1
					FROM dbo.EmployeeWorkingShift WITH (ROWLOCK)
					WHERE EmployeeId = @EmployeeId
						AND ShiftDate = @ShiftDate
					)
			BEGIN
				INSERT INTO dbo.EmployeeWorkingShift (
					EmployeeId
					,ShiftId
					,ShiftDate
					,ShiftStartTime
					,ShiftEndTime
					)
				VALUES (
					@EmployeeId
					,@ShiftId
					,@ShiftDate
					,@ShiftStartTime
					,@ShiftEndTime
					);
			END
		END

		SET @DayOfTheWeek = @DayOfTheWeek + 1
	END
END