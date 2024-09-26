/*<info serverAlias="DBOWP-bodb_OWP" selecters="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetShiftTime] (
	@ShiftDate DATE
	,@ShiftId INT
	)
RETURNS @tblShiftTime TABLE (
	ShiftStartTime DATETIME
	,ShiftEndTime DATETIME
	)
AS
/*          
Created: 20190520@Leo.Vo
Task : get shift time
DB: bodb_OWP

Revisions:
	20190520@Leo.Vo: Initial Func - [Redmine: #112737]
	20191003@Tyler.Dang: Add REAL/ SPECIAL shift - [Redmine: #121438]
*/
BEGIN
	DECLARE @ShiftStartTime DATETIME
		,@ShiftEndTime DATETIME
		,@IsTimeShift BIT
		,@StartTime TIME(7)
		,@EndTime TIME(7)
		,@Extension INT
		,@REAL INT = 1
		,@SPECIAL INT = 2

	SELECT @IsTimeShift = c.IsTimeShift
		,@StartTime = c.StartTime
		,@EndTime = c.EndTime
		,@Extension = c.Extension
	FROM dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK)
	WHERE c.ShiftId = @ShiftId

	IF @IsTimeShift = 1
	BEGIN
		SELECT @ShiftStartTime = CAST(@ShiftDate AS DATETIME) + CAST(@StartTime AS DATETIME)
			,@ShiftEndTime = CAST(@ShiftDate AS DATETIME) + CAST(@EndTime AS DATETIME)

		IF @Extension = @SPECIAL
		BEGIN
			SELECT @ShiftStartTime = DATEADD(DAY, 1, @ShiftStartTime)
				,@ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
		END
		ELSE IF @Extension <> @REAL
		BEGIN
			IF DATEPART(HOUR, @StartTime) BETWEEN 0
				AND 6
			BEGIN
				SELECT @ShiftStartTime = DATEADD(DAY, 1, @ShiftStartTime)
					,@ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
			END
		END

		IF @StartTime > @EndTime
		BEGIN
			SET @ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
		END
	END

	INSERT INTO @tblShiftTime (
		ShiftStartTime
		,ShiftEndTime
		)
	VALUES (
		@ShiftStartTime
		,@ShiftEndTime
		)

	RETURN
END