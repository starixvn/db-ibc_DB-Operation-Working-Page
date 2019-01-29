
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetUsersByDate] @EventDate DATE
AS
/*
Created: 20181221@Raymond.Le
Task : Get users for auto assignment
DB: bodb_OWP

Revisions:
	20181221@Raymond.Le: Initial SP - [Redmine: #106196]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @LASection INT
		
	SELECT @LASection = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'Section' AND Value = 'LA'

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
		,ws.ShiftStartTime
		,ws.ShiftEndTime
	FROM dbo.EmployeeWorkingShift AS ws WITH (NOLOCK)
		INNER JOIN #tblUser AS u ON ws.EmployeeId = u.UserId
	WHERE ws.ShiftStartTime IS NOT NULL AND @EventDate >= ws.ShiftStartTime
		AND ws.ShiftEndTime IS NOT NULL AND @EventDate <= ws.ShiftEndTime

	DROP TABLE #tblUser
END