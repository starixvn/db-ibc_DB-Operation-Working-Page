/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
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
		,@BettypeHDP INT = 1
		,@Bettype1HHDP INT = 7
		,@BettypeOU INT = 3
		,@Bettype1HOU INT = 8
		,@NotifyAssigneeRecommendOddsUpdatedId INT = 4
		,@NotifyWatcherRecommendOddsUpdatedId INT = 8
		,@UserReceivedAssigneeMessageRecommendOdds TVP_INT
		,@UserReceivedWatcherMessageRecommendOdds TVP_INT

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

	CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@RecommendOdds

	INSERT INTO #RecommendOdds (
		Choice
		,Odds
		)
	SELECT DISTINCT data.Choice
		,data.Odds
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Choice VARCHAR(20), Odds MONEY) AS data

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

	IF @Bettype IN (@BettypeHDP, @Bettype1HHDP)
	BEGIN
		SET @HandicapText = CAST(@Handicap AS NVARCHAR(50)) + ' '

		IF @TeamChoice = 1
			SET @TeamName = 'Home@'
		ELSE IF @TeamChoice = 2
			SET @TeamName = 'Away@'
	END
	ELSE IF @Bettype IN (@BettypeOU, @Bettype1HOU)
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
		-------------- ASSIGNEE --------------------
		-- get all assignee in match (include main + minor)
		INSERT INTO #tblAllAssigneeOfMatch (UserId)
		SELECT a.UserId
		FROM dbo.fnc_GetAllAssigneeOfMatch(@OWPMatchId) AS a

		-- get list users received ASSIGNEE message update Recommend Odds
		INSERT INTO @UserReceivedAssigneeMessageRecommendOdds (Id)
		SELECT a.UserId
		FROM #tblAllAssigneeOfMatch AS a
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyAssigneeRecommendOddsUpdatedId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = a.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

		EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
			,@MessageContent = @MessageTemplate
			,@MessageType = @MessageType
			,@MessageTo = @UserReceivedAssigneeMessageRecommendOdds
			,@IsImportant = 0
			,@IsWatcher = 0
			,@SessionId = @SessionId
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		-------------- WATCHER --------------------
		-- get all SectionMemberOfUserReceivedWatcher
		INSERT INTO #tblSectionMemberOfUserReceivedWatcher (
			MemberId
			,UserReceivedWatcherId
			)
		SELECT ISNULL(mem.UserId, r.UserId)
			,r.UserId
		FROM (
			SELECT w.UserId
				,u.SectionId
			FROM dbo.fnc_GetWatcherToSendMessage(@NotifyWatcherRecommendOddsUpdatedId) AS w
				LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
			) AS r
			LEFT JOIN dbo.[User] AS mem WITH (NOLOCK) ON r.SectionId = mem.SectionId
			AND mem.SectionId IS NOT NULL

		-- get list users received Watcher message update Recommend Odds
		INSERT INTO @UserReceivedWatcherMessageRecommendOdds (Id)
		SELECT DISTINCT sm.UserReceivedWatcherId
		FROM #tblAllAssigneeOfMatch AS a
			INNER JOIN #tblSectionMemberOfUserReceivedWatcher AS sm ON sm.MemberId = a.UserId
		WHERE NOT EXISTS (
				-- ignore user received Assignee message
				SELECT 1
				FROM @UserReceivedAssigneeMessageRecommendOdds AS ur
				WHERE ur.Id = sm.UserReceivedWatcherId
				)

		EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
			,@MessageContent = @MessageTemplate
			,@MessageType = @MessageType
			,@MessageTo = @UserReceivedWatcherMessageRecommendOdds
			,@IsImportant = 0
			,@IsWatcher = 1
			,@SessionId = @SessionId
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT
	END

	DROP TABLE #RecommendOdds

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END