/*
	Created: Raymond.Le
	Date: 2019-01-28
	Task: [Redmine: #108206]
	DB: bodb_OWP
*/
-- Add column ShiftId to table [EmployeeWorkingShift]
ALTER TABLE [dbo].[EmployeeWorkingShift] ADD ShiftId INT NULL;
EXECUTE sys.sp_rename 'dbo.EmployeeWorkingShift.ShiftCode', '_ShiftCode', 'COLUMN';

-- Rename table EmployeeWorkingShiftColor to EmployeeWorkingShiftColor_Old
EXECUTE sys.sp_rename 'dbo.EmployeeWorkingShiftColor', 'EmployeeWorkingShiftColor_Old';
EXECUTE sys.sp_rename 'PK_EmployeeWorkingShiftColor', 'PK_EmployeeWorkingShiftColor_Old';
EXECUTE sys.sp_rename 'DF_EmployeeWorkingShiftColor_Background', 'DF_EmployeeWorkingShiftColor_Background_Old';
EXECUTE sys.sp_rename 'DF_EmployeeWorkingShiftColor_Color', 'DF_EmployeeWorkingShiftColor_Color_Old';

-- Create new table [EmployeeWorkingShiftColor]
CREATE TABLE [dbo].[EmployeeWorkingShiftColor] (
	[ShiftId] [int] IDENTITY(1, 1) NOT NULL
	,[ShiftCode] [nvarchar](50) NOT NULL
	,[Background] [varchar](50) NOT NULL CONSTRAINT [DF_EmployeeWorkingShiftColor_Background] DEFAULT('')
	,[Color] [varchar](50) NOT NULL CONSTRAINT [DF_EmployeeWorkingShiftColor_Color] DEFAULT('')
	,[StartTime] [time](7) NULL
	,[EndTime] [time](7) NULL
	,[IsTimeShift] [bit] NOT NULL
	,CONSTRAINT [PK_EmployeeWorkingShiftColor] PRIMARY KEY CLUSTERED ([ShiftId] ASC)
	) ON [OWP_Data];

-- create table EmployeeWorkingShiftTimeZoneSetting
CREATE TABLE [dbo].[EmployeeWorkingShiftTimeZoneSetting] (
	[SettingId] [smallint] NOT NULL
	,[Name] [nvarchar](20) NOT NULL
	,[IsDefault] [bit] NOT NULL
	,[Offset] [smallint] NOT NULL
	,CONSTRAINT [PK_EmployeeWorkingShiftTimeZoneSetting] PRIMARY KEY CLUSTERED ([SettingId] ASC)
	) ON [OWP_Data];

INSERT INTO [dbo].[EmployeeWorkingShiftTimeZoneSetting] (
	SettingId
	,NAME
	,IsDefault
	,Offset
	)
VALUES (1, 'GMT+8', 1, 0)
	,(2, 'GMT+7', 0, - 60);

-- Add column to table [User]
ALTER TABLE dbo.[User] ADD TimeZoneSettingId SMALLINT NULL;

----------------------------------------------------
-- Migrate old data EmployeeWorkingShift
CREATE TABLE #tblWorkingShift (
	ShiftCode NVARCHAR(50)
	,StartTimeText NVARCHAR(50)
	,EndTimeText NVARCHAR(50)
	,IsValidShiftCode BIT
	);

CREATE TABLE #tblStartTime (
	ShiftCode NVARCHAR(50)
	,HourText NVARCHAR(50)
	,MinuteText NVARCHAR(50)
	,IsOnlyHaveHour BIT
	,IsValidTime BIT
	,Hour INT
	,Minute INT
	);

CREATE TABLE #tblEndTime (
	ShiftCode NVARCHAR(50)
	,HourText NVARCHAR(50)
	,MinuteText NVARCHAR(50)
	,IsOnlyHaveHour BIT
	,IsValidTime BIT
	,Hour INT
	,Minute INT
	);

CREATE TABLE #tblValidTimeShift (
	ShiftCode NVARCHAR(50)
	,StartTimeText NVARCHAR(5)
	,EndTimeText NVARCHAR(5)
	,StartTime TIME(7)
	,EndTime TIME(7)
	,NewShiftCode NVARCHAR(50)
	);

CREATE TABLE #tblOtherShift (
	ShiftCode NVARCHAR(50)
	,Background VARCHAR(50)
	,Color VARCHAR(50)
	);

CREATE TABLE #tblInsertedShift (
	ShiftId INT
	,ShiftCode NVARCHAR(50)
	);

