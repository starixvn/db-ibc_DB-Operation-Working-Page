
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QuickInsert_WorkingShiftColor] @ActorId INT
	,@ShiftCode NVARCHAR(50)
	,@Background NVARCHAR(50)
	,@Color NVARCHAR(50)
	,@StartTime TIME(7) = NULL
	,@EndTime TIME(7) = NULL
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
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrCode INT = 0
		,@ErrMsg NVARCHAR(200) = ''
		,@TimezoneOffset INT = dbo.fnc_GetWorkingShiftTimezoneOffset(@ActorId)

	SELECT @StartTime = DATEADD(MINUTE, - @TimezoneOffset, @StartTime)
		,@EndTime = DATEADD(MINUTE, - @TimezoneOffset, @EndTime)

	IF EXISTS (
			SELECT 1
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
			)
	BEGIN
		SELECT 1 AS ErrCode
			,'Shift existed' AS ErrMsg
			,NULL AS ShiftId
			,NULL AS ShiftCode
			,@Color AS Color
			,@Background AS Background
			,NULL AS StartTime
			,NULL AS EndTime
			,0 AS IsTimeShift
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
		VALUES (
			UPPER(LTRIM(RTRIM(@ShiftCode)))
			,@Background
			,@Color
			,@StartTime
			,@EndTime
			,CASE 
				WHEN @StartTime IS NULL THEN 0
				ELSE 1
				END
			);

		SELECT 0 AS ErrCode
			,'' AS ErrMsg
			,ShiftId
			,@ShiftCode AS ShiftCode
			,@Color AS Color
			,@Background AS Background
			,@StartTime AS StartTime
			,@EndTime AS EndTime
			,IsTimeShift
		FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
		WHERE ShiftId = @@IDENTITY
	END
END