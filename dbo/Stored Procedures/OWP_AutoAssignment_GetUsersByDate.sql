USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_AutoAssignment_GetUsersByDate]    Script Date: 10/05/2020 14:53:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetUsersByDate]
	@EventDate DATE,
	@SiteId INT
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
	20200520@Tyler.Dang: Update User SpeakChinese and English [Redmine: #133428]
	20200528@Carlos.Nguyen: Get distinct user - [Redmine: #126964]
	20200713@Carlos.Nguyen: Update LA session ID from (2)=> to (2,30)- [Redmine: #126964]
	20201005@Carlos.Nguyen: Exclude close account- [Redmine: #126964]
	20201028@Carlos.Nguyen: Exclude user role null (level=6)- [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '12:00:00')
		,@NullLevelId INT
	
	SELECT @NullLevelId = MAX(ResourceId) + 1
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'UserLevel'

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
	INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON ou.UserId = ci.custid
	INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH (NOLOCK) ON us.UserId = ou.UserId AND us.SiteId = @SiteId
	WHERE  ou.[Level] <> 6
		AND LocationCode IS NOT NULL
		AND SectionId IN (2,30)
		AND (ur.RoleId = 1 OR ur.RoleId IS NULL)
		AND (ci.closed = 0
		AND ci.reject = 0
		AND ci.[Enabled] = 1
		AND us.IsActive = 1)


	SELECT DISTINCT UserId
		,[Level]
		,(CASE 
			WHEN CHARINDEX('1', LanguageId) > 0 OR LanguageId IS NULL THEN 1
			ELSE 0
			END) AS SpeakChinese
			,(CASE 
			WHEN CHARINDEX('2', LanguageId) > 0 OR LanguageId IS NULL THEN 1
			ELSE 0
			END) AS SpeakEnglish
		 
		,[Location]		
	FROM #tblUser

	SELECT DISTINCT u.UserId
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
