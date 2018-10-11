/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MinorMatchAutoDetermine]
AS
/*
Created: 20161101@Julien
Task : Initiate for auto determine Minor Match
DB: bodb_OWP

Param's Explanation:

Revisions:
    20170119@Julien	:	Link minor to main match by checking home & away are correct, even for singleteam bettype
    20170411@Tim.Trinh: fix bug and remove get data from bodb02
    20170727@Tim.Trinh: fix bug determine next cornor, next booking
    20171013@Tim.Trinh: allow determine yesterday event
	20180613@Jacob: Hotfix - Live Detail - Ignore representated
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @today DATE = DATEADD(DAY, -1, GETDATE())

	CREATE TABLE #tblRuleChecking (
		OWPMatchId INT
		,MinorBettypeId INT
		,IsFalse INT
		)

	CREATE TABLE #tblRepresentRuleChecking (
		OWPMatchId INT
		,MinorBettypeId INT
		,IsFalse INT
		)

	CREATE TABLE #tblMatchDetails (
		OWPMatchId INT
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
		,IsRepresented BIT
		)

	CREATE TABLE #tblMatchList (
		OWPMatchId INT
		,EventDate DATE
		,KickOffTime TIME
		,MatchId INT
		,LeagueId INT
		,HomeId INT
		,AwayId INT
		)

	INSERT INTO #tblMatchList (
		OWPMatchId
		,EventDate
		,KickOffTime
		,MatchId
		,LeagueId
		,HomeId
		,AwayId
		)
	SELECT om.OWPMatchId
		,om.EventDate
		,om.KickOffTime
		,om.MatchId
		,om.OWPLeagueId
		,om.OWPHomeId
		,om.OWPAwayId
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
	WHERE om.EventDate >= @today
		AND om.OWPMatchId NOT IN (
			SELECT mm.MinorMatchId
			FROM dbo.MinorMatch AS mm WITH (NOLOCK)
			)

	INSERT INTO #tblMatchDetails (
		OWPMatchId
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		)
	SELECT ml.OWPMatchId
		,ml.EventDate
		,ml.KickOffTime
		,ol.OWPLeagueName
		,h.OWPTeamName
		,a.OWPTeamName
	FROM #tblMatchList AS ml WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS ol WITH (NOLOCK) ON ml.LeagueId = ol.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON ml.HomeId = h.OWPTeamId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON ml.AwayId = a.OWPTeamId

	INSERT INTO #tblRuleChecking (
		OWPMatchId
		,MinorBettypeId
		,IsFalse
		)
	SELECT md.OWPMatchId
		,mmd.MinorBettypeId
		,CASE 
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 1
				AND EXISTS (
					SELECT 1
					FROM dbo.fnc_SplitStrings(mmd.Value, ',')
					WHERE md.League LIKE '%' + val + '%'
					) THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 1
				AND md.League NOT LIKE '%' + mmd.Value + '%' THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 2
				AND EXISTS (
					SELECT 1
					FROM dbo.fnc_SplitStrings(mmd.Value, ',')
					WHERE md.Home LIKE '%' + val + '%'
					) THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 2
				AND md.Home NOT LIKE '%' + mmd.Value + '%' THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 3
				AND EXISTS (
					SELECT 1
					FROM dbo.fnc_SplitStrings(mmd.Value, ',')
					WHERE md.Away LIKE '%' + val + '%'
					) THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 3
				AND md.Away NOT LIKE '%' + mmd.Value + '%' THEN 0
			ELSE 1
			END
	FROM #tblMatchDetails AS md
		,dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
	WHERE mmd.Field IN (1, 2, 3)

	UPDATE md
	SET md.MinorBettypeId = rc.MinorBettypeId
	FROM #tblMatchDetails AS md
		INNER JOIN (
		SELECT OWPMatchId
			,MinorBettypeId
		FROM #tblRuleChecking WITH (NOLOCK)
		GROUP BY OWPMatchId
			,MinorBettypeId
		HAVING SUM(IsFalse) = 0
		) rc ON md.OWPMatchId = rc.OWPMatchId

	IF NOT EXISTS (
			SELECT 1
			FROM #tblMatchDetails AS md
			WHERE md.MinorBettypeId IS NOT NULL
			)
	BEGIN
		DROP TABLE #tblRuleChecking

		DROP TABLE #tblMatchList

		DROP TABLE #tblMatchDetails

		DROP TABLE #tblRepresentRuleChecking

		RETURN
	END

	UPDATE md
	SET md.MainLeague = RTRIM(LEFT(md.League, LEN(md.League) - c.LeagueChars))
		,md.MainHome = CASE ISNULL(c.HomeChars, 0)
			WHEN 0 THEN md.Home
			ELSE RTRIM(LEFT(md.Home, LEN(md.Home) - c.HomeChars))
			END
		,md.MainAway = CASE ISNULL(c.AwayChars, 0)
			WHEN 0 THEN md.Away
			ELSE RTRIM(LEFT(md.Away, LEN(md.Away) - c.AwayChars))
			END
	FROM #tblMatchDetails AS md
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
		) c ON md.MinorBettypeId = c.MinorBettypeId
	WHERE LEN(md.League) - c.LeagueChars > 0
		AND LEN(md.Home) - ISNULL(c.HomeChars, 0) > 0
		AND LEN(md.Away) - ISNULL(c.AwayChars, 0) > 0

	UPDATE md
	SET md.MainOWPMatchId = mmd.OWPMatchId
	FROM #tblMatchDetails AS md
		INNER JOIN (
		SELECT mmd1.MinorBettypeId
			,MAX(CASE mmd1.Field
					WHEN 4 THEN CAST(mmd1.Value AS INT)
					END) 'LeagueChars'
			,MAX(CASE mmd1.Field
					WHEN 5 THEN CAST(mmd1.Value AS INT)
					END) 'HomeChars'
			,MAX(CASE mmd1.Field
					WHEN 6 THEN CAST(mmd1.Value AS INT)
					END) 'AwayChars'
		FROM dbo.MinorMatchDetemination AS mmd1 WITH (NOLOCK)
		WHERE mmd1.Field IN (4, 5, 6)
		GROUP BY mmd1.MinorBettypeId
		) c ON md.MinorBettypeId = c.MinorBettypeId
		INNER JOIN #tblMatchDetails AS mmd ON md.MainLeague = mmd.League
	WHERE (
			(
				ISNULL(c.HomeChars, 0) = 0
				AND ISNULL(c.AwayChars, 0) = 0
				AND md.Home LIKE '%' + mmd.Home + '%'
				)
			OR (
				ISNULL(c.HomeChars, 0) > 0
				AND ISNULL(c.AwayChars, 0) > 0
				AND (
					(
						md.MainHome = mmd.Home
						AND md.MainAway = mmd.Away
						)
					OR (
						md.MainHome = mmd.Home
						AND md.MainAway = mmd.Home
						)
					OR (
						md.MainHome = mmd.Away
						AND md.MainAway = mmd.Away
						)
					)
				)
			)
		AND md.EventDate = mmd.EventDate
		AND md.KickOffTime = mmd.KickOffTime

	INSERT INTO #tblRepresentRuleChecking (
		OWPMatchId
		,MinorBettypeId
		,IsFalse
		)
	SELECT md.OWPMatchId
		,mmd.MinorBettypeId
		,CASE 
			WHEN mmd.CONDITION = 1
				AND mmd.Field = 7
				AND md.Home LIKE '%' + ISNULL(NULLIF(mmd.Value, ''), md1.Home) + '%' THEN 0
			WHEN mmd.CONDITION = 2
				AND mmd.Field = 7
				AND md.Home NOT LIKE '%' + ISNULL(NULLIF(mmd.Value, ''), md1.Home) + '%' THEN 0
			WHEN mmd.CONDITION = 1
				AND mmd.Field = 8
				AND md.Away LIKE '%' + ISNULL(NULLIF(mmd.Value, ''), md1.Away) + '%' THEN 0
			WHEN mmd.CONDITION = 2
				AND mmd.Field = 8
				AND md.Away NOT LIKE '%' + ISNULL(NULLIF(mmd.Value, ''), md1.Away) + '%' THEN 0
			ELSE 1
			END
	FROM #tblMatchDetails AS md
		INNER JOIN dbo.MinorMatchDetemination AS mmd WITH (NOLOCK) ON md.MinorBettypeId = mmd.MinorBettypeId
		INNER JOIN #tblMatchDetails AS md1 ON md.MainOWPMatchId = md1.OWPMatchId
	WHERE mmd.Field IN (7, 8)
		AND md.MinorBettypeId IS NOT NULL

	UPDATE md
	SET md.IsRepresented = 1
	FROM #tblMatchDetails AS md
		INNER JOIN (
		SELECT OWPMatchId
			,MinorBettypeId
		FROM #tblRepresentRuleChecking
		GROUP BY OWPMatchId
			,MinorBettypeId
		HAVING SUM(IsFalse) = 0
		) rc ON md.OWPMatchId = rc.OWPMatchId

	INSERT INTO dbo.MinorMatch (
		MinorMatchId
		,ParentMatchId
		,MinorBettypeId
		,IsRepresented
		)
	SELECT md.OWPMatchId
		,md.MainOWPMatchId
		,md.MinorBettypeId
		,ISNULL(md.IsRepresented, 1)
	FROM #tblMatchDetails AS md
	WHERE md.MinorBettypeId IS NOT NULL
		AND md.MainOWPMatchId IS NOT NULL
		AND md.OWPMatchId NOT IN (
			SELECT MinorMatchId
			FROM dbo.MinorMatch WITH (NOLOCK)
			)

	DROP TABLE #tblRuleChecking

	DROP TABLE #tblMatchList

	DROP TABLE #tblMatchDetails

	DROP TABLE #tblRepresentRuleChecking
END