CREATE TABLE #tblTempEmployeeWorkingShift (
	ShiftCode NVARCHAR(50)
	,ShiftDate DATE
	,ShiftStartDate DATE
	,ShiftStartTime DATETIME
	,ShiftEndDate DATE
	,ShiftEndTime DATETIME
	);

-- Split Shift code
INSERT INTO #tblWorkingShift (
	ShiftCode
	,StartTimeText
	,EndTimeText
	,IsValidShiftCode
	)
SELECT [Name]
	,SUBSTRING([Name], 1, CASE CHARINDEX('>', [Name])
			WHEN 0 THEN LEN([Name])
			ELSE CHARINDEX('>', [Name]) - 1
			END)
	,SUBSTRING([Name], CASE CHARINDEX('>', [Name])
			WHEN 0 THEN LEN([Name]) + 1
			ELSE CHARINDEX('>', [Name]) + 1
			END, 1000)
	,0
FROM dbo.EmployeeWorkingShiftColor_Old WITH (NOLOCK);

-- check valid time shift code
UPDATE #tblWorkingShift WITH (ROWLOCK, UPDLOCK)
SET IsValidShiftCode = 1
WHERE RTRIM(LTRIM(StartTimeText)) <> ''
	AND RTRIM(LTRIM(EndTimeText)) <> '';

-----
INSERT INTO #tblStartTime (
	ShiftCode
	,HourText
	,MinuteText
	,IsOnlyHaveHour
	,IsValidTime
	)
SELECT ShiftCode
	,RTRIM(LTRIM(SUBSTRING(StartTimeText, 1, CASE CHARINDEX(':', StartTimeText)
					WHEN 0 THEN LEN(StartTimeText)
					ELSE CHARINDEX(':', StartTimeText) - 1
					END)))
	,RTRIM(LTRIM(SUBSTRING(StartTimeText, CASE CHARINDEX(':', StartTimeText)
					WHEN 0 THEN LEN(StartTimeText) + 1
					ELSE CHARINDEX(':', StartTimeText) + 1
					END, 1000)))
	,CASE CHARINDEX(':', StartTimeText)
		WHEN 0 THEN 1
		ELSE 0
		END
	,0
FROM #tblWorkingShift WITH (NOLOCK)
WHERE IsValidShiftCode = 1;

INSERT INTO #tblEndTime (
	ShiftCode
	,HourText
	,MinuteText
	,IsOnlyHaveHour
	,IsValidTime
	)
SELECT ShiftCode
	,RTRIM(LTRIM(SUBSTRING(EndTimeText, 1, CASE CHARINDEX(':', EndTimeText)
					WHEN 0 THEN LEN(EndTimeText)
					ELSE CHARINDEX(':', EndTimeText) - 1
					END)))
	,RTRIM(LTRIM(SUBSTRING(EndTimeText, CASE CHARINDEX(':', EndTimeText)
					WHEN 0 THEN LEN(EndTimeText) + 1
					ELSE CHARINDEX(':', EndTimeText) + 1
					END, 1000)))
	,CASE CHARINDEX(':', EndTimeText)
		WHEN 0 THEN 1
		ELSE 0
		END
	,[IsValidTime] = 0
FROM #tblWorkingShift WITH (NOLOCK)
WHERE IsValidShiftCode = 1;

-- Check valid time value (ex: 8 or 8:45)
UPDATE #tblStartTime WITH (ROWLOCK, UPDLOCK)
SET IsValidTime = CASE 
		WHEN (
				IsOnlyHaveHour = 1
				AND ISNUMERIC(HourText + '.0e0') = 1
				AND MinuteText = ''
				AND CAST(HourText AS INT) BETWEEN 0
					AND 23
				) THEN 1
		WHEN (
				IsOnlyHaveHour = 0
				AND ISNUMERIC(HourText + '.0e0') = 1
				AND ISNUMERIC(MinuteText + '.0e0') = 1
				AND CAST(HourText AS INT) BETWEEN 0
					AND 23
				AND CAST(MinuteText AS INT) BETWEEN 0
					AND 60
				) THEN 1
		ELSE 0
		END;

UPDATE #tblStartTime WITH (ROWLOCK, UPDLOCK)
SET [Hour] = CAST(HourText AS INT)
	,[Minute] = CAST(MinuteText AS INT)
WHERE IsValidTime = 1;

UPDATE #tblEndTime WITH (ROWLOCK, UPDLOCK)
SET IsValidTime = CASE 
		WHEN (
				IsOnlyHaveHour = 1
				AND ISNUMERIC(HourText + '.0e0') = 1
				AND MinuteText = ''
				AND CAST(HourText AS INT) BETWEEN 0
					AND 23
				) THEN 1
		WHEN (
				IsOnlyHaveHour = 0
				AND ISNUMERIC(HourText + '.0e0') = 1
				AND ISNUMERIC(MinuteText + '.0e0') = 1
				AND CAST(HourText AS INT) BETWEEN 0
					AND 23
				AND CAST(MinuteText AS INT) BETWEEN 0
					AND 60
				) THEN 1
		ELSE 0
		END;

