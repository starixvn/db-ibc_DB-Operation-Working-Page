
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftColorUpd] @ActorId INT
	,@ShiftId INT
	,@Background VARCHAR(50)
	,@Color VARCHAR(50)
AS
/*
Created: 20180213@Jacob
Task: Employee Working Shift Management
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
	20190521@Kane.Le: SP Writelog Update WorkingShift Color - [Redmine: #113763]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@OldBackground VARCHAR(50)
		,@OldColor NVARCHAR(50)
		,@OldShiftCode NVARCHAR(50)
		,@OldStartTime TIME
		,@OldEndTime TIME
		,@OldIsTimeShift BIT

	SELECT @OldBackground = wsc.Background
		,@OldColor = wsc.Color
		,@OldShiftCode = wsc.ShiftCode
		,@OldStartTime = wsc.StartTime
		,@OldEndTime = wsc.EndTime
		,@OldIsTimeShift = wsc.IsTimeShift
	FROM EmployeeWorkingShiftColor wsc WITH (NOLOCK)
	WHERE wsc.ShiftId = @ShiftId

	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT @ShiftId AS '@sid'
				,@OldShiftCode AS '@sc'
				,@OldBackground AS '@bg'
				,@OldColor AS '@cl'
				,@OldStartTime AS '@sst'
				,@OldEndTime AS '@set'
				,@OldIsTimeShift AS '@its'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	UPDATE dbo.EmployeeWorkingShiftColor
	WITH (ROWLOCK)

	SET Background = @Background
		,Color = @Color
	WHERE ShiftId = @ShiftId;

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO dbo.EmployeeWorkingShiftColor (
			ShiftId
			,Background
			,Color
			)
		VALUES (
			@ShiftId
			,@Background
			,@Color
			)
	END;

	--New data
	SET @Xml = (
			SELECT @ShiftId AS '@sid'
				,@OldShiftCode AS '@sc'
				,@Background AS '@bg'
				,@Color AS '@cl'
				,@OldStartTime AS '@sst'
				,@OldEndTime AS '@set'
				,@OldIsTimeShift AS '@its'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShiftColorUpd'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @ActorId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END;