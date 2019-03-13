
CREATE PROCEDURE [dbo].[OWP_LiveDetail_InsertRecommendOdds] @UserId INT
	,@SessionId NVARCHAR(50)
	,@OWPMatchId INT
	,@Bettype INT
	,@TeamChoice INT
	,@Handicap SMALLMONEY
	,@RecommendOdds NVARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
	,@Id INT OUTPUT
AS
/*
Created: 20161205@Tim.Trinh
Task : insert recommend odds
DB: bodb_OWP

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]  
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
	20190308@Kane.Le: add Notification Watcher - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@BettypeName NVARCHAR(50) = ''
		,@NewOddsText NVARCHAR(200) = ''
		,@TeamName NVARCHAR(50) = ''
		,@HandicapText NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT
		,@NotificationSettingId INT = 4
		,@NotificationSettingIdWatcher INT = 8
		,@BettypeHDP INT = 1
		,@Bettype1HHDP INT = 7
		,@BettypeOU INT = 3
		,@Bettype1HOU INT = 8

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP = @Handicap
				AND TeamChoice = @TeamChoice
			)
	BEGIN
		SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
			,@ErrCode = 7201 -- ActionId + 01

		RETURN
	END

	CREATE TABLE #RecommendOdds (
		Choice INT
		,Odds MONEY
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@RecommendOdds

	INSERT INTO #RecommendOdds (
		Choice
		,Odds
		)
	SELECT DISTINCT data.Choice
		,data.Odds
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
			Choice VARCHAR(20)
			,Odds MONEY
			) AS data

	EXEC sp_xml_removedocument @idoc

	INSERT INTO dbo.MatchRecommendOdds (
		OWPMatchId
		,Bettype
		,HDP
		,TeamChoice
		,CreatedBy
		,CreatedDate
		)
	VALUES (
		@OWPMatchId
		,@Bettype
		,@Handicap
		,@TeamChoice
		,@UserId
		,GETDATE()
		)

	SELECT @Id = @@IDENTITY

	INSERT INTO dbo.MatchRecommendOddsDetail (
		MatchRecommendOddsId
		,Choice
		,Odds
		)
	SELECT @Id
		,Choice
		,Odds
	FROM #RecommendOdds

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

	SELECT @NewOddsText = STUFF((
				SELECT '/' + CAST(Odds AS NVARCHAR(30))
				FROM #RecommendOdds
				ORDER BY Choice ASC
				FOR XML PATH('')
				), 1, 1, '')

	SET @NewOddsText = @TeamName + @HandicapText + @NewOddsText
	SET @MessageTemplate = REPLACE(@MessageTemplate, '<bettype>', @BettypeName)
	SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldodds>', '')
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

	SELECT @ErrMsg = @Id

	DROP TABLE #RecommendOdds
END