/*
	Creator:	20181009@Leo
	Task:		Data migration for new OWP - EmployeeWorkingShift table - [Redmine: #102733]
	Server:		DBOWP.bodb_OWP

	Review & Tested:	Billy
*/


CREATE TABLE	#tblWorkingShift (
					EmployeeId			INT
				,	ShiftDate			DATE
				,	StartTimeText		NVARCHAR(50)
				,	EndTimeText			NVARCHAR(50)
				,	IsValidShiftCode	BIT
				);

CREATE TABLE	#tblStartTime (
					EmployeeId			INT
				,	ShiftDate			DATE
				,	HourText			NVARCHAR(50)
				,	MinuteText			NVARCHAR(50)
				,	IsOnlyHaveHour		BIT
				,	IsValidTime			BIT
				,	Hour				INT
				,	Minute				INT
				);

CREATE TABLE	#tblEndTime (
					EmployeeId			INT
				,	ShiftDate			DATE
				,	HourText			NVARCHAR(50)
				,	MinuteText			NVARCHAR(50)
				,	IsOnlyHaveHour		BIT
				,	IsValidTime			BIT
				,	Hour				INT
				,	Minute				INT
				);

CREATE TABLE	#tblValidShift (
					EmployeeId			INT
				,	ShiftDate			DATE
				,	ShiftStartDate		DATE
				,	ShiftStartTime		DATETIME
				,	ShiftEndDate		DATE
				,	ShiftEndTime		DATETIME
				);

-- Split Shift code
-- 77529 rows affected --
INSERT INTO	#tblWorkingShift (EmployeeId, ShiftDate, StartTimeText, EndTimeText, IsValidShiftCode)
SELECT	[EmployeeId]		= EmployeeId
	,	[ShiftDate]			= ShiftDate
	,	[StartTimeText]		= SUBSTRING(ShiftCode, 1, CASE CHARINDEX('>', ShiftCode) WHEN 0 THEN LEN(ShiftCode) ELSE CHARINDEX('>', ShiftCode) - 1 END)
	,	[EndTimeText]		= SUBSTRING(ShiftCode, CASE CHARINDEX('>', ShiftCode) WHEN 0 THEN LEN(ShiftCode) + 1 ELSE CHARINDEX('>', ShiftCode) + 1 END, 1000)
	,	[IsValidShiftCode]	= 0
FROM	dbo.EmployeeWorkingShift WITH (NOLOCK);

-- check valid time shift code (ex: 6 > 9)
-- 53670 rows affected --
UPDATE	#tblWorkingShift WITH (TABLOCK)
SET		IsValidShiftCode = 1
WHERE	RTRIM(LTRIM(StartTimeText)) <> ''
	AND	RTRIM(LTRIM(EndTimeText)) <> '';

-----
-- 53670 rows affected --
INSERT INTO	#tblStartTime (EmployeeId, ShiftDate, HourText, MinuteText, IsOnlyHaveHour, IsValidTime)
SELECT	[EmployeeId]		= EmployeeId
	,	[ShiftDate]			= ShiftDate
	,	[HourText]			= SUBSTRING(StartTimeText, 1, CASE CHARINDEX(':', StartTimeText) WHEN 0 THEN LEN(StartTimeText) ELSE CHARINDEX(':', StartTimeText) - 1 END)
	,	[MinuteText]		= SUBSTRING(StartTimeText, CASE CHARINDEX(':', StartTimeText) WHEN 0 THEN LEN(StartTimeText) + 1 ELSE CHARINDEX(':', StartTimeText) + 1 END, 1000)
	,	[IsOnlyHaveHour]	= CASE CHARINDEX(':', StartTimeText)WHEN 0 THEN 1 ELSE 0 END
	,	[IsValidTime]		= 0
FROM	#tblWorkingShift WITH (NOLOCK)
WHERE	IsValidShiftCode = 1;

-- 53670 rows affected --
INSERT INTO	#tblEndTime (EmployeeId, ShiftDate, HourText, MinuteText, IsOnlyHaveHour, IsValidTime)
SELECT	[EmployeeId]		= EmployeeId
	,	[ShiftDate]			= ShiftDate
	,	[HourText]			= SUBSTRING(EndTimeText, 1, CASE CHARINDEX(':', EndTimeText) WHEN 0 THEN LEN(EndTimeText) ELSE CHARINDEX(':', EndTimeText) - 1 END)
	,	[MinuteText]		= SUBSTRING(EndTimeText, CASE CHARINDEX(':', EndTimeText) WHEN 0 THEN LEN(EndTimeText) + 1 ELSE CHARINDEX(':', EndTimeText) + 1 END, 1000)
	,	[IsOnlyHaveHour]	= CASE CHARINDEX(':', StartTimeText)WHEN 0 THEN 1 ELSE 0 END
	,	[IsValidTime]		= 0
