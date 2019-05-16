
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
	20190513@Leo.Vo: change condition when send message - [Redmine: #113333]
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
		,@Id INT = 1
		,@Total INT
		,@MatchRecommendOddId INT
		,@BettypeHDP INT = 1
		,@Bettype1HHDP INT = 7
		,@BettypeOU INT = 3
		,@Bettype1HOU INT = 8
		,@NotifyAssigneeRecommendOddsUpdatedId INT = 4
		,@NotifyWatcherRecommendOddsUpdatedId INT = 8
		,@UserReceivedAssigneeMessageRecommendOdds TVP_INT
		,@UserReceivedWatcherMessageRecommendOdds TVP_INT

	CREATE TABLE #MatchRecommendOddsIds (MatchRecommendOddsId INT)

	CREATE TABLE #ValidMatchRecommendOddsIds (
		Id INT IDENTITY(1, 1)
		,MatchRecommendOddsId INT
		)

	CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
		)

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


	INSERT INTO #MatchRecommendOddsIds (MatchRecommendOddsId)
	SELECT val
	FROM dbo.strSplit(@MatchRecommendOddsIds, ',')

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
				,@MessageType = @MessageType
				,@MessageTo = @UserReceivedAssigneeMessageRecommendOdds
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
				,@MessageContent = @MatchMessageTemplate
				,@MessageType = @MessageType
				,@MessageTo = @UserReceivedWatcherMessageRecommendOdds
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			SET @Id = @Id + 1
		END
	END

	DROP TABLE #MatchRecommendOddsIds

	DROP TABLE #ValidMatchRecommendOddsIds

	DROP TABLE #ValidMatchRecommendOdds

	DROP TABLE #ValidMatchRecommendOddsDetail

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END