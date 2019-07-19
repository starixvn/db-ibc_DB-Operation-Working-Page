
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftPublish_GetSectionByWeek] @FromDate DATE
	,@ToDate DATE
	,@SectionIds NVARCHAR(2000) = NULL
AS
/*    
 Created: 20190530@Kane.Le
 Task : Get Section with Publish working shift
 DB: bodb_OWP

 Revisions:
	20190530@Kane.Le: Initial SP - [Redmine: #110322]
	20190719@Kane.Le: Update Section Order - [Redmine: #117098]	
*/
BEGIN
	DECLARE @tblSection TABLE (
		SectionId INT
		,SectionName VARCHAR(50)
		)

	INSERT INTO @tblSection (
		SectionId
		,SectionName
		)
	SELECT SectionId
		,SectionName
	FROM dbo.fnc_GetSectionByIds(@SectionIds)

	SELECT [SectionId] = r.ResourceId
		,[Name] = r.[Value]
		,t.FromDate
		,t.ToDate
		,t.IsPublished
		,[LastPublishedBy] = t.Username
		,t.LastPublishedDate
	FROM dbo.RefResource r
	LEFT JOIN (
		SELECT p.SectionId
			,p.FromDate
			,p.ToDate
			,p.IsPublished
			,p.LastPublishedDate
			,u.Username
		FROM dbo.EmployeeWorkingShiftPublish AS p WITH (NOLOCK)
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON p.LastPublishedById = u.UserId
		WHERE p.FromDate >= @FromDate
			AND p.ToDate <= @ToDate
		) AS t ON r.ResourceId = t.SectionId
	WHERE r.RefName = 'Section'
		AND r.ResourceId IN (
			SELECT SectionId
			FROM @tblSection
			)
	ORDER BY r.[Order]
		,r.[Value]
END