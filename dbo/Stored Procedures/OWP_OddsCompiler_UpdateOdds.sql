
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_UpdateOdds] @UserId INT
	,@SessionId VARCHAR(50)
	,@Id INT
	,@Choice TINYINT
	,@Odds MONEY = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20181030@Leo: negative Handicap
 Task : negative HDP
 DB: bodb_OWP          
          
 Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]      
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
	20190308@Kane.Le: add Notification Watcher - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OWPMatchId INT
		,@Bettype INT
		,@TeamChoice TINYINT
		,@Handicap SMALLMONEY
		,@OldOddsText NVARCHAR(50) = ''
		,@NewOddsText NVARCHAR(50) = ''
		,@TeamName NVARCHAR(50) = ''
		,@HandicapText NVARCHAR(50) = ''
		,@BettypeName NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT
		,@IsOldDetailValid BIT = 0
		,@IsNewDetailValid BIT = 0
		,@NotificationSettingId INT = 4
		,@NotificationSettingIdWatcher INT = 8
		,@BettypeHDP INT = 1
		,@Bettype1HHDP INT = 7
		,@BettypeOU INT = 3
		,@Bettype1HOU INT = 8
		,@Bettype1X2 INT = 5
		,@Bettype1H1X2 INT = 15

	SELECT @OWPMatchId = OWPMatchId
		,@Bettype = Bettype
		,@TeamChoice = TeamChoice
		,@Handicap = HDP
	FROM dbo.MatchRecommendOdds WITH (NOLOCK)
	WHERE MatchRecommendOddsId = @Id

	IF @OWPMatchId IS NULL
	BEGIN
		SELECT @ErrMsg = 'The recommend odds is not existed or deleted'
			,@ErrCode = 7201 -- ActionId + 01

		RETURN
	END

	CREATE TABLE #RecommendOdds (
		Choice TINYINT NOT NULL
		,Odds MONEY
		)

	CREATE TABLE #OldRecommendOdds (
		Choice TINYINT NOT NULL
		,Odds MONEY
		)

	INSERT INTO #OldRecommendOdds (
		Choice
		,Odds
		)
	SELECT Choice
		,Odds
	FROM dbo.MatchRecommendOddsDetail WITH (NOLOCK)
	WHERE MatchRecommendOddsId = @Id

	UPDATE dbo.MatchRecommendOddsDetail
	WITH (
			ROWLOCK
			,UPDLOCK
			)

	SET Odds = @Odds
	WHERE MatchRecommendOddsId = @Id
		AND Choice = @Choice

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
		IF @Bettype IN (
				@Bettype1X2
				,@Bettype1H1X2
				)
			OR @Handicap IS NOT NULL
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM #OldRecommendOdds
					WHERE Odds IS NULL
					)
				SET @IsOldDetailValid = 1

			IF NOT EXISTS (
					SELECT 1
					FROM #RecommendOdds
					WHERE Odds IS NULL
					)
				SET @IsNewDetailValid = 1

			IF @IsOldDetailValid = 1
				OR @IsNewDetailValid = 1
			BEGIN
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

					IF @TeamChoice = 1
						SET @TeamName = 'Home@'
					ELSE IF @TeamChoice = 2
						SET @TeamName = 'Away@'
				END
				ELSE IF @Bettype IN (
						@BettypeOU
						,@Bettype1HOU
						)
				BEGIN
					SET @HandicapText = CAST(@Handicap AS NVARCHAR(50)) + ' '
				END

				IF @IsOldDetailValid = 1
				BEGIN
					SELECT @OldOddsText = STUFF((
								SELECT '/' + CAST(Odds AS NVARCHAR(30))
								FROM #OldRecommendOdds
								ORDER BY Choice ASC
								FOR XML PATH('')
								), 1, 1, '')

					SET @OldOddsText = @TeamName + @HandicapText + @OldOddsText
				END

				IF @IsNewDetailValid = 1
				BEGIN
					SELECT @NewOddsText = STUFF((
								SELECT '/' + CAST(Odds AS NVARCHAR(30))
								FROM #RecommendOdds
								ORDER BY Choice ASC
								FOR XML PATH('')
								), 1, 1, '')

					SET @NewOddsText = @TeamName + @HandicapText + @NewOddsText
				END

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
	END

	DROP TABLE #OldRecommendOdds

	DROP TABLE #RecommendOdds
END