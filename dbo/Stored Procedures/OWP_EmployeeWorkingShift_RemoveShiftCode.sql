
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_RemoveShiftCode] @EmployeeId INT
	,@ShiftDate DATE
AS
/*    
 Created: 20181106@Kane.Le
 Task : Remove working shift code - [Redmine: #104291]
 DB: bodb_OWP
 
Revisions:
	 20181106@Kane.Le: Initial SP - [Redmine: #104291]
	 20190215@Leo.Vo: Init default shift - [Redmine: #108723]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartDate DATE
		,@EndDate DATE
		,@IsInit BIT
		,@SectionId INT

	-- check condition to init default shift weekly
	SELECT @StartDate = StartDate
		,@EndDate = EndDate
		,@IsInit = IsInit
	FROM dbo.fnc_CheckToInitDefaultShiftWeekly(@EmployeeId, @ShiftDate)

	IF @IsInit = 1
	BEGIN
		EXECUTE dbo.[OWP_EmployeeWorkingShift_InitDefaultShiftForWeek] @EmployeeId = @EmployeeId
			,@StartDate = @StartDate
			,@EndDate = @EndDate
	END

	DELETE
	FROM EmployeeWorkingShift WITH (ROWLOCK)
	WHERE EmployeeId = @EmployeeId
		AND ShiftDate = @ShiftDate

	SELECT EmployeeId
		,ShiftId
		,ShiftDate
	FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
	WHERE EmployeeId = @EmployeeId
		AND ShiftDate BETWEEN @StartDate
			AND @EndDate
END