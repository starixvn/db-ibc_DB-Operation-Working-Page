
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_CopyWeekly] @UserId INT
	,@Date DATE
AS
/*
Created: 20180913@Leo
Task : clone week from previous
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181126@Kane.Le: Select Column SectionId for check permisson [Redmine: #105043]
	20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @PreviousFromDate DATE = DATEADD(DAY, - 7, @Date)
	DECLARE @PreviousToDate DATE = DATEADD(DAY, - 1, @Date)
	DECLARE @CurrentFromDate DATE = @Date
	DECLARE @CurrentToDate DATE = DATEADD(DAY, 6, @Date)
	DECLARE @SectionId INT = NULL
	DECLARE @CopyWorkingShift TABLE (
		EmployeeId INT
		,ShiftId INT
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		)
	DECLARE @OutputWorkingShift TABLE (
		EmployeeId INT
		,ShiftId INT
		,ShiftDate DATE
		,ShiftStartTime DATETIME
		,ShiftEndTime DATETIME
		)

	-- get working shift need to be copied
	INSERT INTO @CopyWorkingShift
	SELECT EmployeeId
		,ShiftId
		,DATEADD(DAY, 7, ShiftDate) AS ShiftDate
		,DATEADD(DAY, 7, ShiftStartTime) AS ShiftStartTime
		,DATEADD(DAY, 7, ShiftEndTime) AS ShiftEndTime
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
		FROM @CopyWorkingShift
		) AS s ON s.EmployeeId = t.EmployeeId
			AND s.ShiftDate = t.ShiftDate
	WHEN MATCHED THEN
			UPDATE
			SET t.ShiftId = s.ShiftId
				,t.ShiftStartTime = s.ShiftStartTime
				,t.ShiftEndTime = s.ShiftEndTime
	WHEN NOT MATCHED BY TARGET THEN
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
				)
	OUTPUT inserted.EmployeeId
		,inserted.ShiftId
		,inserted.ShiftDate
		,inserted.ShiftStartTime
		,inserted.ShiftEndTime
	INTO @OutputWorkingShift;

	SELECT @SectionId = u.SectionId
	FROM dbo.[User] u WITH (NOLOCK)
	WHERE u.UserId = @UserId

	SELECT ISNULL(s.EmployeeId, 0) AS EmployeeId
		,s.ShiftId
		,s.ShiftDate
		,c.Background
		,c.Color
		,@SectionId AS SectionId
	FROM @OutputWorkingShift AS s
		INNER JOIN dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK) ON s.ShiftId = c.ShiftId
END