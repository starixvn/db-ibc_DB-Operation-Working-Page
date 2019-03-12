
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
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartTime TIME(7)
		,@EndTime TIME(7)
		,@IsTimeShift BIT
		,@ShiftStartTime DATETIME = NULL
		,@ShiftEndTime DATETIME = NULL
		,@StartDate DATE
		,@EndDate DATE
		,@IsInit BIT
		,@DayOfTheWeek INT

	-- check condition to init default shift weekly
	SELECT @StartDate = StartDate
		,@EndDate = EndDate
		,@IsInit = IsInit
	FROM dbo.fnc_CheckToInitDefaultShiftWeekly(@EmployeeId, @ShiftDate)

	SELECT @StartTime = StartTime
		,@EndTime = EndTime
		,@IsTimeShift = IsTimeShift
	FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
	WHERE ShiftId = @ShiftId

	IF @IsTimeShift = 1
	BEGIN
		SELECT @ShiftStartTime = @ShiftDate + CAST(@StartTime AS DATETIME)
			,@ShiftEndTime = @ShiftDate + CAST(@EndTime AS DATETIME)

		IF DATEPART(HOUR, @StartTime) < 6
		BEGIN
			SELECT @ShiftStartTime = DATEADD(DAY, 1, @ShiftStartTime)
				,@ShiftEndTime = DATEADD(DAY, 1, @ShiftEndTime)
		END
	END

	-- try to update
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

	-- no working shift updated then should insert
	IF @@ROWCOUNT = 0
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

	-- init default shift weekly
	IF @IsInit = 1
	BEGIN
		EXECUTE dbo.[OWP_EmployeeWorkingShift_InitDefaultShiftForWeek] @EmployeeId = @EmployeeId
			,@StartDate = @StartDate
			,@EndDate = @EndDate
	END

	SELECT EmployeeId
		,ShiftId
		,ShiftDate
		,RefShiftId
	FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
	WHERE EmployeeId = @EmployeeId
		AND ShiftDate BETWEEN @StartDate
			AND @EndDate
END