
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Delete] @MatchRecommendOddsIds VARCHAR(200)
	,@SessionId VARCHAR(50)
	,@UserId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170317@Alvin.Nguyen
 Task : delete odds compiler
 DB: bodb_OWP          
          
 Revisions:      
	20181004@Kane.Le: delete odds compiler - [Redmine: #92868]
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
	20190308@Kane.Le: add Notification Watcher - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OWPMatchId INT
		,@Bettype INT
		,@BettypeName NVARCHAR(50) = ''
		,@OldTeamChoice TINYINT
		,@OldTeamName NVARCHAR(50) = ''
		,@OldHandicap SMALLMONEY
		,@OldHandicapText NVARCHAR(50) = ''
		,@OldOddsText NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(2000) = ''
		,@MatchMessageTemplate NVARCHAR(2000) = ''
		,@MessageType INT
		,@Assignee TVP_INT
		,@NotificationSettingId INT = 4
		,@NotificationSettingIdWatcher INT = 8
		,@Id INT = 1
		,@Total INT
		,@MatchRecommendOddId INT
		,@BettypeHDP INT = 1
		,@Bettype1HHDP INT = 7
		,@BettypeOU INT = 3
		,@Bettype1HOU INT = 8

	CREATE TABLE #MatchRecommendOddsIds (MatchRecommendOddsId INT)

	CREATE TABLE #ValidMatchRecommendOddsIds (
		Id INT IDENTITY(1, 1)
		,MatchRecommendOddsId INT
		)

	INSERT INTO #MatchRecommendOddsIds (MatchRecommendOddsId)
	SELECT val
	FROM dbo.strSplit(@MatchRecommendOddsIds, ',')

	CREATE TABLE #ValidMatchRecommendOdds (
		MatchRecommendOddsId INT NOT NULL
		,OWPMatchId INT NOT NULL
		,Bettype INT NOT NULL
		,TeamChoice TINYINT
		,HDP SMALLMONEY
		)

	CREATE TABLE #ValidMatchRecommendOddsDetail (
		MatchRecommendOddsId INT NOT NULL
		,Choice TINYINT NOT NULL
		,Odds MONEY
		)

	INSERT INTO #ValidMatchRecommendOddsIds (MatchRecommendOddsId)
	SELECT m.MatchRecommendOddsId
	FROM #MatchRecommendOddsIds AS i
	INNER JOIN dbo.MatchRecommendOdds AS m WITH (NOLOCK) ON m.MatchRecommendOddsId = i.MatchRecommendOddsId
	WHERE Bettype IN (
			5
			,15
			)
		OR HDP IS NOT NULL

	DELETE id
	FROM #ValidMatchRecommendOddsIds AS id
	WHERE EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOddsDetail AS d WITH (NOLOCK)
			WHERE id.MatchRecommendOddsId = d.MatchRecommendOddsId
				AND d.Odds IS NULL
			)

	INSERT INTO #ValidMatchRecommendOdds (
		MatchRecommendOddsId
		,OWPMatchId
		,Bettype
		,TeamChoice
		,HDP
		)
	SELECT i.MatchRecommendOddsId
		,OWPMatchId
		,Bettype
		,TeamChoice
		,HDP
	FROM #ValidMatchRecommendOddsIds AS i
	INNER JOIN dbo.MatchRecommendOdds AS m WITH (NOLOCK) ON i.MatchRecommendOddsId = m.MatchRecommendOddsId

	INSERT INTO #ValidMatchRecommendOddsDetail (
		MatchRecommendOddsId
		,Choice
		,Odds
		)
	SELECT i.MatchRecommendOddsId
		,Choice
		,Odds
	FROM #ValidMatchRecommendOddsIds AS i
	INNER JOIN dbo.MatchRecommendOddsDetail AS d WITH (NOLOCK) ON i.MatchRecommendOddsId = d.MatchRecommendOddsId
	WHERE Odds IS NOT NULL

	-- remove main records
	DELETE
	FROM dbo.MatchRecommendOdds
	WHERE MatchRecommendOddsId IN (
			SELECT MatchRecommendOddsId
			FROM #MatchRecommendOddsIds
			)

	-- remove detail records
	DELETE
	FROM dbo.MatchRecommendOddsDetail
	WHERE MatchRecommendOddsId IN (
			SELECT MatchRecommendOddsId
			FROM #MatchRecommendOddsIds
			)

	SELECT @OWPMatchId = OWPMatchId
	FROM #ValidMatchRecommendOdds

	-- send message
	IF @OWPMatchId IS NOT NULL
		AND dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1
	BEGIN
		SELECT @MessageTemplate = mt.MsgTemplateContent
			,@MessageType = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'EditMatchRecommendOdds'

		SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

		INSERT INTO @Assignee
		SELECT UserId
		FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, @NotificationSettingId)

		DECLARE Id_Cursor CURSOR
		FOR
		SELECT Id
		FROM #ValidMatchRecommendOddsIds

		SELECT @Total = COUNT(1)
		FROM #ValidMatchRecommendOddsIds

		SET @Id = 1

		WHILE @Id <= @Total
		BEGIN
			SELECT @MatchRecommendOddId = MatchRecommendOddsId
			FROM #ValidMatchRecommendOddsIds
			WHERE Id = @Id

			SELECT @Bettype = Bettype
				,@OldTeamChoice = TeamChoice
				,@OldHandicap = HDP
			FROM #ValidMatchRecommendOdds
			WHERE MatchRecommendOddsId = @MatchRecommendOddId

			SELECT @BettypeName = ShortName
			FROM dbo.MajorBettype WITH (NOLOCK)
			WHERE BettypeId = @Bettype

			SELECT @OldTeamName = ''
				,@OldHandicapText = ''

			IF @Bettype IN (
					@BettypeHDP
					,@Bettype1HHDP
					)
			BEGIN
				SET @OldHandicapText = CAST(@OldHandicap AS NVARCHAR(50)) + ' '

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
				SET @OldHandicapText = CAST(@OldHandicap AS NVARCHAR(50)) + ' '
			END

			SELECT @OldOddsText = STUFF((
						SELECT '/' + CAST(Odds AS NVARCHAR(30))
						FROM #ValidMatchRecommendOddsDetail
						WHERE MatchRecommendOddsId = @MatchRecommendOddId
						ORDER BY Choice ASC
						FOR XML PATH('')
						), 1, 1, '')

			SET @OldOddsText = @OldTeamName + @OldHandicapText + @OldOddsText
			SET @MatchMessageTemplate = @MessageTemplate
			SET @MatchMessageTemplate = REPLACE(@MatchMessageTemplate, '<bettype>', @BettypeName)
			SET @MatchMessageTemplate = REPLACE(@MatchMessageTemplate, '<oldodds>', @OldOddsText)
			SET @MatchMessageTemplate = REPLACE(@MatchMessageTemplate, '<newodds>', '')

			EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
				,@MessageContent = @MatchMessageTemplate
				,@MessageTo = @Assignee
				,@IsImportant = 0
				,@MessageType = @MessageType
				,@SessionId = @SessionId
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			SET @Id = @Id + 1
		END

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

	DROP TABLE #MatchRecommendOddsIds

	DROP TABLE #ValidMatchRecommendOddsIds

	DROP TABLE #ValidMatchRecommendOdds

	DROP TABLE #ValidMatchRecommendOddsDetail
END