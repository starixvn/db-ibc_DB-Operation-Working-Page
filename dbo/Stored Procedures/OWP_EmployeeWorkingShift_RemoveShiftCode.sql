
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_RemoveShiftCode] @ActorId INT
	,@EmployeeId INT
	,@ShiftDate DATE
AS
/*    
 Created: 20181106@Kane.Le
 Task : Remove working shift code - [Redmine: #104291]
 DB: bodb_OWP
 
Revisions:
	 20181106@Kane.Le: Initial SP - [Redmine: #104291]
	 20190215@Leo.Vo: Init default shift - [Redmine: #108723]
	 20190312@Leo.Vo: Add overtime - [Redmine: #109560]
	 20190513@Kane.Le: Change rule get default shift - [Redmine: #112737]
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
		,@OldShiftId INT
		,@OldRefShiftId INT
		,@OldShiftStartTime DATETIME
		,@OldShiftEndTime DATETIME
		,@ShiftId INT

	SET @StartRun = GETDATE()

	SELECT @OldShiftId = ShiftId
		,@OldShiftStartTime = ShiftStartTime
		,@OldShiftEndTime = ShiftEndTime
		,@OldRefShiftId = RefShiftId
	FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
	WHERE EmployeeId = @EmployeeId
		AND ShiftDate = @ShiftDate

	IF @OldRefShiftId IS NOT NULL
	BEGIN
		UPDATE EmployeeWorkingShift WITH (ROWLOCK)
		SET ShiftId = RefShiftId
			,ShiftStartTime = NULL
			,ShiftEndTime = NULL
			,RefShiftId = NULL
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate = @ShiftDate
			AND RefShiftId > 0

		SELECT @ShiftId = @OldRefShiftId
	END
	ELSE
	BEGIN
		DELETE
		FROM EmployeeWorkingShift WITH (ROWLOCK)
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate = @ShiftDate

		SELECT @ShiftId = NULL
	END

	-- write log
	SET @Xml = (
			SELECT @EmployeeId AS '@eid'
				,@ShiftDate AS '@sd'
				,@OldShiftStartTime AS '@st'
				,@OldShiftEndTime AS '@et'
				,@OldShiftId AS '@sid'
				,@OldRefShiftId AS '@rsid'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @Xml = (
			SELECT @EmployeeId AS '@eid'
				,@ShiftDate AS '@sd'
				,NULL AS '@st'
				,NULL AS '@et'
				,@ShiftId AS '@sid'
				,NULL AS '@rsid'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShift_RemoveShiftCode'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @EmployeeId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END