
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QuickInsert_WorkingShiftColor] @ActorId INT
	,@ShiftCode NVARCHAR(50)
	,@Background NVARCHAR(50)
	,@Color NVARCHAR(50)
	,@StartTime TIME(7) = NULL
	,@EndTime TIME(7) = NULL
	,@Extension INT = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(2000) = NULL OUTPUT
	,@ShiftId INT = 0 OUTPUT
AS
/*    
 Created: 20181009@Kane.Le
 Task : Insert Shift Color [Redmine: #102867]
 DB: bodb_OWP
 
 Param's Explanation:
 @Name: '8 > 17'
 @Background: '#3399cc'
 @Color: '#3399cc'
 
 Revisions:
	 20181012@Kane.Le: Initial SP - [Redmine: #102867]
	 20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
	 20190312@Leo.Vo: Set ShiftCode empty if it is time shift - [Redmine: #109560]
	 20190326@Leo.Vo: Change to handle error code - [Redmine: #110322]
	 20190520@Leo.Vo: Write log - [Redmine: #113763]
	 20191002@Kane.Le: Add Extension ((REAL), (SPECIAL))  = '' - [Redmine: #121272]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @TimezoneOffset INT = dbo.fnc_GetWorkingShiftTimezoneOffset(@ActorId)
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	SELECT @StartTime = DATEADD(MINUTE, - @TimezoneOffset, @StartTime)
		,@EndTime = DATEADD(MINUTE, - @TimezoneOffset, @EndTime)

	SELECT @ShiftId = ShiftId
	FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
	WHERE (
			@StartTime IS NULL
			AND ShiftCode = LTRIM(RTRIM(@ShiftCode))
			)
		OR (
			@StartTime IS NOT NULL
			AND StartTime = @StartTime
			AND EndTime = @EndTime
			AND Extension=@Extension
			)

	IF @ShiftId > 0
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Shift existed'
	END
	ELSE
	BEGIN
		DECLARE @IsTimeShift BIT = (CASE 
				WHEN @StartTime IS NULL THEN 0
				ELSE 1 END
				)

		INSERT INTO dbo.EmployeeWorkingShiftColor (
			ShiftCode
			,Background
			,Color
			,StartTime
			,EndTime
			,IsTimeShift
			,Extension
			)
		VALUES (CASE 
				WHEN @StartTime IS NULL THEN UPPER(LTRIM(RTRIM(@ShiftCode)))
				ELSE ''
				END
			,@Background
			,@Color
			,@StartTime
			,@EndTime
			,@IsTimeShift
			,@Extension
			)

		SELECT @ShiftId = @@IDENTITY

		-- write log
		SET @Xml = (
				SELECT @ShiftId AS '@sid'
					,@ShiftCode AS '@sc'
					,@Background AS '@bg'
					,@Color AS '@c'
					,@StartTime AS '@st'
					,@EndTime AS '@et'
					,@IsTimeShift AS '@its'
					,@Extension AS '@ext'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
			,@SPName = 'OWP_EmployeeWorkingShift_QuickInsert_WorkingShiftColor'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @ShiftId
			,@Data = @LogData
			,@DataOld = NULL
	END
END