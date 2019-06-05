
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Task_OWP_EmployeeWorkingShiftPublish_AutoPublish]
AS
/*    
 Created: 20190530@Kane.Le
 Task : Publish working shift auto for next week  
 DB: bodb_OWP

 Revisions:
	20190530@Kane.Le: Initial SP - [Redmine: #110322]	
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RunDate DATE = DATEADD(HOUR, 11, GETDATE())
		,@FromDate DATE
		,@ToDate DATE
		,@NextWeek DATE
		,@ExcludeSections NVARCHAR(500) = 'LA' -- LA, LG, LST

	SET @FromDate = DATEADD(DD, 0 - (@@DATEFIRST + 5 + DATEPART(DW, @RunDate)) % 7, @RunDate) -- Monday
	SET @ToDate = DATEADD(DD, 6 - (@@DATEFIRST + 5 + DATEPART(DW, @RunDate)) % 7, @RunDate) -- Sunday
	SET @FromDate = DATEADD(DAY, 1, @ToDate)
	SET @ToDate = DATEADD(DAY, 6, @FromDate)

	DECLARE @tblSection TABLE (
		RowNum INT
		,SectionId INT
		,SectionName VARCHAR(50)
		)

	INSERT INTO @tblSection
	SELECT ROW_NUMBER() OVER (
			ORDER BY (
					SELECT NULL
					)
			)
		,rs.ResourceId
		,rs.Value
	FROM dbo.RefResource AS rs WITH (NOLOCK)
	WHERE rs.RefName = 'Section'
		AND rs.[Value] NOT IN (
			SELECT LTRIM(RTRIM(val))
			FROM dbo.fnc_SplitStrings(@ExcludeSections, ',')
			)
		AND ResourceId NOT IN (
			SELECT p.SectionId
			FROM dbo.EmployeeWorkingShiftPublish AS p WITH (NOLOCK)
			WHERE p.FromDate >= @FromDate
				AND p.ToDate <= @ToDate
			)

	DECLARE @SectionId INT
		,@RowNum INT;

	SELECT @RowNum = COUNT(*)
	FROM @tblSection

	WHILE @RowNum > 0
	BEGIN
		SELECT @SectionId = SectionId
		FROM @tblSection
		WHERE RowNum = @RowNum

		EXEC OWP_EmployeeWorkingShiftPublish_ManualPublish 0
			,@SectionId
			,@FromDate
			,@ToDate
			,1

		SET @RowNum = @RowNum - 1
	END
END