CREATE FUNCTION [dbo].[fnc_GetDateTimeForTraderViewTime] ()
RETURNS @TraderViewTime TABLE (
	FromTime DATETIME
	,ToTime DATETIME
	,FromTimeForSpecialBettype DATETIME
	,ToTimeViewDetailForSpecialBettype DATETIME
	,ToTimeForSpecialBettype DATETIME
	)
AS
/*
Created: Quinn.Vo@20170421
Task: Get date time for trader view time.
DB: bodb_OWP
Original: 

Revisions:  
Param's Explanation:

*/
BEGIN
	DECLARE @Today DATETIME = GETDATE() -- GMT-4
		,@OWPToday DATETIME = DATEADD(hh, 12, GETDATE()) -- GMT+8
	DECLARE @FromTime DATETIME
		,@ToTime DATETIME
		,@FromTimeForSpecialBettype DATETIME
		,@ToTimeForSpecialBettype DATETIME
		,@ToTimeViewDetailForSpecialBettype DATETIME
		,@DateForWeekendAndWeekDay DATETIME
		,@IsWeekend BIT

	SELECT @IsWeekend = CASE DATEPART(weekday, @OWPToday)
		WHEN 1 THEN 1 --'Weekend'
		WHEN 2 THEN 0
		WHEN 3 THEN 0
		WHEN 4 THEN 0
		WHEN 5 THEN 0
		WHEN 6 THEN 0
		WHEN 7 THEN 1 --'Weekend'
		END

	IF (@IsWeekend = 1)
	BEGIN
		SET @DateForWeekendAndWeekDay = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '19:30:00')
	END
	ELSE
	BEGIN
		SET @DateForWeekendAndWeekDay = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '20:30:00')
	END

	IF (
		DATEDIFF(SECOND, DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00'), @OWPToday) > 0
		AND DATEDIFF(SECOND, @OWPToday, @DateForWeekendAndWeekDay) > 0
	)
	BEGIN
		SELECT @FromTime = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00')
			,@FromTimeForSpecialBettype = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00')
			,@ToTime = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '23:59:59')
			,@ToTimeForSpecialBettype = DATEADD(DAY, (DATEDIFF(DAY, 0, @Today) + 1), '11:59:59')
			,@ToTimeViewDetailForSpecialBettype = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '23:59:59')
	END
	ELSE IF (
		DATEDIFF(SECOND, @DateForWeekendAndWeekDay, @OWPToday) > 0
		AND DATEDIFF(SECOND, @OWPToday, DATEADD(DAY, (DATEDIFF(DAY, 0, @Today) + 1), '11:30:00')) > 0
	)
	BEGIN
		SELECT @FromTime = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00')
			,@FromTimeForSpecialBettype = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00')
			,@ToTime = DATEADD(DAY, (DATEDIFF(DAY, 0, @Today) + 1), '11:59:59')
			,@ToTimeForSpecialBettype = DATEADD(DAY, (DATEDIFF(DAY, 0, @Today) + 1), '11:59:59')
			,@ToTimeViewDetailForSpecialBettype = DATEADD(DAY, (DATEDIFF(DAY, 0, @Today) + 1), '11:59:59')
	END
	ELSE
	BEGIN
		SELECT @FromTime = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00')
			,@FromTimeForSpecialBettype = DATEADD(DAY, DATEDIFF(DAY, 0, @Today), '12:00:00')
			,@ToTime = DATEADD(DAY, (DATEDIFF(DAY, 0, @Today) + 1), '23:59:59')
			,@ToTimeForSpecialBettype = DATEADD(DAY, (DATEDIFF(DAY, 0, @Today) + 2), '11:59:59')
			,@ToTimeViewDetailForSpecialBettype = DATEADD(DAY, (DATEDIFF(DAY, 0, @Today) + 1), '23:59:59')
	END

	INSERT INTO @TraderViewTime (
		FromTime
		,ToTime
		,FromTimeForSpecialBettype
		,ToTimeForSpecialBettype
		,ToTimeViewDetailForSpecialBettype
	)
	VALUES (
		@FromTime
		,@ToTime
		,@FromTimeForSpecialBettype
		,@ToTimeForSpecialBettype
		,@ToTimeViewDetailForSpecialBettype
	)

	RETURN
END