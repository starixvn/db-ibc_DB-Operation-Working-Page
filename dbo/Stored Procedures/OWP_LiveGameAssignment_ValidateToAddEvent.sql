
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_ValidateToAddEvent] @EventDate DATE
	,@KickOffTime TIME(7)
	,@MatchStatus VARCHAR(10)
	,@LeagueName NVARCHAR(500)
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@MatchSettingBettypeIds VARCHAR(100) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
	,@ExistedMatchId INT = NULL OUTPUT
	,@MinorBettypeId INT = NULL OUTPUT
	,@ParentMatchId INT = NULL OUTPUT
AS
/*
 Created: 20190724@Leo.Vo
 Task : validate input before to add new event
 DB: bodb_OWP

 Revisions:
	20190724@Leo.Vo: Initial SP - [Feature: #117461]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @MatchSettingBettype_XMin INT = - 1001
		,@MatchSettingBettype_FastMarket INT = - 1003
		,@MatchSettingBettype_AllInOne INT = - 1004
		,@MinorBettype_FastMarket INT = - 88
		,@MinorBettype_AllInOne INT = - 89
		,@MinorBettype_TotalBooking INT = - 6
		,@MinorBettype_NoOfCorner INT = - 3
		,@MinorBettype_Specific15Mins INT = - 1
		,@MinorBettype_Specific10Mins INT = - 2
		,@MinorBettype_Specific15MinsNoOfCorners INT = - 5
		,@MinorBettype_Specific15MinsTotalBooking INT = - 8
		,@MinorBettype_HomeSingleTeamOU INT = - 92
		,@MinorBettype_AwaySingleTeamOU INT = - 93
		,@MinorBettype_HomeSingleTeamOUOfCorners INT = - 94
		,@MinorBettype_AwaySingleTeamOUOfCorners INT = - 95
		,@MinorBettype_HomePenShootOut INT = - 98
		,@MinorBettype_AwayPenShootOut INT = - 99
	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')

	-- check match is existed
	SELECT @ExistedMatchId = m.OWPMatchId
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
	WHERE l.OWPLeagueName = @LeagueName
		AND h.OWPTeamName = @HomeName
		AND a.OWPTeamName = @AwayName
		AND m.EventDateTime BETWEEN @FromDate
			AND @ToDate

	IF @ExistedMatchId IS NOT NULL
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'This match is existing, please check it !'

		RETURN
	END

	-- determine minor match
	CREATE TABLE #tblRuleChecking (
		MinorBettypeId INT
		,IsFalse INT
		)

	INSERT INTO #tblRuleChecking (
		MinorBettypeId
		,IsFalse
		)
	SELECT mmd.MinorBettypeId
		,CASE 
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 1
				AND @LeagueName LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 1
				AND @LeagueName NOT LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 2
				AND @HomeName LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 2
				AND @HomeName NOT LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 3
				AND @AwayName LIKE '%' + mmd.[Value] + '%' THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 3
				AND @AwayName NOT LIKE '%' + mmd.[Value] + '%' THEN 0
			ELSE 1
			END
	FROM dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
	WHERE mmd.Field IN (1, 2, 3)

	SELECT @MinorBettypeId = MinorBettypeId
	FROM #tblRuleChecking WITH (NOLOCK)
	GROUP BY MinorBettypeId
	HAVING SUM(IsFalse) = 0

	DROP TABLE #tblRuleChecking

	IF @MinorBettypeId IS NOT NULL
	BEGIN
		DECLARE @LeagueChars INT
			,@HomeChars INT
			,@AwayChars INT

		SELECT @LeagueChars = MAX(CASE mmd.Field
					WHEN 4 THEN CAST(mmd.Value AS INT)
					END)
			,@HomeChars = MAX(CASE mmd.Field
					WHEN 5 THEN CAST(mmd.Value AS INT)
					END)
			,@AwayChars = MAX(CASE mmd.Field
					WHEN 6 THEN CAST(mmd.Value AS INT)
					END)
		FROM dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
		WHERE mmd.MinorBettypeId = @MinorBettypeId
			AND mmd.Field IN (4, 5, 6)

		IF LEN(@LeagueName) > @LeagueChars
			AND LEN(@HomeName) > @HomeChars
			AND LEN(@AwayName) > @AwayChars
		BEGIN
			IF @MinorBettypeId NOT IN (1111, 1112, 1113) -- ignore Hard code Single team bettype
			BEGIN
				SELECT @ParentMatchId = m.OWPMatchId
				FROM dbo.OWPMatch AS m WITH (NOLOCK)
					INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
					INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
					INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
				WHERE m.EventDateTime BETWEEN @FromDate
						AND @ToDate
					AND l.OWPLeagueName = RTRIM(LEFT(@LeagueName, LEN(@LeagueName) - @LeagueChars))
					AND h.OWPTeamName = RTRIM(LEFT(@HomeName, LEN(@HomeName) - @HomeChars))
					AND a.OWPTeamName = RTRIM(LEFT(@AwayName, LEN(@AwayName) - @AwayChars))
			END
			ELSE
			BEGIN
				DECLARE @SingleTeamType SMALLINT

				SELECT @ParentMatchId = m.OWPMatchId
					,@SingleTeamType = CASE 
						WHEN h.OWPTeamName = RTRIM(LEFT(@HomeName, LEN(@HomeName) - @HomeChars))
							AND h.OWPTeamName = RTRIM(LEFT(@AwayName, LEN(@AwayName) - @AwayChars)) THEN 1
						ELSE 2
						END
				FROM dbo.OWPMatch AS m WITH (NOLOCK)
					INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
					INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
					INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
				WHERE m.EventDateTime BETWEEN @FromDate
						AND @ToDate
					AND l.OWPLeagueName = RTRIM(LEFT(@LeagueName, LEN(@LeagueName) - @LeagueChars))
					AND (
						(
							h.OWPTeamName = RTRIM(LEFT(@HomeName, LEN(@HomeName) - @HomeChars))
							AND h.OWPTeamName = RTRIM(LEFT(@AwayName, LEN(@AwayName) - @AwayChars))
							)
						OR (
							a.OWPTeamName = RTRIM(LEFT(@HomeName, LEN(@HomeName) - @HomeChars))
							AND a.OWPTeamName = RTRIM(LEFT(@AwayName, LEN(@AwayName) - @AwayChars))
							)
						)

				SELECT @MinorBettypeId = CASE @MinorBettypeId
						WHEN 1111 THEN CASE @SingleTeamType
								WHEN 1 THEN @MinorBettype_HomeSingleTeamOU
								WHEN 2 THEN @MinorBettype_AwaySingleTeamOU
								END
						WHEN 1112 THEN CASE @SingleTeamType
								WHEN 1 THEN @MinorBettype_HomeSingleTeamOUOfCorners
								WHEN 2 THEN @MinorBettype_AwaySingleTeamOUOfCorners
								END
						WHEN 1113 THEN CASE @SingleTeamType
								WHEN 1 THEN @MinorBettype_HomePenShootOut
								WHEN 2 THEN @MinorBettype_AwayPenShootOut
								END
						END
			END
		END

		IF @ParentMatchId IS NULL
			SELECT @MinorBettypeId = NULL
		ELSE
		BEGIN
			DECLARE @ParentKickOffTime DATETIME
				,@ParentMatchStatus VARCHAR(10)

			SELECT @LeagueName = l.OWPLeagueName
				,@HomeName = h.OWPTeamName
				,@AwayName = a.OWPTeamName
				,@ParentKickOffTime = m.KickOffTime
				,@ParentMatchStatus = mi.MatchStatus
			FROM dbo.OWPMatch AS m WITH (NOLOCK)
				INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
				INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
				INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
				INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
			WHERE m.OWPMatchId = @ParentMatchId

			IF CAST(@ParentKickOffTime AS TIME(7)) <> @KickOffTime
			BEGIN
				SELECT @ErrCode = 1
					,@ErrMsg = 'Minor match has KO Time different main match'

				RETURN
			END

			IF @ParentMatchStatus <> 'Live'
				AND @MatchStatus <> @ParentMatchStatus
			BEGIN
				SELECT @ErrCode = 1
					,@ErrMsg = 'Minor match has match status different main match'

				RETURN
			END
		END
	END

	DECLARE @tblMatchSettingBettypeIds TABLE (BettypeId INT)

	INSERT INTO @tblMatchSettingBettypeIds (BettypeId)
	SELECT val
	FROM dbo.fnc_SplitStrings(@MatchSettingBettypeIds, ',')
	WHERE val <> ''

	DECLARE @tblMinorMatch TABLE (
		MinorBettypeId INT
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		)
	DECLARE @tblValidMatchSettingBettypeIds TABLE (BettypeId INT)

	INSERT INTO @tblValidMatchSettingBettypeIds (BettypeId)
	SELECT BettypeId
	FROM dbo.MajorBettype
	WHERE BettypeId > 0

	IF @MinorBettypeId IS NULL
	BEGIN
		-- insert default minor match FM & AIO for main match
		INSERT INTO @tblMinorMatch (MinorBettypeId)
		VALUES (@MinorBettype_FastMarket)
			,(@MinorBettype_AllInOne)

		IF EXISTS (
				SELECT 1
				FROM @tblMatchSettingBettypeIds
				WHERE BettypeId = @MatchSettingBettype_XMin
				)
		BEGIN
			INSERT INTO @tblMinorMatch (MinorBettypeId)
			VALUES (@MinorBettype_Specific15Mins)
				,(@MinorBettype_Specific10Mins)

			INSERT INTO @tblValidMatchSettingBettypeIds (BettypeId)
			VALUES (@MatchSettingBettype_XMin)
		END

		INSERT INTO @tblValidMatchSettingBettypeIds (BettypeId)
		VALUES (@MatchSettingBettype_FastMarket)
			,(@MatchSettingBettype_AllInOne)
	END
	ELSE IF @MinorBettypeId = @MinorBettype_NoOfCorner
	BEGIN
		INSERT INTO @tblMinorMatch (MinorBettypeId)
		VALUES (@MinorBettype_Specific15MinsNoOfCorners)

		INSERT INTO @tblValidMatchSettingBettypeIds (BettypeId)
		VALUES (@MatchSettingBettype_XMin)
	END
	ELSE IF @MinorBettypeId = @MinorBettype_TotalBooking
	BEGIN
		INSERT INTO @tblMinorMatch (MinorBettypeId)
		VALUES (@MinorBettype_Specific15MinsTotalBooking)

		INSERT INTO @tblValidMatchSettingBettypeIds (BettypeId)
		VALUES (@MatchSettingBettype_XMin)
	END

	UPDATE mm
	SET mm.LeagueName = REPLACE(ts.League, '<name>', @LeagueName)
		,mm.HomeName = REPLACE(ts.Home, '<name>', @HomeName)
		,mm.AwayName = REPLACE(ts.Away, '<name>', @AwayName)
	FROM @tblMinorMatch AS mm
		INNER JOIN dbo.MinorMatchTemplateSetting AS ts WITH (NOLOCK) ON ts.MinorBettypeId = mm.MinorBettypeId

	DECLARE @ExistedMinorBettypeName NVARCHAR(MAX)

	SELECT @ExistedMinorBettypeName = STUFF((
				SELECT ', ' + mb.MinorBettypeName
				FROM dbo.OWPMatch AS m WITH (NOLOCK)
					INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
					INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
					INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
					INNER JOIN @tblMinorMatch AS mm ON l.OWPLeagueName = mm.LeagueName
					AND h.OWPTeamName = mm.HomeName
					AND a.OWPTeamName = mm.AwayName
					INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.MinorBettypeId
				WHERE m.EventDateTime BETWEEN @FromDate
						AND @ToDate
				FOR XML PATH('')
				), 1, 1, '')

	IF @ExistedMinorBettypeName IS NOT NULL
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Minor match is existed: ' + @ExistedMinorBettypeName
	END

	DECLARE @InvalidMatchSettingBettypes VARCHAR(2000) = STUFF((
				SELECT ',' + mb.ShortName
				FROM @tblMatchSettingBettypeIds AS s
					INNER JOIN dbo.MajorBettype AS mb WITH (NOLOCK) ON s.BettypeId = mb.BettypeId
					LEFT JOIN @tblValidMatchSettingBettypeIds AS t ON s.BettypeId = t.BettypeId
				WHERE t.BettypeId IS NULL
				FOR XML PATH('')
				), 1, 1, '')

	IF @InvalidMatchSettingBettypes IS NOT NULL
	BEGIN
		SELECT @ErrCode = 2
			,@ErrMsg = 'Unable to save trading info for bettypes: ' + @InvalidMatchSettingBettypes

		RETURN
	END

	SELECT @ErrCode = 0
		,@ErrMsg = ''
END