FROM	#tblWorkingShift WITH (NOLOCK)
WHERE	IsValidShiftCode = 1;

-- Check valid time value (ex: 8 or 8:45)
-- 53670 rows affected --
UPDATE	#tblStartTime WITH (TABLOCK)
SET		IsValidTime		= CASE	WHEN (IsOnlyHaveHour = 1 AND ISNUMERIC(HourText) = 1 AND MinuteText = '' AND CAST(HourText AS INT) BETWEEN 0 AND 23) THEN 1
								WHEN (IsOnlyHaveHour = 0 AND ISNUMERIC(HourText) = 1 AND ISNUMERIC(MinuteText) = 1 AND CAST(HourText AS INT) BETWEEN 0 AND 23 AND CAST(MinuteText AS INT) BETWEEN 0 AND 60) THEN 1
								ELSE 0
						  END;

-- 53670 rows affected --
UPDATE	#tblStartTime WITH (TABLOCK)
SET		Hour	= CAST(HourText AS INT)
	,	Minute	= CAST(MinuteText AS INT)
WHERE	IsValidTime = 1;

-- 53670 rows affected --
UPDATE	#tblEndTime WITH (TABLOCK)
SET		IsValidTime		= CASE	WHEN (IsOnlyHaveHour = 1 AND ISNUMERIC(HourText) = 1 AND MinuteText = '' AND CAST(HourText AS INT) BETWEEN 0 AND 23) THEN 1
								WHEN (IsOnlyHaveHour = 0 AND ISNUMERIC(HourText) = 1 AND ISNUMERIC(MinuteText) = 1 AND CAST(HourText AS INT) BETWEEN 0 AND 23 AND CAST(MinuteText AS INT) BETWEEN 0 AND 60) THEN 1
								ELSE 0
						  END;

-- 51299 rows affected --
UPDATE	#tblEndTime WITH (TABLOCK)
SET		Hour	= CAST(HourText AS INT)
	,	Minute	= CAST(MinuteText AS INT)
WHERE	IsValidTime = 1;

-- Calc ShiftStartDate
-- 51299 rows affected --
INSERT INTO	#tblValidShift (EmployeeId, ShiftDate, ShiftStartDate, ShiftStartTime)
SELECT	[EmployeeId]		= st.EmployeeId
	,	[ShiftDate]			= st.ShiftDate
	,	[ShiftStartDate]	= CASE WHEN st.Hour < 6 THEN DATEADD(DAY, 1, st.ShiftDate) ELSE st.ShiftDate END
	,	[ShiftStartTime]	= DATEADD(HOUR, st.Hour, DATEADD(MINUTE, st.Minute, 0))
FROM		#tblStartTime AS st WITH (NOLOCK)
INNER JOIN	#tblEndTime AS et WITH (NOLOCK)
		ON	st.EmployeeId = et.EmployeeId
		AND	st.ShiftDate = et.ShiftDate
WHERE	st.IsValidTime = 1
	AND	et.IsValidTime = 1;

-- 51299 rows affected --
-- Calc ShiftEndDate
UPDATE	vs WITH (TABLOCK)
SET		vs.ShiftEndDate		= CASE WHEN et.Hour < st.Hour THEN DATEADD(DAY, 1, vs.ShiftStartDate) ELSE vs.ShiftStartDate END
	,	vs.ShiftEndTime		= DATEADD(HOUR, et.Hour, DATEADD(MINUTE, et.Minute, 0))
FROM		#tblValidShift AS vs
LEFT JOIN	#tblStartTime AS st WITH (NOLOCK)
		ON	vs.EmployeeId = st.EmployeeId
		AND	vs.ShiftDate = st.ShiftDate
LEFT JOIN	#tblEndTime AS et WITH (NOLOCK)
		ON	vs.EmployeeId = et.EmployeeId
		AND	vs.ShiftDate = et.ShiftDate;

--------------
--Update table EmployeeWorkingShift
-- 77529 rows affected --
UPDATE	ws WITH (TABLOCK)
SET		ws.ShiftStartTime	= vs.ShiftStartDate + vs.ShiftStartTime
	,	ws.ShiftEndTime		= vs.ShiftEndDate + vs.ShiftEndTime
FROM		dbo.EmployeeWorkingShift AS ws
LEFT JOIN	#tblValidShift AS vs WITH (NOLOCK)
		ON	ws.EmployeeId = vs.EmployeeId
		AND	ws.ShiftDate = vs.ShiftDate;

DROP TABLE #tblWorkingShift;
DROP TABLE #tblStartTime;
DROP TABLE #tblEndTime;
DROP TABLE #tblValidShift;