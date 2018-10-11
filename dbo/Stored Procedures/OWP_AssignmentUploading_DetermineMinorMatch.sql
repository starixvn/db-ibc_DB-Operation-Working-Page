/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AssignmentUploading_DetermineMinorMatch] @SessionId VARCHAR(50)
AS
/*
Created: 20180621@Leo
Task : Determine minor for assignment uploading
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Raymond.Le: new structure  
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @HomeSingleTeamOU INT = - 92
		,@AwaySingleTeamOU INT = - 93
		,@HomeSingleTeamOUOfCorners INT = - 94
		,@AwaySingleTeamOUOfCorners INT = - 95
		,@HomePenShootOut INT = - 98
		,@AwayPenShootOut INT = - 99

	CREATE TABLE #tblRuleChecking (
		RowNumber INT
		,MinorBettypeId INT
		,IsFalse INT
		)

	CREATE TABLE #tblSingleTeamMatch (
		RowNumber INT
		,MinorBettypeId INT
		,TeamType INT
		,ParentRowNumber INT
		)

	-- list of validation rules for valid matches
	INSERT INTO #tblRuleChecking (
		RowNumber
		,MinorBettypeId
		,IsFalse
		)
	SELECT au.RowNumber
		,mmd.MinorBettypeId
		,CASE 
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 1
				AND au.League LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 1
				AND au.League NOT LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 2
				AND au.Home LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 2
				AND au.Home NOT LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 3
				AND au.Away LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 3
				AND au.Away NOT LIKE '%' + mmd.[Value] + '%' THEN 0
			ELSE 1
			END
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
		CROSS JOIN dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
	WHERE au.SessionId = @SessionId
		AND ISDATE(KickOffTime) = 1
		AND (
			au.MatchId = ''
			OR ISNUMERIC(MatchId) = 1
			)
		AND mmd.Field IN (1, 2, 3)

	-- update MinorBettypeId if match is minor
	UPDATE au
	SET au.MinorBettypeId = rc.MinorBettypeId
	FROM dbo.AssignmentUploading AS au WITH (ROWLOCK)
		INNER JOIN (
		SELECT RowNumber
			,MinorBettypeId
		FROM #tblRuleChecking WITH (NOLOCK)
		GROUP BY RowNumber
			,MinorBettypeId
		HAVING SUM(IsFalse) = 0
		) rc ON au.RowNumber = rc.RowNumber
	WHERE au.SessionId = @SessionId

	-- update ParentRowNumber of minor matches
	UPDATE minor
	SET minor.ParentRowNumber = main.RowNumber
	FROM (
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
			INNER JOIN dbo.AssignmentUploading AS au WITH (NOLOCK) ON au.SessionId = @SessionId
			AND au.MinorBettypeId = mmd.MinorBettypeId
		WHERE mmd.Field IN (4, 5, 6)
			AND mmd.MinorBettypeId NOT IN (1111, 1112, 1113) -- ignore Hard code Single team bettype
		GROUP BY mmd.MinorBettypeId
		) AS r
		INNER JOIN dbo.AssignmentUploading AS minor WITH (ROWLOCK) ON minor.SessionId = @SessionId
		AND minor.MinorBettypeId = r.MinorBettypeId
		INNER JOIN dbo.AssignmentUploading AS main WITH (NOLOCK) ON main.SessionId = @SessionId
		AND main.MinorBettypeId IS NULL
		AND LEN(minor.League) - r.LeagueChars > 0
		AND LEN(minor.Home) - r.HomeChars > 0
		AND LEN(minor.Away) - r.AwayChars > 0
		AND main.League = RTRIM(LEFT(minor.League, LEN(minor.League) - r.LeagueChars))
		AND main.Home = RTRIM(LEFT(minor.Home, LEN(minor.Home) - r.HomeChars))
		AND main.Away = RTRIM(LEFT(minor.Away, LEN(minor.Away) - r.AwayChars))

	-- handle single team minor match
	INSERT INTO #tblSingleTeamMatch (
		RowNumber
		,MinorBettypeId
		,TeamType
		,ParentRowNumber
		)
	SELECT minor.RowNumber
		,minor.MinorBettypeId
		,CASE 
			WHEN (main.Home = RTRIM(LEFT(minor.Away, LEN(minor.Away) - r.AwayChars)))
				AND (main.Home = RTRIM(LEFT(minor.Home, LEN(minor.Home) - r.HomeChars))) THEN 1
			WHEN (main.Away = RTRIM(LEFT(minor.Away, LEN(minor.Away) - r.AwayChars)))
				AND (main.Away = RTRIM(LEFT(minor.Home, LEN(minor.Home) - r.HomeChars))) THEN 2
			ELSE NULL
			END
		,main.RowNumber AS ParentRowNumber
	FROM (
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
			INNER JOIN dbo.AssignmentUploading AS au WITH (NOLOCK) ON au.SessionId = @SessionId
			AND au.MinorBettypeId = mmd.MinorBettypeId
		WHERE mmd.Field IN (4, 5, 6)
			AND mmd.MinorBettypeId IN (1111, 1112, 1113)
		GROUP BY mmd.MinorBettypeId
		) AS r
		INNER JOIN dbo.AssignmentUploading AS minor WITH (ROWLOCK) ON minor.SessionId = @SessionId
		AND minor.MinorBettypeId = r.MinorBettypeId
		INNER JOIN dbo.AssignmentUploading AS main WITH (NOLOCK) ON main.SessionId = @SessionId
		AND main.MinorBettypeId IS NULL
		AND LEN(minor.League) - r.LeagueChars > 0
		AND LEN(minor.Home) - r.HomeChars > 0
		AND LEN(minor.Away) - r.AwayChars > 0
		AND (main.League = RTRIM(LEFT(minor.League, LEN(minor.League) - r.LeagueChars)))-- test nh?ng case match cha league, home gi?ng nhung away khác 

	--Update real id for single team bettype
	UPDATE au
	SET au.MinorBettypeId = st.RealMinorBettype
		,au.ParentRowNumber = st.ParentRowNumber
	FROM dbo.AssignmentUploading AS au WITH (ROWLOCK)
		INNER JOIN (
		SELECT st.RowNumber
			,ParentRowNumber
			,(CASE 
				WHEN st.MinorBettypeId = 1111
					AND st.TeamType = 1 THEN @HomeSingleTeamOU
				WHEN st.MinorBettypeId = 1111
					AND st.TeamType = 2 THEN @AwaySingleTeamOU
				WHEN st.MinorBettypeId = 1112
					AND st.TeamType = 1 THEN @HomeSingleTeamOUOfCorners
				WHEN st.MinorBettypeId = 1112
					AND st.TeamType = 2 THEN @AwaySingleTeamOUOfCorners
				WHEN st.MinorBettypeId = 1113
					AND st.TeamType = 1 THEN @HomePenShootOut
				WHEN st.MinorBettypeId = 1113
					AND st.TeamType = 2 THEN @AwayPenShootOut END
				) AS RealMinorBettype
		FROM #tblSingleTeamMatch AS st
		WHERE st.TeamType IS NOT NULL
		) AS st ON au.RowNumber = st.RowNumber
		AND au.SessionId = @SessionId

	--update minor matches as main matches if has no ParentRowNumber
	UPDATE au
	SET MinorBettypeId = NULL
	FROM dbo.AssignmentUploading AS au WITH (ROWLOCK)
	WHERE au.SessionId = @SessionId
		AND au.MinorBettypeId IS NOT NULL
		AND au.ParentRowNumber IS NULL

	-- drop tables
	DROP TABLE #tblRuleChecking

	DROP TABLE #tblSingleTeamMatch
END