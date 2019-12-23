
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
	20190513@Leo.Vo: change condition when send message - [Redmine: #113333]
	20180705@Tyler.Dang: Edit SP for Live Details Recommend odds notification [Redmine: #116398]
	20191224@Kane.Le: add user log - [Redmine: #124448]
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
		,@OWPMatchId INT
		,@Bettype INT
		,@OldHandicap SMALLMONEY
		,@OldTeamChoice TINYINT
		,@BettypeHDP INT = 1
		,@Bettype1HHDP INT = 7
		,@BettypeOU INT = 3
		,@Bettype1HOU INT = 8
		,@NotifyAssigneeRecommendOddsUpdatedId INT = 4
		,@NotifyWatcherRecommendOddsUpdatedId INT = 8
		,@UserReceivedAssigneeMessageRecommendOdds TVP_INT
		,@UserReceivedWatcherMessageRecommendOdds TVP_INT

	SELECT @OWPMatchId = OWPMatchId
		,@Bettype = Bettype
		,@OldHandicap = HDP
		,@OldTeamChoice = TeamChoice
	FROM dbo.MatchRecommendOdds WITH (NOLOCK)
	WHERE MatchRecommendOddsId = @Id

		DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@Xml XML
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)

	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT mo.MatchRecommendOddsId AS '@id'
				,mo.Bettype AS '@bt'
				,mo.HDP AS '@hdp'
				,mo.TeamChoice AS '@tc'
				,mo.CreatedBy AS 'cb'
				,mo.CreatedDate AS 'cd'
				,d.Choice AS 'ch'
				,d.Odds AS 'odd'
			FROM dbo.MatchRecommendOdds AS mo WITH (NOLOCK)
				INNER JOIN dbo.MatchRecommendOddsDetail AS d WITH (NOLOCK) ON mo.MatchRecommendOddsId = d.MatchRecommendOddsId
			WHERE mo.MatchRecommendOddsId = @Id
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

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

	CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
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
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Choice INT, Odds MONEY) AS data

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
		) AS s ON t.MatchRecommendOddsId = @Id
			AND t.Choice = s.Choice
	WHEN MATCHED THEN
			UPDATE
			SET t.Odds = s.Odds
	WHEN NOT MATCHED BY TARGET THEN
			INSERT
			VALUES (
				@Id
				,s.Choice
				,s.Odds
				);

	SELECT @BettypeName = ShortName
	FROM dbo.MajorBettype WITH (NOLOCK)
	WHERE BettypeId = @Bettype

	IF @Bettype IN (@BettypeHDP, @Bettype1HHDP)
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
	ELSE IF @Bettype IN (@BettypeOU, @Bettype1HOU)
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

	SET @OldOddsText = ISNULL(@OldTeamName + @OldHandicapText + @OldOddsText, '')

	SELECT @NewOddsText = STUFF((
				SELECT '/' + CAST(Odds AS NVARCHAR(30))
				FROM #RecommendOdds
				ORDER BY Choice ASC
				FOR XML PATH('')
				), 1, 1, '')

	SET @NewOddsText = ISNULL(@TeamName + @HandicapText + @NewOddsText, '')

	-- insert message
	IF (
			@OldOddsText <> @NewOddsText
			AND dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1
			)
	BEGIN
		SELECT @MessageTemplate = mt.MsgTemplateContent
			,@MessageType = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'EditMatchRecommendOdds'

		SET @MessageTemplate = REPLACE(@MessageTemplate, '<Bettype>', @BettypeName)
		SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

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


	SET @Xml = (
			SELECT mo.MatchRecommendOddsId AS '@id'
				,mo.Bettype AS '@bt'
				,mo.HDP AS '@hdp'
				,mo.TeamChoice AS '@tc'
				,mo.CreatedBy AS '@cb'
				,mo.CreatedDate AS '@cd'
				,d.Choice AS '@ch'
				,d.Odds AS '@odd'
			FROM dbo.MatchRecommendOdds AS mo WITH (NOLOCK)
				INNER JOIN dbo.MatchRecommendOddsDetail AS d WITH (NOLOCK) ON mo.MatchRecommendOddsId = d.MatchRecommendOddsId
			WHERE mo.MatchRecommendOddsId = @Id
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
		,@SPName = 'OWP_OddsCompiler_UpdateOdds'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@Data = @LogData
		,@DataOld = @LogDataOld

	DROP TABLE #RecommendOdds

	DROP TABLE #OldRecommendOdds

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END