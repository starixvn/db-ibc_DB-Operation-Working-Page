
/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_CheckToInitDefaultShiftWeekly] (
	@EmployeeId INT
	,@ShiftDate DATE
	)
RETURNS @Result TABLE (
	StartDate DATE
	,EndDate DATE
	,IsInit BIT
	)
AS
/*
Created: 20190215@Leo.Vo
Task : check condition to init default shift weekly
DB: bodb_OWP

Param's Explanation:

Revisions:
	20190215@Leo.Vo: Initial function - [Redmine: #108723]
 
*/
BEGIN
	DECLARE @Today DATE = CONVERT(DATE, GETDATE())
		,@StartDate DATE
		,@EndDate DATE
		,@IsInit BIT = 0

	SET @StartDate = DATEADD(DAY, - (DATEPART(dw, @ShiftDate) + 5) % 7, @ShiftDate)
	SET @EndDate = DATEADD(DAY, 6, @StartDate)

	-- init default working shift if selected week is future one and there is no working shift in selected week
	IF @Today < @StartDate
		AND NOT EXISTS (
			SELECT 1
			FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
			WHERE EmployeeId = @EmployeeId
				AND ShiftDate BETWEEN @StartDate
					AND @EndDate
			)
	BEGIN
		SET @IsInit = 1
	END

	INSERT INTO @Result (
		StartDate
		,EndDate
		,IsInit
		)
	SELECT @StartDate
		,@EndDate
		,@IsInit

	RETURN
END