
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateRecommendOdds] @UserId INT
	,@SessionId NVARCHAR(50) = NULL
	,@Id INT
	,@Handicap SMALLMONEY
	,@TeamChoice TINYINT
	,@RecommendOdds NVARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161205@Tim.Trinh
Task : update recommend odds
DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
	20190308@Kane.Le: add Notification Watcher - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@OldTeamName NVARCHAR(50) = ''
		,@TeamName NVARCHAR(50) = ''
		,@OldHandicapText NVARCHAR(50) = ''
		,@HandicapText NVARCHAR(50) = ''
		,@BettypeName NVARCHAR(50) = ''
		,@OldOddsText NVARCHAR(50) = ''
		,@NewOddsText NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT
		,@OWPMatchId INT
		,@Bettype INT
		,@OldHandicap SMALLMONEY
		,@OldTeamChoice TINYINT
		,@NotificationSettingId INT = 4
		,@NotificationSettingIdWatcher INT = 8
		,@BettypeHDP INT = 1
		,@Bettype1HHDP INT = 7
		,@BettypeOU INT = 3
		,@Bettype1HOU INT = 8

	SELECT @OWPMatchId = OWPMatchId
		,@Bettype = Bettype
		,@OldHandicap = HDP
		,@OldTeamChoice = TeamChoice
	FROM dbo.MatchRecommendOdds WITH (NOLOCK)
	WHERE MatchRecommendOddsId = @Id

	IF @OWPMatchId IS NULL
	BEGIN
		SELECT @ErrMsg = 'Recommend odds is not existed or deleted'
			,@ErrCode = 4503 -- ActionId + 03

		RETURN
	END

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP = @Handicap
				AND TeamChoice = @TeamChoice
				AND MatchRecommendOddsId <> @Id
			)
	BEGIN
		SELECT @ErrMsg = 'Duplicate recommend odds'
			,@ErrCode = 4502 -- ActionId + 02

		RETURN
	END

	CREATE TABLE #OldRecommendOdds (
		Choice TINYINT
		,Odds MONEY
		)

	CREATE TABLE #RecommendOdds (
		Choice TINYINT
		,Odds MONEY
		)

	INSERT INTO #OldRecommendOdds
	SELECT Choice
		,Odds
	FROM dbo.MatchRecommendOddsDetail WITH (NOLOCK)
	WHERE MatchRecommendOddsId = @Id

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@RecommendOdds

	INSERT INTO #RecommendOdds (
		Choice
		,Odds
		)
	SELECT DISTINCT data.Choice
		,data.Odds
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
			Choice INT
			,Odds MONEY
			) AS data

	EXEC sp_xml_removedocument @idoc

	SELECT @OldOddsText = COALESCE(@OldOddsText + '/', '') + CAST(ISNULL(Odds, 0) AS VARCHAR)
	FROM MatchRecommendOddsDetail
	WHERE MatchRecommendOddsId = @Id

	-- update table MatchRecommendOdds with Handicap & TeamChoice
	UPDATE dbo.MatchRecommendOdds
	SET TeamChoice = @TeamChoice
		,HDP = @Handicap
	WHERE MatchRecommendOddsId = @Id

	MERGE INTO MatchRecommendOddsDetail AS t
	USING (
		SELECT Choice
			,Odds
		FROM #RecommendOdds
		) AS s
		ON t.MatchRecommendOddsId = @Id
			AND t.Choice = s.Choice
	WHEN MATCHED
		THEN
			UPDATE
			SET t.Odds = s.Odds
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT
			VALUES (
				@Id
				,s.Choice
				,s.Odds
				);

	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageType = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditMatchRecommendOdds'

	SELECT @BettypeName = ShortName
	FROM dbo.MajorBettype WITH (NOLOCK)
	WHERE BettypeId = @Bettype

	IF @Bettype IN (
			@BettypeHDP
			,@Bettype1HHDP
			)
	BEGIN
		SET @HandicapText = CAST(@Handicap AS NVARCHAR(50)) + ' '
		SET @OldHandicapText = CAST(@OldHandicap AS NVARCHAR(50)) + ' '

		IF @TeamChoice = 1
			SET @TeamName = 'Home@'
		ELSE IF @TeamChoice = 2
			SET @TeamName = 'Away@'

		IF @OldTeamChoice = 1
			SET @OldTeamName = 'Home@'
		ELSE IF @OldTeamChoice = 2
			SET @OldTeamName = 'Away@'
	END
	ELSE IF @Bettype IN (
			@BettypeOU
			,@Bettype1HOU
			)
	BEGIN
		SET @HandicapText = CAST(@Handicap AS NVARCHAR(50)) + ' '
		SET @OldHandicapText = CAST(@OldHandicap AS NVARCHAR(50)) + ' '
	END

	SELECT @OldOddsText = STUFF((
				SELECT '/' + CAST(Odds AS NVARCHAR(30))
				FROM #OldRecommendOdds
				ORDER BY Choice ASC
				FOR XML PATH('')
				), 1, 1, '')

	SET @OldOddsText = @OldTeamName + @OldHandicapText + @OldOddsText

	SELECT @NewOddsText = STUFF((
				SELECT '/' + CAST(Odds AS NVARCHAR(30))
				FROM #RecommendOdds
				ORDER BY Choice ASC
				FOR XML PATH('')
				), 1, 1, '')

	SET @NewOddsText = @TeamName + @HandicapText + @NewOddsText
	SET @MessageTemplate = REPLACE(@MessageTemplate, '<bettype>', @BettypeName)
	SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldodds>', @OldOddsText)
	SET @MessageTemplate = REPLACE(@MessageTemplate, '<newodds>', @NewOddsText)
	SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

	-- insert message
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		INSERT INTO @Assignee
		SELECT UserId
		FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, @NotificationSettingId)

		EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
			,@MessageContent = @MessageTemplate
			,@MessageTo = @Assignee
			,@IsImportant = 0
			,@MessageType = @MessageType
			,@SessionId = @SessionId
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		-------------- WATCHER --------------------
		-- 20190304@Kane.Le send message to watcher
		CREATE TABLE #tblUserAssignees (
			UserId INT NOT NULL
			,SectionId INT
			)

		INSERT INTO #tblUserAssignees (
			UserId
			,SectionId
			)
		SELECT u.UserId
			,u.SectionId
		FROM dbo.[fnc_GetAllAssigneeOfMatch](@OWPMatchId) AS u
		WHERE NOT EXISTS (
				SELECT 1
				FROM #tblUserAssignees AS ass2
				WHERE u.UserId = ass2.UserId
				)

		CREATE TABLE #tblUserIdReciveWatchers (
			UserId INT NOT NULL
			,SectionId INT
			)

		INSERT INTO #tblUserIdReciveWatchers (
			UserId
			,SectionId
			)
		SELECT nsm.UserId
			,u.SectionId
		FROM dbo.NotificationSetting AS ns WITH (NOLOCK)
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON nsm.UserId = u.UserId
		WHERE ns.NotificationSettingId = @NotificationSettingIdWatcher
			AND ISNULL(nsm.Value, ns.DefaultValue) = 'True'
			AND u.SectionId IN (
				SELECT SectionId
				FROM #tblUserAssignees
				)
			AND u.UserId <> @UserId

		DECLARE @RowCount INT = 0
		DECLARE @MessageId INT

		SELECT @RowCount = COUNT(1)
		FROM #tblUserIdReciveWatchers

		IF @RowCount > 0
		BEGIN
			INSERT INTO dbo.[Message] (
				MessageContent
				,MessageType
				,CreatedBy
				,IsImportant
				,IsWatcher
				)
			VALUES (
				@MessageTemplate
				,@MessageType
				,@UserId
				,0
				,1
				)

			SET @MessageId = @@IDENTITY

			IF @MessageId IS NOT NULL
				INSERT INTO dbo.MessageUser (
					MessageId
					,UserId
					,IsViewed
					,SessionId
					)
				SELECT @MessageId
					,wc.UserId
					,0
					,@SessionId
				FROM #tblUserIdReciveWatchers AS wc
		END

		DROP TABLE #tblUserAssignees

		DROP TABLE #tblUserIdReciveWatchers
			------------- END Watcher -----------------------
	END

	DROP TABLE #RecommendOdds
END