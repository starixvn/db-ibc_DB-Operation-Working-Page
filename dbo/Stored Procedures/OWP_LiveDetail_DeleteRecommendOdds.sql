
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_DeleteRecommendOdds] @UserId INT
	,@SessionId NVARCHAR(50)
	,@Id INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161206@Tim.Trinh
Task : delete recommend odds
DB: bodb_OWP

Revisions:
	20181004@Kane.Le: delete recommend odds
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181016@Kane.Le: Insert message for assignee traders - [Redmine: #102867]
	20190308@Kane.Le: add Notification Watcher - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OWPMatchId INT
		,@Bettype INT
		,@OldTeamChoice TINYINT
		,@OldHandicap SMALLMONEY
		,@BettypeName NVARCHAR(50) = ''
		,@OldTeamName NVARCHAR(50) = ''
		,@OldHandicapText NVARCHAR(50) = ''
		,@OldOddsText NVARCHAR(50) = ''
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Assignee TVP_INT
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
		SELECT @ErrMsg = 'Recommend odds is not existed or deleted'
			,@ErrCode = 4503 -- ActionId + 03

		RETURN
	END

	CREATE TABLE #OldRecommendOdds (
		Choice TINYINT
		,Odds MONEY
		)

	DELETE
	FROM dbo.MatchRecommendOdds WITH (
			ROWLOCK
			,UPDLOCK
			)
	WHERE MatchRecommendOddsId = @Id

	DELETE
	FROM dbo.MatchRecommendOddsDetail WITH (
			ROWLOCK
			,UPDLOCK
			)
	OUTPUT deleted.Choice
		,deleted.Odds
	INTO #OldRecommendOdds(Choice, Odds)
	WHERE MatchRecommendOddsId = @Id

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
				FROM #OldRecommendOdds
				ORDER BY Choice ASC
				FOR XML PATH('')
				), 1, 1, '')

	SET @OldOddsText = @OldTeamName + @OldHandicapText + @OldOddsText
	SET @MessageTemplate = REPLACE(@MessageTemplate, '<bettype>', @BettypeName)
	SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldodds>', @OldOddsText)
	SET @MessageTemplate = REPLACE(@MessageTemplate, '<newodds>', '')
	SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

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
			,@ErrCode = 0
			,@ErrMsg = ''
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
	DROP TABLE #OldRecommendOdds
END