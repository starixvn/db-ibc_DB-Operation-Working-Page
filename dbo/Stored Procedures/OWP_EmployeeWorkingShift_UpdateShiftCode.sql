
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateShiftCode] @ActorId INT
	,@EmployeeId INT
	,@ShiftId INT
	,@ShiftDate DATE
AS
/*    
 Created: 20180914@Kane.Le
 Task : Edit working shift by date
 DB: bodb_OWP
 
Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartTime TIME(7)
		,@EndTime TIME(7)
		,@IsTimeShift BIT
		,@ShiftStartTime DATETIME = NULL
		,@ShiftEndTime DATETIME = NULL

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

	IF EXISTS (
			SELECT 1
			FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
			WHERE EmployeeId = @EmployeeId
				AND ShiftDate = @ShiftDate
			)
	BEGIN
		UPDATE dbo.EmployeeWorkingShift WITH (ROWLOCK)
		SET ShiftId = @ShiftId
			,ShiftStartTime = @ShiftStartTime
			,ShiftEndTime = @ShiftEndTime
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate = @ShiftDate
	END
	ELSE
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