UPDATE #tblEndTime WITH (ROWLOCK, UPDLOCK)
SET [Hour] = CAST(HourText AS INT)
	,[Minute] = CAST(MinuteText AS INT)
WHERE IsValidTime = 1;

--------------
-- get All valid time shift
INSERT INTO #tblValidTimeShift (
	ShiftCode
	,StartTimeText
	,EndTimeText
	,StartTime
	,EndTime
	)
SELECT st.ShiftCode
	,CASE 
		WHEN st.[Minute] = 0 THEN RIGHT(REPLICATE('0', 2) + CAST(st.[Hour] AS VARCHAR(2)), 2)
		ELSE RIGHT(REPLICATE('0', 2) + CAST(st.[Hour] AS VARCHAR(2)), 2) + ':' + RIGHT(REPLICATE('0', 2) + CAST(st.[Minute] AS VARCHAR(2)), 2)
		END AS StartTimeText
	,CASE 
		WHEN et.[Minute] = 0 THEN RIGHT(REPLICATE('0', 2) + CAST(et.[Hour] AS VARCHAR(2)), 2)
		ELSE RIGHT(REPLICATE('0', 2) + CAST(et.[Hour] AS VARCHAR(2)), 2) + ':' + RIGHT(REPLICATE('0', 2) + CAST(et.[Minute] AS VARCHAR(2)), 2)
		END AS EndTimeText
	,DATEADD(hour, st.[Hour], DATEADD(minute, st.[Minute], 0))
	,DATEADD(hour, et.[Hour], DATEADD(minute, et.[Minute], 0))
FROM #tblStartTime AS st WITH (NOLOCK)
	INNER JOIN #tblEndTime AS et WITH (NOLOCK) ON st.ShiftCode = et.ShiftCode
WHERE st.IsValidTime = 1
	AND et.IsValidTime = 1;

UPDATE #tblValidTimeShift
SET NewShiftCode = StartTimeText + ' >' + EndTimeText

-- get non-time shift
INSERT INTO #tblOtherShift (
	ShiftCode
	,Background
	,Color
	)
SELECT ws.[Name]
	,ws.Background
	,ws.Color
FROM dbo.EmployeeWorkingShiftColor_Old AS ws WITH (NOLOCK)
WHERE NOT EXISTS (
		SELECT 1
		FROM #tblValidTimeShift AS vs WITH (NOLOCK)
		WHERE vs.ShiftCode = ws.[Name]
		)

--Insert new Shift
INSERT INTO dbo.EmployeeWorkingShiftColor (
	ShiftCode
	,Background
	,Color
	,StartTime
	,EndTime
	,IsTimeShift
	)
OUTPUT inserted.ShiftId
	,inserted.ShiftCode
INTO #tblInsertedShift(ShiftId, ShiftCode)
SELECT DISTINCT vs.NewShiftCode
	,sc.Background
	,sc.Color
	,vs.StartTime
	,vs.EndTime
	,1
FROM #tblValidTimeShift AS vs WITH (NOLOCK)
	OUTER APPLY (
	SELECT TOP 1 c.Background
		,c.Color
	FROM #tblValidTimeShift AS s WITH (NOLOCK)
		LEFT JOIN dbo.EmployeeWorkingShiftColor_Old AS c WITH (NOLOCK) ON s.ShiftCode = c.[Name]
	WHERE s.NewShiftCode = vs.NewShiftCode
	) AS sc

UNION
SELECT os.ShiftCode
	,os.Background
	,os.Color
	,NULL
	,NULL
	,0
FROM #tblOtherShift AS os WITH (NOLOCK)

-- Update color follow valid shift code format
UPDATE c WITH (ROWLOCK, UPDLOCK)
SET c.Background = oc.Background
	,c.Color = oc.Color
FROM dbo.EmployeeWorkingShiftColor AS c
	INNER JOIN dbo.EmployeeWorkingShiftColor_Old AS oc WITH (NOLOCK) ON c.ShiftCode = oc.[Name]
WHERE c.IsTimeShift = 1
	AND EXISTS (
		SELECT 1
		FROM dbo.EmployeeWorkingShiftColor_Old AS eo WITH (NOLOCK)
		WHERE eo.[Name] = c.ShiftCode
		)

