USE [bodb_OWP]
GO
/****** Object:  UserDefinedFunction [dbo].[fnc_CheckToInitDefaultShiftWeekly]    Script Date: 5/6/2019 10:48:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
ALTER FUNCTION [dbo].[fnc_CheckToInitDefaultShiftWeekly] (
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
	20190506@Kane.Le: Change Today -> GMT-7 - [Redmine: #111840]
*/
BEGIN		
	DECLARE @Today_GMT7 DATE = DATEADD(HOUR, 7, GETUTCDATE())
		,@StartDate DATE
		,@EndDate DATE
		,@IsInit BIT = 0

	SET @StartDate = DATEADD(DAY, - (DATEPART(dw, @ShiftDate) + 5) % 7, @ShiftDate)
	SET @EndDate = DATEADD(DAY, 6, @StartDate)

	-- init default working shift if selected week is future one and there is no working shift in selected week
	IF @Today_GMT7 < @StartDate
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
