
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_UpdateHDP] @UserId INT
	,@SessionId VARCHAR(50)
	,@Id INT
	,@TeamChoice TINYINT = 0
	,@HDP SMALLMONEY = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170320@Alvin.Nguyen
 Task : insert odds compiler
 DB: bodb_OWP          
          
 Revisions:      
        20181030@Leo: negative Handicap - [Redmine: #92868]
        20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
		20181128@Kane.Le: Prevent send message if HDP no change - [Redmine: #105043]
		20190308@Kane.Le: add Notification Watcher - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OWPMatchId INT
		,@Bettype INT
		,@OldTeamChoice TINYINT
		,@OldHandicap SMALLMONEY
		,@BettypeName NVARCHAR(50) = ''
		,@OddsText NVARCHAR(50) = ''
		,@OldOddsText NVARCHAR(50) = ''
		,@NewOddsText NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT
		,@OldTeamName NVARCHAR(50) = ''
		,@TeamName NVARCHAR(50) = ''
		,@OldHandicapText NVARCHAR(50) = ''
		,@HandicapText NVARCHAR(50) = ''
		,@NotificationSettingId INT = 4
		,@NotificationSettingIdWatcher INT = 8
		,@BettypeHDP INT = 1
		,@Bettype1HHDP INT = 7
		,@BettypeOU INT = 3
		,@Bettype1HOU INT = 8

	SELECT @OWPMatchId = OWPMatchId
		,@Bettype = Bettype
		,@OldTeamChoice = TeamChoice
		,@OldHandicap = HDP
	FROM dbo.MatchRecommendOdds WITH (NOLOCK)
	WHERE MatchRecommendOddsId = @Id

	IF @OWPMatchId IS NULL
	BEGIN
		SELECT @ErrMsg = 'The recommend odds is not existed or deleted'
			,@ErrCode = 7201 -- ActionId + 01

		RETURN
	END

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE MatchRecommendOddsId <> @Id
				AND OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND TeamChoice = @TeamChoice
				AND ISNULL(HDP, 0) = ISNULL(@HDP, 0)
			)
	BEGIN
		SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
			,@ErrCode = 7201 -- ActionId + 01

		RETURN
	END

	UPDATE dbo.MatchRecommendOdds
	WITH (
			ROWLOCK
			,UPDLOCK
			)

	SET TeamChoice = @TeamChoice
		,HDP = @HDP
	WHERE MatchRecommendOddsId = @Id

	IF @Bettype IN (
			@BettypeHDP
			,@Bettype1HHDP
			,@BettypeOU
			,@Bettype1HOU
			)
		AND @HDP IS NULL
		AND @OldHandicap IS NULL
		RETURN

	CREATE TABLE #RecommendOdds (
		Choice TINYINT
		,Odds MONEY
		)

	INSERT INTO #RecommendOdds (
		Choice
		,Odds
		)
	SELECT Choice
		,Odds
	FROM dbo.MatchRecommendOddsDetail WITH (NOLOCK)
	WHERE MatchRecommendOddsId = @Id

	-- insert message
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM #RecommendOdds
				WHERE Odds IS NULL
				)
		BEGIN
			IF @OldTeamChoice <> @TeamChoice
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
				SET @HandicapText = CAST(@HDP AS NVARCHAR(50)) + ' '
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
				SET @HandicapText = CAST(@HDP AS NVARCHAR(50)) + ' '
				SET @OldHandicapText = CAST(@OldHandicap AS NVARCHAR(50)) + ' '
			END

			SELECT @OddsText = STUFF((
						SELECT '/' + CAST(Odds AS NVARCHAR(30))
						FROM #RecommendOdds
						ORDER BY Choice ASC
						FOR XML PATH('')
						), 1, 1, '')

			IF @OldHandicap IS NOT NULL
				SET @OldOddsText = @OldTeamName + @OldHandicapText + @OddsText

			IF @HDP IS NOT NULL
				SET @NewOddsText = @TeamName + @HandicapText + @OddsText
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<bettype>', @BettypeName)
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldodds>', @OldOddsText)
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<newodds>', @NewOddsText)
			SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

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
	END

	DROP TABLE #RecommendOdds
END