---------
-- Update table EmployeeWorkingShift
INSERT INTO #tblTempEmployeeWorkingShift (
	ShiftCode
	,ShiftDate
	,ShiftStartDate
	,ShiftStartTime
	)
SELECT ws._ShiftCode
	,ws.ShiftDate
	,CASE 
		WHEN st.Hour < 6 THEN DATEADD(DAY, 1, ws.ShiftDate)
		ELSE ws.ShiftDate
		END
	,DATEADD(HOUR, st.Hour, DATEADD(MINUTE, st.Minute, 0))
FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
	INNER JOIN #tblValidTimeShift AS v WITH (NOLOCK) ON ws._ShiftCode = v.ShiftCode
	LEFT JOIN #tblStartTime AS st WITH (NOLOCK) ON v.ShiftCode = st.ShiftCode

UPDATE ws WITH (ROWLOCK, UPDLOCK)
SET ws.ShiftEndDate = CASE 
		WHEN et.Hour < st.Hour THEN DATEADD(DAY, 1, ws.ShiftStartDate)
		ELSE ws.ShiftStartDate
		END
	,ws.ShiftEndTime = DATEADD(HOUR, et.Hour, DATEADD(MINUTE, et.Minute, 0))
FROM #tblTempEmployeeWorkingShift AS ws
	LEFT JOIN #tblStartTime AS st WITH (NOLOCK) ON ws.ShiftCode = st.ShiftCode
	LEFT JOIN #tblEndTime AS et WITH (NOLOCK) ON ws.ShiftCode = et.ShiftCode

-- 1. Update Time Shift
UPDATE ws WITH (ROWLOCK, UPDLOCK)
SET ws.ShiftId = i.ShiftId
	,ws.ShiftStartTime = tws.ShiftStartDate + tws.ShiftStartTime
	,ws.ShiftEndTime = tws.ShiftEndDate + tws.ShiftEndTime
FROM dbo.EmployeeWorkingShift AS ws
	LEFT JOIN #tblTempEmployeeWorkingShift AS tws WITH (NOLOCK) ON tws.ShiftCode = ws._ShiftCode
	AND tws.ShiftDate = ws.ShiftDate
	LEFT JOIN #tblValidTimeShift AS v WITH (NOLOCK) ON tws.ShiftCode = v.ShiftCode
	LEFT JOIN #tblInsertedShift AS i WITH (NOLOCK) ON v.NewShiftCode = i.ShiftCode
WHERE EXISTS (
		SELECT 1
		FROM #tblTempEmployeeWorkingShift AS et WITH (NOLOCK)
		WHERE et.ShiftCode = ws._ShiftCode
			AND et.ShiftDate = ws.ShiftDate
		)

-- 2. Update Non-Time SHIFT
UPDATE ws WITH (ROWLOCK, UPDLOCK)
SET ws.ShiftId = i.ShiftId
	,ws.ShiftStartTime = NULL
	,ws.ShiftEndTime = NULL
FROM dbo.EmployeeWorkingShift AS ws
	LEFT JOIN #tblOtherShift AS os WITH (NOLOCK) ON os.ShiftCode = ws._ShiftCode
	LEFT JOIN #tblInsertedShift AS i WITH (NOLOCK) ON os.ShiftCode = i.ShiftCode
WHERE EXISTS (
		SELECT 1
		FROM #tblOtherShift AS eos WITH (NOLOCK)
		WHERE eos.ShiftCode = ws._ShiftCode
		)

DROP TABLE #tblWorkingShift;

DROP TABLE #tblStartTime;

DROP TABLE #tblEndTime;

DROP TABLE #tblValidTimeShift;

DROP TABLE #tblOtherShift;

DROP TABLE #tblInsertedShift;

DROP TABLE #tblTempEmployeeWorkingShift;

-------------------------------------
-- Remove column _ShiftCode
DROP INDEX dbo.[EmployeeWorkingShift].IX_EmployeeWorkingShift_ShiftCode;

ALTER TABLE dbo.[EmployeeWorkingShift]
DROP COLUMN _ShiftCode;

-- Alter column ShiftId
DELETE 
FROM dbo.[EmployeeWorkingShift]
WHERE ShiftId IS NULL;

ALTER TABLE dbo.[EmployeeWorkingShift]
ALTER COLUMN ShiftId INT NOT NULL;

CREATE NONCLUSTERED INDEX IX_EmployeeWorkingShift_ShiftId ON dbo.[EmployeeWorkingShift] (ShiftId ASC) ON OWP_Index;

-- Drop table EmployeeWorkingShiftColor_Old
DROP TABLE EmployeeWorkingShiftColor_Old

