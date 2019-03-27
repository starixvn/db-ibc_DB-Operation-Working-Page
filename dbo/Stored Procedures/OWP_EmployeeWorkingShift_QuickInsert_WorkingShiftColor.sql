
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QuickInsert_WorkingShiftColor] @ActorId INT
	,@ShiftCode NVARCHAR(50)
	,@Background NVARCHAR(50)
	,@Color NVARCHAR(50)
	,@StartTime TIME(7) = NULL
	,@EndTime TIME(7) = NULL
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
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @TimezoneOffset INT = dbo.fnc_GetWorkingShiftTimezoneOffset(@ActorId)

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
			)

	IF @ShiftId > 0
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Shift existed'
	END
	ELSE
	BEGIN
		INSERT INTO dbo.EmployeeWorkingShiftColor (
			ShiftCode
			,Background
			,Color
			,StartTime
			,EndTime
			,IsTimeShift
			)
		VALUES (CASE 
				WHEN @StartTime IS NULL THEN UPPER(LTRIM(RTRIM(@ShiftCode)))
				ELSE ''
				END
			,@Background
			,@Color
			,@StartTime
			,@EndTime
			,CASE 
				WHEN @StartTime IS NULL THEN 0
				ELSE 1
				END
			);

		SELECT @ShiftId = @@IDENTITY
	END
END