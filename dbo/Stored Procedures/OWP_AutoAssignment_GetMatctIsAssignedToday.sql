
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetMatctIsAssignedToday]
	@EventDate DATE
AS
/*
Created: 20200527@Carlos.Nguyen
Task : Get match is assigned today
DB: bodb_OWP

Revisions:
	20200527@Carlos.Nguyen: Initial SP - [Redmine: #126964]
	20210511@Mira: Auto trader assignment - [Redmine: #132710]
*/
BEGIN
	SET NOCOUNT ON
	
	/* Declare variable*/
	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@BettypeHDP INT = 1

	CREATE TABLE #tblMatch (
		OWPMatchId INT,
		ParentMatchId INT
	)

	INSERT INTO #tblMatch (
		OWPMatchId,
		ParentMatchId
		)
	SELECT om.OWPMatchId,
		CASE 
			WHEN mm.MinorBettypeId IS NULL THEN om.OWPMatchId
			ELSE mm.ParentMatchId
			END
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON om.OWPMatchId = mm.MinorMatchId
	WHERE mi.IsSelected = 1
		AND om.EventDateTime BETWEEN @FromDate
			AND @ToDate
		AND (
			mm.MinorBettypeId NOT IN (@FastMarket, @AllInOne)
			OR mm.MinorBettypeId IS NULL
			)
			
	SELECT DISTINCT r.OWPMatchId AS MatchId,
		r.Bettype,
		r.UserId_LA 'UserId'
	FROM #tblMatch AS tblm WITH (NOLOCK)
		INNER JOIN AutoAssignmentResult AS r WITH(NOLOCK) ON tblm.ParentMatchId=r.OWPMatchId
	
	DROP TABLE #tblMatch
END