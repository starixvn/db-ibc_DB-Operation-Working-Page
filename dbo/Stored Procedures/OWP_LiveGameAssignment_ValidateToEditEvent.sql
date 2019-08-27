
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_ValidateToEditEvent] @OWPMatchId INT
	,@KickOffTime TIME(7)
	,@LeagueName NVARCHAR(500)
	,@MatchNo NVARCHAR(50) = ''
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
	,@MinorBettypeId INT = NULL OUTPUT
	,@ParentMatchId INT = NULL OUTPUT
AS
/*
 Created: 20190813@Kane.Le
 Task : validate input before to edit event
 DB: bodb_OWP

 Revisions:
	20190813@Kane.Le: Initial SP - [Feature: #117960]	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @EventDate DATE
		,@ExistedMatchId INT
		,@OldParentMatchId INT
		,@MatchSettingBettype_XMin INT = - 1001
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
		,@OWPLeagueId INT
		,@OWPHomeTeamId INT
		,@OWPAwayTeamId INT
		,@OldKickOffTime TIME
		,@OldOWPLeagueName NVARCHAR(500)
		,@OldOWPHomeName NVARCHAR(200)
		,@OldOWPAwayName NVARCHAR(200)
		,@OldMatchNo NVARCHAR(200)

	SELECT @OWPLeagueId = m.OWPLeagueId
		,@OWPHomeTeamId = m.OWPHomeId
		,@OWPAwayTeamId = m.OWPAwayId
		,@OldMatchNo = m.MatchNo
		,@OldKickOffTime = m.KickOffTime
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	WHERE m.OWPMatchId = @OWPMatchId

	SELECT @OldOWPLeagueName = l.OWPLeagueName
	FROM dbo.OWPLeague AS l WITH (NOLOCK)
	WHERE l.OWPLeagueId = @OWPLeagueId

	SELECT @OldOWPHomeName = l.OWPTeamName
	FROM dbo.OWPTeam AS l WITH (NOLOCK)
	WHERE l.OWPTeamId = @OWPHomeTeamId

	SELECT @OldOWPAwayName = l.OWPTeamName
	FROM dbo.OWPTeam AS l WITH (NOLOCK)
	WHERE l.OWPTeamId = @OWPAwayTeamId

	IF @OldOWPLeagueName = @LeagueName
		AND @OldOWPHomeName = @HomeName
		AND @OldOWPAwayName = @AwayName
		AND @OldMatchNo = @MatchNo
		AND @OldKickOffTime = @KickOffTime
	BEGIN
		SELECT @ErrCode = - 1
			,@ErrMsg = 'Event information has no change!'

		RETURN
	END

	SELECT @EventDate = EventDate
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	WHERE m.OWPMatchId = @OWPMatchId

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')

	-- check match is existed
	IF EXISTS (
			SELECT 1
			FROM dbo.OWPMatch AS m WITH (NOLOCK)
			WHERE m.OWPMatchId = @OWPMatchId
				AND @OldOWPHomeName = @HomeName
				AND @OldOWPAwayName = @AwayName
				AND @OldMatchNo = @MatchNo
				AND @OldKickOffTime = @KickOffTime
				AND m.EventDateTime BETWEEN @FromDate
					AND @ToDate
			)
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'This match is not existing, please check it !'

		RETURN
	END

	DECLARE @tblOWPMatchByEventDate TABLE (
		RowNumber INT IDENTITY
		,OWPMatchId INT
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,MatchNo NVARCHAR(50)
		)
	DECLARE @tblSpecialEventTemplate TABLE (
		RowNumber INT IDENTITY
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,ParentMatchId INT
		,MinorBettypeId INT
		,MinorMatchId INT
		)
	DECLARE @tblMinorBettypeId TABLE (
		RowNumber INT IDENTITY
		,MinorMatchId INT
		,MinorBettypeId INT
		,ParentMatchId INT
		)

	INSERT INTO @tblOWPMatchByEventDate (
		OWPMatchId
		,LeagueName
		,HomeName
		,AwayName
		,MatchNo
		)
	SELECT m.OWPMatchId
		,l.OWPLeagueName
		,h.OWPTeamName
		,a.OWPTeamName
		,m.MatchNo
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
	WHERE m.OWPMatchId <> @OWPMatchId
		AND m.EventDateTime BETWEEN @FromDate
			AND @ToDate

	INSERT INTO @tblMinorBettypeId
	SELECT mm.MinorMatchId
		,mm.MinorBettypeId
		,mm.ParentMatchId
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
	WHERE ParentMatchId = @OWPMatchId

	DECLARE @LoopCounter INT = 1
		,@MaxRowCount INT
		,@MinorMatchId INT
		,@RowNumber INT

	SELECT @MaxRowCount = COUNT(*)
	FROM @tblMinorBettypeId

	WHILE (@LoopCounter <= @MaxRowCount)
	BEGIN
		SELECT @MinorBettypeId = MinorBettypeId
			,@ParentMatchId = ParentMatchId
			,@MinorMatchId = MinorMatchId
		FROM @tblMinorBettypeId
		WHERE @LoopCounter = RowNumber

		INSERT INTO @tblSpecialEventTemplate (
			LeagueName
			,HomeName
			,AwayName
			)
		EXEC [dbo].[OWP_LiveGameAssignment_GetSpecialEventTemplate_ByName] @LeagueName
			,@HomeName
			,@AwayName
			,@MinorBettypeId

		UPDATE @tblSpecialEventTemplate
		SET ParentMatchId = @ParentMatchId
			,MinorBettypeId = @MinorBettypeId
			,MinorMatchId = @MinorMatchId
		WHERE @LoopCounter = RowNumber

		SET @LoopCounter = @LoopCounter + 1
	END

	SELECT *
	FROM @tblSpecialEventTemplate

	SELECT *
	FROM @tblOWPMatchByEventDate

	-- check match is duplicated
	SELECT @ExistedMatchId = m.OWPMatchId
	FROM @tblOWPMatchByEventDate AS m
	WHERE m.OWPMatchId <> @OWPMatchId
		AND m.LeagueName = @LeagueName
		AND m.HomeName = @HomeName
		AND m.AwayName = @AwayName

	IF @ExistedMatchId IS NOT NULL
	BEGIN
		SELECT @ExistedMatchId = m.OWPMatchId
		FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON mm.ParentMatchId = m.OWPMatchId
		WHERE mm.MinorMatchId = @ExistedMatchId
			AND mm.MinorBettypeId IN (
				@MinorBettype_Specific15Mins
				,@MinorBettype_Specific10Mins
				,@MinorBettype_Specific15MinsNoOfCorners
				,@MinorBettype_Specific15MinsTotalBooking
				,@MinorBettype_FastMarket
				,@MinorBettype_AllInOne
				)

		SELECT @ErrCode = 1
			,@ErrMsg = 'This match is existing, please check it !'

		RETURN
	END

	IF EXISTS (
			SELECT 1
			FROM @tblOWPMatchByEventDate AS m
			JOIN @tblSpecialEventTemplate t ON m.LeagueName = t.LeagueName
				AND m.HomeName = t.HomeName
				AND m.AwayName = t.AwayName
			)
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'This match is existing, please check it !'

		RETURN
	END

	IF @MatchNo <> ''
		AND EXISTS (
			SELECT 1
			FROM @tblOWPMatchByEventDate AS m
			WHERE m.MatchNo = @MatchNo
			)
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'The Match No. is used. Please choose another one.'

		RETURN
	END

	SELECT @OldParentMatchId = mn.ParentMatchId
	FROM dbo.MinorMatch AS mn WITH (NOLOCK)
	WHERE mn.ParentMatchId = @OWPMatchId

	IF @OldParentMatchId IS NOT NULL
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM dbo.MinorMatch AS m WITH (NOLOCK)
				WHERE m.ParentMatchId = @OldParentMatchId
					AND m.MinorBettypeId NOT IN (
						- 1
						,- 2
						,- 88
						,- 89
						)
				)
		BEGIN
			SELECT @ErrCode = 1
				,@ErrMsg = 'This match is existing minor match, please check it !'

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
					AND @LeagueName LIKE '%' + mmd.[Value] + '%'
					THEN 0
				WHEN mmd.[Condition] = 2
					AND mmd.Field = 1
					AND @LeagueName NOT LIKE '%' + mmd.[Value] + '%'
					THEN 0
				WHEN mmd.[Condition] = 1
					AND mmd.Field = 2
					AND @HomeName LIKE '%' + mmd.[Value] + '%'
					THEN 0
				WHEN mmd.[Condition] = 2
					AND mmd.Field = 2
					AND @HomeName NOT LIKE '%' + mmd.[Value] + '%'
					THEN 0
				WHEN mmd.[Condition] = 1
					AND mmd.Field = 3
					AND @AwayName LIKE '%' + mmd.[Value] + '%'
					THEN 0
				WHEN mmd.[Condition] = 2
					AND mmd.Field = 3
					AND @AwayName NOT LIKE '%' + mmd.[Value] + '%'
					THEN 0
				ELSE 1
				END
		FROM dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
		WHERE mmd.Field IN (
				1
				,2
				,3
				)

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
						WHEN 4
							THEN CAST(mmd.Value AS INT)
						END)
				,@HomeChars = MAX(CASE mmd.Field
						WHEN 5
							THEN CAST(mmd.Value AS INT)
						END)
				,@AwayChars = MAX(CASE mmd.Field
						WHEN 6
							THEN CAST(mmd.Value AS INT)
						END)
			FROM dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
			WHERE mmd.MinorBettypeId = @MinorBettypeId
				AND mmd.Field IN (
					4
					,5
					,6
					)

			IF LEN(@LeagueName) > @LeagueChars
				AND LEN(@HomeName) > @HomeChars
				AND LEN(@AwayName) > @AwayChars
			BEGIN
				IF @MinorBettypeId NOT IN (
						1111
						,1112
						,1113
						) -- ignore Hard code Single team bettype
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
								AND h.OWPTeamName = RTRIM(LEFT(@AwayName, LEN(@AwayName) - @AwayChars))
								THEN 1
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
							WHEN 1111
								THEN CASE @SingleTeamType
										WHEN 1
											THEN @MinorBettype_HomeSingleTeamOU
										WHEN 2
											THEN @MinorBettype_AwaySingleTeamOU
										END
							WHEN 1112
								THEN CASE @SingleTeamType
										WHEN 1
											THEN @MinorBettype_HomeSingleTeamOUOfCorners
										WHEN 2
											THEN @MinorBettype_AwaySingleTeamOUOfCorners
										END
							WHEN 1113
								THEN CASE @SingleTeamType
										WHEN 1
											THEN @MinorBettype_HomePenShootOut
										WHEN 2
											THEN @MinorBettype_AwayPenShootOut
										END
							END
				END
			END
		END

		IF @OldParentMatchId = @ParentMatchId
			SELECT @ParentMatchId = NULL
				,@MinorBettypeId = NULL

		SELECT @ErrCode = 0
			,@ErrMsg = ''

		RETURN
	END

	-- determine minor match
	SELECT @ParentMatchId = NULL
		,@ErrCode = 0
		,@ErrMsg = ''
END