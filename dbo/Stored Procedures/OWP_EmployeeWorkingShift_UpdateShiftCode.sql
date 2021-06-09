
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateShiftCode] @ActorId INT
	,@EmployeeId INT
	,@ShiftId INT
	,@ShiftDate DATE
	,@RefShiftId INT = NULL
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
	20190524@Leo.Vo: Refactor code - [Redmine: #114047]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML
		,@ShiftStartTime DATETIME
		,@ShiftEndTime DATETIME
		,@OldShiftId INT
		,@OldRefShiftId INT
		,@OldShiftStartTime DATETIME
		,@OldShiftEndTime DATETIME
		,@OldIsOvertime BIT

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

	CREATE TABLE #tmpEmployeeWorkingShiftDefault (
		UserId INT
		,DateOfWeek INT
		,ShiftId INT
		,ShiftDate DATE
		);

	SELECT @ShiftStartTime = ShiftStartTime
		,@ShiftEndTime = ShiftEndTime
	FROM dbo.fnc_GetShiftTime(@ShiftDate, @ShiftId)

	IF @OldShiftId IS NOT NULL
	BEGIN
		UPDATE dbo.EmployeeWorkingShift WITH (ROWLOCK)
		SET ShiftId = @ShiftId
			,ShiftStartTime = @ShiftStartTime
			,ShiftEndTime = @ShiftEndTime
			,RefShiftId = @RefShiftId
			,LastUpdated = DATEADD(HOUR, 12, GETDATE())
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
			,RefShiftId
			,LastUpdated
			)
		VALUES (
			@EmployeeId
			,@ShiftId
			,@ShiftDate
			,@ShiftStartTime
			,@ShiftEndTime
			,@RefShiftId
			,DATEADD(HOUR, 12, GETDATE())
			);
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

	DROP TABLE #tmpEmployeeWorkingShiftDefault
END