
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QuickDelete_WorkingShiftColor] @ActorId INT
	,@ShiftId INT
AS
/*    
 Created: 20181009@Kane.Le
 Task : Delete Shift Color [Redmine: #102867]
 DB: bodb_OWP

 Revisions:
	 20181012@Kane.Le: Initial SP - [Redmine: #102867]
	 20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
	 20190520@Leo.Vo: Write log - [Redmine: #113763]
	 20190521@Kane.Le: Delete in defaul shift - [Redmine: #113763]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @ShiftCode NVARCHAR(50)
		,@Background VARCHAR(50)
		,@Color VARCHAR(50)
		,@StartTime TIME(7)
		,@EndTime TIME(7)
		,@IsTimeShift BIT
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	SELECT @ShiftCode = ShiftCode
		,@Background = Background
		,@Color = Color
		,@StartTime = StartTime
		,@EndTime = EndTime
		,@IsTimeShift = IsTimeShift
	FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
	WHERE ShiftId = @ShiftId

	IF @Background IS NOT NULL
	BEGIN
		DELETE
		FROM EmployeeWorkingShiftColor WITH (ROWLOCK)
		WHERE ShiftId = @ShiftId

		DELETE
		FROM EmployeeWorkingShiftDefault WITH (ROWLOCK)
		WHERE ShiftId = @ShiftId

		-- write log
		SET @Xml = (
				SELECT @ShiftId AS '@sid'
					,@ShiftCode AS '@sc'
					,@Background AS '@bg'
					,@Color AS '@c'
					,@StartTime AS '@st'
					,@EndTime AS '@et'
					,@IsTimeShift AS '@its'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
			,@SPName = 'OWP_EmployeeWorkingShift_QuickDelete_WorkingShiftColor'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @ShiftId
			,@Data = NULL
			,@DataOld = @LogDataOld
	END
END