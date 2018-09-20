/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_CopyWeekly] @UserId INT
	,@Date DATE
AS
/*
Created: 20180913@Leo
Task : clone week from previous
DB: bodb_OWP

Revisions:
	20180913@Leo: clone week from previous
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @PreviousFromDate DATE = DATEADD(DAY, - 7, @Date)
	DECLARE @PreviousToDate DATE = DATEADD(DAY, - 1, @Date)
	DECLARE @CurrentFromDate DATE = @Date
	DECLARE @CurrentToDate DATE = DATEADD(DAY, 6, @Date)
	DECLARE @CopyWorkingShift TABLE (
		EmployeeId INT
		,ShiftCode VARCHAR(50)
		,ShiftDate DATE
		)
	DECLARE @OutputWorkingShift TABLE (
		EmployeeId INT
		,ShiftCode VARCHAR(50)
		,ShiftDate DATE
		)

	-- get working shift need to be copied
	INSERT INTO @CopyWorkingShift
	SELECT EmployeeId
		,ShiftCode
		,DATEADD(DAY, 7, ShiftDate) AS ShiftDate
	FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
	WHERE EmployeeId = @UserId
		AND ShiftDate >= @PreviousFromDate
		AND ShiftDate <= @PreviousToDate

	-- delete current working shift
	DELETE EmployeeWorkingShift WITH (ROWLOCK, UPDLOCK)
	WHERE EmployeeId = @UserId
		AND ShiftDate >= @CurrentFromDate
		AND ShiftDate <= @CurrentToDate

	MERGE INTO dbo.EmployeeWorkingShift AS t
	USING (
		SELECT EmployeeId
			,ShiftCode
			,ShiftDate
		FROM @CopyWorkingShift
		) AS s ON s.EmployeeId = t.EmployeeId
			AND s.ShiftDate = t.ShiftDate
	WHEN MATCHED THEN
			UPDATE
			SET t.ShiftCode = s.ShiftCode
	WHEN NOT MATCHED BY TARGET THEN
			INSERT
			VALUES (
				s.EmployeeId
				,s.ShiftCode
				,s.ShiftDate
				)
	OUTPUT inserted.EmployeeId
		,inserted.ShiftCode
		,inserted.ShiftDate
	INTO @OutputWorkingShift;

	SELECT ISNULL(s.EmployeeId, 0) AS EmployeeId
		,s.ShiftCode
		,s.ShiftDate
		,c.Background
		,c.Color
	FROM @OutputWorkingShift AS s
		INNER JOIN dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK) ON s.ShiftCode = c.NAME
END