/*
	Created: Kane.Le
	Date: 20190612
	Task: [Redmine: #113763]
	DB: bodb_OWP
*/
--------------------------------
-- 1. INIT DATA
--------------------------------
SET DATEFIRST 1 -- Define beginning of week as Monday

DECLARE @FirstDateOfCurrentWeek DATE
	,@StartDate DATE
	,@TotalWeekToInit INT = 3 -- Init data for 3 week only
DECLARE @tblWSPublish TABLE (
	SectionId INT
	,FromDate DATE
	,ToDate DATE
	,IsPublished BIT
	,LastPublishedById INT
	,LastPublishedDate DATE
	)
DECLARE @tblSectionIds TABLE (SectionId INT)

INSERT INTO @tblSectionIds
SELECT [SectionId] = rs.ResourceId
FROM dbo.RefResource AS rs WITH (NOLOCK)
WHERE rs.RefName = 'Section'

SET @FirstDateOfCurrentWeek = DATEADD(DAY, 1 - DATEPART(DW, GETUTCDATE()), CONVERT(DATE, GETUTCDATE()))
SET @StartDate = DATEADD(WEEK, 1 - @TotalWeekToInit, @FirstDateOfCurrentWeek)

DECLARE @sIndex INT = 0

WHILE @sIndex < @TotalWeekToInit
BEGIN
	INSERT INTO @tblWSPublish
	SELECT rs.[SectionId]
		,@StartDate
		,DATEADD(DAY, 6, @StartDate)
		,1
		,0
		,GETUTCDATE()
	FROM @tblSectionIds AS rs

	SET @StartDate = DATEADD(DAY, 7, @StartDate)
	SET @sIndex = @sIndex + 1
END

SET DATEFIRST 7

-- INSERT DATA

DELETE FROM dbo.EmployeeWorkingShiftPublish
WHERE FromDate <= @FirstDateOfCurrentWeek

INSERT INTO dbo.EmployeeWorkingShiftPublish
SELECT * FROM @tblWSPublish
