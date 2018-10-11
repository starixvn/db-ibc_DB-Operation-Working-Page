/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Trade5MatchPerDay_RunAfterInsertAssignment] @OWPEventDate DATE
	,@Trader INT = NULL
AS
/*          
Created: 20170215@razor.nguyen      
Task : Insert Assignment      
DB: bodb_OWP          

Param's Explanation:
	@OWPEventDate: GMT-4
	        
Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]              
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @AssignmentType INT
		,@MaxTrading INT
		,@countTrading INT
		,@EventDateTime DATETIME
		,@FromDate DATE
		,@ToDate DATE
		,@FromTime TIME
		,@ToTime TIME
	
	SET @EventDateTime = dbo.[OWP_ConvertDateGMTplus8](@OWPEventDate)
	
	SELECT @FromDate = CAST(@EventDateTime AS DATE)
		,@ToDate = CAST(DATEADD(DD, 1, @EventDateTime) AS DATE)
	SELECT
		@FromTime = CAST(@EventDateTime AS TIME)
		,@ToTime = CAST(DATEADD(DD, 1, @EventDateTime) AS TIME)
		

	SELECT @AssignmentType = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'AssignmentType'
		AND Value = 'Assignee'

	SELECT @MaxTrading = Value
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MaxMatchTradingPerDay'

	CREATE TABLE #tblAssignmentInfo (
		OWPMatchId INT
		,owpEventDate DATE
		,UserId INT
		,MinorBettypeId INT NULL
		,MinorMatchId INT
		,ParentMatchId INT NULL
		)

	CREATE TABLE #tblCountMatchTrading (
		UserId INT
		,owpEventDate DATE
		,Total INT
		)

	INSERT INTO #tblAssignmentInfo (
		OWPMatchId
		,owpEventDate
		,UserId
		,MinorBettypeId
		,MinorMatchId
		,ParentMatchId
		)
	SELECT DISTINCT om.OWPMatchId
		,om.EventDate
		,a.UserId
		,minor.MinorBettypeId
		,minor.MinorMatchId
		,minor.ParentMatchId
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON om.OWPMatchId = a.OWPMatchId
		LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
	WHERE (
			(
				om.EventDate = @FromDate
				AND om.KickOffTime >= @FromTime
				)
			OR (
				om.EventDate = @ToDate
				AND om.KickOffTime < @ToTime
				)
			)
		AND a.AssignmentType = @AssignmentType
		AND (
			@Trader IS NULL
			OR a.UserId = @Trader
			)

	UPDATE assignment
	SET assignment.ParentMatchId = assignment.OWPMatchId
	FROM #tblAssignmentInfo AS assignment
	WHERE assignment.MinorBettypeId IS NULL

	INSERT INTO #tblCountMatchTrading (
		UserId
		,owpEventDate
		,Total
		)
	SELECT data.UserId
		,data.owpEventDate
		,COUNT(1)
	FROM (
		SELECT ParentMatchId
			,owpEventDate
			,UserId
		FROM #tblAssignmentInfo WITH (NOLOCK)
		GROUP BY ParentMatchId
			,owpEventDate
			,UserId
		) AS data
	GROUP BY data.UserId
		,data.owpEventDate

	INSERT INTO dbo.Trade5MatchPerDay (
		UserId
		,[Date]
		)
	SELECT UserId
		,owpEventDate
	FROM #tblCountMatchTrading t1 WITH (NOLOCK)
	WHERE NOT EXISTS (
			SELECT 1
			FROM dbo.Trade5matchPerDay AS t2 WITH (NOLOCK)
			WHERE t1.UserId = t2.UserId
				AND t1.owpEventDate = t2.[Date]
			)
	GROUP BY UserId
		,owpEventDate
	HAVING SUM(Total) >= @MaxTrading

	DROP TABLE #tblAssignmentInfo

	DROP TABLE #tblCountMatchTrading
END