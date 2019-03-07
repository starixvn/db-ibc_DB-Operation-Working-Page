
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
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @LASection INT
		,@FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')

	SELECT @LASection = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'Section'
		AND Value = 'LA'

	CREATE TABLE #tblUser (
		UserId INT
		,[Level] INT
		,SpeakChinese BIT
		)

	INSERT INTO #tblUser (
		UserId
		,[Level]
		,SpeakChinese
		)
	SELECT UserId
		,[Level]
		,CASE 
			WHEN LocationCode = 'CTI' THEN 1
			ELSE 0
			END
	FROM dbo.[User] WITH (NOLOCK)
	WHERE [Level] IS NOT NULL
		AND LocationCode IS NOT NULL
		AND SectionId = @LASection

	SELECT UserId
		,[Level]
		,SpeakChinese
	FROM #tblUser

	SELECT u.UserId
		,(CASE 
			WHEN ws.ShiftStartTime < @FromDate THEN @FromDate
			ELSE ws.ShiftStartTime END
			) AS ShiftStartTime
		,(CASE 
			WHEN ws.ShiftEndTime > @ToDate THEN @ToDate
			ELSE ws.ShiftEndTime END
			) AS ShiftEndTime
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