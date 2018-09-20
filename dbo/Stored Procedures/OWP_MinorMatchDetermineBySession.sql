CREATE PROCEDURE [dbo].[OWP_MinorMatchDetermineBySession] @SessionId NVARCHAR(100)
AS
/*
Created: 20170216@Julien
Task : Determine minor for assignment uploading
DB: bodb_OWP

Param's Explanation:

Revisions:
    20170411@Tim.Trinh: fix bug and remove get data from bodb02
    20170727@Tim.Trinh: fix bug determine next cornor, next booking
*/
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #tblMatchListNew (
		RowNumber INT
		,EventDate DATE
		,KickOffTime TIME
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,MinorBettypeId INT
		,MainLeague NVARCHAR(2000)
		,MainHome NVARCHAR(200)
		,MainAway NVARCHAR(200)
		,MainOWPMatchId INT
		,MainRowNumber INT
		,IsRepresented BIT
		)

	CREATE TABLE #tblRuleChecking (
		RowNumber INT
		,MinorBettypeId INT
		,IsFalse INT
		)

	CREATE TABLE #tblParentMatch (
		OWPMatchId INT
		,RowNumber INT
		,EventDate DATE
		,KickOffTime TIME
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		)

	--Existing matches
	UPDATE au
	SET au.MinorBettypeId = mm.MinorBettypeId
		,au.ParentMatchId = mm.ParentMatchId
	FROM dbo.AssignmentUploading AS au WITH (ROWLOCK, UPDLOCK)
		INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON au.MatchId = mm.MinorMatchId
	WHERE au.SessionId = @SessionId

	--New matches
	INSERT INTO #tblMatchListNew (
		RowNumber
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		)
	SELECT au.RowNumber
		,au.EventDate
		,CASE 
			WHEN ISDATE(KickOffTime) = 1 THEN CAST(au.KickOffTime AS TIME)
			ELSE NULL
			END
		,au.League
		,au.Home
		,au.Away
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	WHERE au.SessionId = @SessionId
		AND ISNULL(MatchId, '') = ''

	INSERT INTO #tblRuleChecking (
		RowNumber
		,MinorBettypeId
		,IsFalse
		)
	SELECT ml.RowNumber
		,mmd.MinorBettypeId
		,CASE 
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 1
				AND EXISTS (
					SELECT 1
					FROM dbo.fnc_SplitStrings(mmd.Value, ',')
					WHERE ml.League LIKE '%' + val + '%'
					) THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 1
				AND ml.League NOT LIKE '%' + mmd.Value + '%' THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 2
				AND EXISTS (
					SELECT 1
					FROM dbo.fnc_SplitStrings(mmd.Value, ',')
					WHERE ml.Home LIKE '%' + val + '%'
					) THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 2
				AND ml.Home NOT LIKE '%' + mmd.Value + '%' THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 3
				AND EXISTS (
					SELECT 1
					FROM dbo.fnc_SplitStrings(mmd.Value, ',')
					WHERE ml.Away LIKE '%' + val + '%'
					) THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 3
				AND ml.Away NOT LIKE '%' + mmd.Value + '%' THEN 0
			ELSE 1
			END
	FROM #tblMatchListNew AS ml
		,dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
	WHERE mmd.Field IN (1, 2, 3)

	--SELECT RowNumber
	--	,MinorBettypeId
	--	,IsFalse
	--FROM #tblRuleChecking WITH (NOLOCK)

	UPDATE ml
	SET ml.MinorBettypeId = rc.MinorBettypeId
	FROM #tblMatchListNew AS ml
		INNER JOIN (
		SELECT RowNumber
			,MinorBettypeId
		FROM #tblRuleChecking WITH (NOLOCK)
		GROUP BY RowNumber
			,MinorBettypeId
		HAVING SUM(IsFalse) = 0
		) rc ON ml.RowNumber = rc.RowNumber

	IF NOT EXISTS (
			SELECT 1
			FROM #tblMatchListNew AS ml WITH (NOLOCK)
			WHERE ml.MinorBettypeId IS NOT NULL
			)
	BEGIN
		DROP TABLE #tblMatchListNew

		DROP TABLE #tblRuleChecking

		RETURN
	END

	--Parent Match
	INSERT INTO #tblParentMatch (
		RowNumber
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		)
	SELECT au.RowNumber
		,au.EventDate
		,CASE 
			WHEN ISDATE(KickOffTime) = 1 THEN CAST(au.KickOffTime AS TIME)
			ELSE NULL
			END
		,au.League
		,au.Home
		,au.Away
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	WHERE au.SessionId = @SessionId
		AND ISNULL(au.MatchId, '') = ''

	INSERT INTO #tblParentMatch (
		OWPMatchId
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		)
	SELECT om.OWPMatchId
		,om.EventDate
		,om.KickOffTime
		,l.OWPLeagueName
		,h.OWPTeamName
		,a.OWPTeamName
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON om.OWPLeagueId = l.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON om.OWPHomeId = h.OWPTeamId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON om.OWPAwayId = a.OWPTeamId
		INNER JOIN dbo.AssignmentUploading AS au WITH (NOLOCK) ON om.EventDate = au.EventDate
	WHERE au.SessionId = @SessionId

	UPDATE ml
	SET ml.MainLeague = RTRIM(LEFT(ml.League, LEN(ml.League) - c.LeagueChars))
		,ml.MainHome = CASE ISNULL(c.HomeChars, 0)
			WHEN 0 THEN ml.Home
			ELSE RTRIM(LEFT(ml.Home, LEN(ml.Home) - c.HomeChars))
			END
		,ml.MainAway = CASE ISNULL(c.AwayChars, 0)
			WHEN 0 THEN ml.Away
			ELSE RTRIM(LEFT(ml.Away, LEN(ml.Away) - c.AwayChars))
			END
	FROM #tblMatchListNew AS ml
		INNER JOIN (
		SELECT mmd.MinorBettypeId
			,MAX(CASE mmd.Field
					WHEN 4 THEN CAST(mmd.Value AS INT)
					END) 'LeagueChars'
			,MAX(CASE mmd.Field
					WHEN 5 THEN CAST(mmd.Value AS INT)
					END) 'HomeChars'
			,MAX(CASE mmd.Field
					WHEN 6 THEN CAST(mmd.Value AS INT)
					END) 'AwayChars'
		FROM dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
		WHERE mmd.Field IN (4, 5, 6)
		GROUP BY mmd.MinorBettypeId
		) c ON ml.MinorBettypeId = c.MinorBettypeId
	WHERE LEN(ml.League) - c.LeagueChars > 0
		AND LEN(ml.Home) - ISNULL(c.HomeChars, 0) > 0
		AND LEN(ml.Away) - ISNULL(c.AwayChars, 0) > 0

	UPDATE ml
	SET ml.MainOWPMatchId = pm.OWPMatchId
		,ml.MainRowNumber = pm.RowNumber
	FROM #tblMatchListNew AS ml
		INNER JOIN #tblParentMatch AS pm ON ml.MainLeague = pm.League
		INNER JOIN (
		SELECT mmd.MinorBettypeId
			,MAX(CASE mmd.Field
					WHEN 4 THEN CAST(mmd.Value AS INT)
					END) 'LeagueChars'
			,MAX(CASE mmd.Field
					WHEN 5 THEN CAST(mmd.Value AS INT)
					END) 'HomeChars'
			,MAX(CASE mmd.Field
					WHEN 6 THEN CAST(mmd.Value AS INT)
					END) 'AwayChars'
		FROM dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
		WHERE mmd.Field IN (4, 5, 6)
		GROUP BY mmd.MinorBettypeId
		) c ON ml.MinorBettypeId = c.MinorBettypeId
	WHERE (
			(
				ISNULL(c.HomeChars, 0) = 0
				AND ISNULL(c.AwayChars, 0) = 0
				AND ml.Home LIKE '%' + pm.Home + '%'
				)
			OR (
				ISNULL(c.HomeChars, 0) > 0
				AND ISNULL(c.AwayChars, 0) > 0
				AND (
					(
						ml.MainHome = pm.Home
						AND ml.MainAway = pm.Away
						)
					OR (
						ml.MainHome = pm.Home
						AND ml.MainAway = pm.Home
						)
					OR (
						ml.MainHome = pm.Away
						AND ml.MainAway = pm.Away
						)
					)
				)
			)
		AND ml.EventDate = pm.EventDate
		AND ml.KickOffTime = pm.KickOffTime

	UPDATE au
	SET au.MinorBettypeId = ml.MinorBettypeId
		,au.ParentRowNumber = ml.MainRowNumber
	FROM dbo.AssignmentUploading AS au WITH (ROWLOCK, UPDLOCK)
		INNER JOIN #tblMatchListNew AS ml ON au.RowNumber = ml.RowNumber
	WHERE au.SessionId = @SessionId

	UPDATE au
	SET au.MinorBettypeId = ml.MinorBettypeId
		,au.ParentMatchId = ml.MainOWPMatchId
	FROM dbo.AssignmentUploading AS au WITH (ROWLOCK, UPDLOCK)
		INNER JOIN #tblMatchListNew AS ml WITH (NOLOCK) ON au.RowNumber = ml.RowNumber
	WHERE au.SessionId = @SessionId

	DROP TABLE #tblMatchListNew

	DROP TABLE #tblRuleChecking

	DROP TABLE #tblParentMatch
END