
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetUsersByDate] @EventDate DATE
AS
/*
Created: 20181221@Raymond.Le
Task : Get users for auto assignment
DB: bodb_OWP

Revisions:
	20181221@Raymond.Le: Initial SP - [Redmine: #106196]
	20190306@Leo.Vo: Change condition - [Redmine: #109560]
	20190819@Leo.Vo: Update rule Auto Assignment [Redmine: #118861]
	20190917@Leo.Vo: Update rule Auto Assignment [Redmine: #118861]
	20191015@Kane.Le: Update rule User Staff Level - [Redmine: #121765]
	20190512@Kane.Le: Update ExtraTime, Venue [Redmine: #124940]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @LASection INT
		,@FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '12:00:00')
		,@NullLevelId INT
	
	SELECT @NullLevelId = MAX(ResourceId) + 1
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'UserLevel'

	SELECT @LASection = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'Section'
		AND Value = 'LA'

	CREATE TABLE #tblUser (
		UserId INT
		,[Level] INT
		,SpeakChinese BIT
		,SpeakEnglish BIT
		,[Location] VARCHAR(10)
		,LanguageId VARCHAR(50)
		)

	INSERT INTO #tblUser (
		UserId
		,[Level]
	 
		,[Location]
		,LanguageId
		)
	SELECT ou.UserId
		,ISNULL(ou.[Level], @NullLevelId)		
			,ou.LocationCode
			,ou.LanguageId
	FROM dbo.[User] AS ou WITH (NOLOCK)  
	LEFT JOIN dbo.UserRole AS ur WITH (NOLOCK) ON ur.UserId = ou.UserId
	WHERE LocationCode IS NOT NULL
		AND SectionId = @LASection
		AND (ur.RoleId = 1 OR ur.RoleId IS NULL)


	SELECT UserId
		,[Level]
		,(CASE 
			WHEN LanguageId LIKE '%1%' THEN 1
			ELSE 0
			END) AS SpeakChinese
			,(CASE 
			WHEN LanguageId LIKE '%2%' THEN 1
			ELSE 0
			END) AS SpeakEnglish
		 
		,[Location]		
	FROM #tblUser

	SELECT u.UserId
		,(CASE 
			WHEN ws.ShiftStartTime < @FromDate THEN @FromDate
			ELSE ws.ShiftStartTime END
			) AS ShiftStartTime
		,ws.ShiftEndTime
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
		INNER JOIN dbo.EmployeeWorkingShiftColor AS c WITH (NOLOCK) ON ws.ShiftId = c.ShiftId
		AND c.IsTimeShift = 1
		INNER JOIN #tblUser AS u ON ws.EmployeeId = u.UserId
	WHERE (
			ws.ShiftStartTime > @FromDate
			AND ws.ShiftStartTime <= @ToDate
			)
		OR (
			ws.ShiftEndTime > @FromDate
			AND ws.ShiftEndTime <= @ToDate
			)

	DROP TABLE #tblUser
END