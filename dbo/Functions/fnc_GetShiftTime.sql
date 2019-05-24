/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
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
*/
BEGIN
	DECLARE @ShiftStartTime DATETIME
		,@ShiftEndTime DATETIME
		,@IsTimeShift BIT
		,@StartTime TIME(7)
		,@EndTime TIME(7)

	SELECT @IsTimeShift = c.IsTimeShift
		,@StartTime = c.StartTime
		,@EndTime = c.EndTime
	FROM dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK)
	WHERE c.ShiftId = @ShiftId

	IF @IsTimeShift = 1
	BEGIN
		SELECT @ShiftStartTime = @ShiftDate + CAST(@StartTime AS DATETIME)
			,@ShiftEndTime = @ShiftDate + CAST(@EndTime AS DATETIME)

		IF DATEPART(HOUR, @StartTime) BETWEEN 1
				AND 6
		BEGIN
			SELECT @ShiftStartTime = DATEADD(DAY, 1, @ShiftStartTime)
				,@ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
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