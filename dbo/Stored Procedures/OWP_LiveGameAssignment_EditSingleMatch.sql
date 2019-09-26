
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_EditSingleMatch] @OWPMatchId INT
	,@LeagueName NVARCHAR(500)
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@MatchNo VARCHAR(50) = ''
	,@KickOffTime TIME(7)
	,@ActorId INT = NULL
	,@SessionId VARCHAR(50) = NULL
	,@MinorBettypeId INT = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
 Created: 20190814@Kane.Le
 Task : edit new event
 DB: bodb_OWP

 Revisions:
	20190814@Kane.Le: Initial SP - [Feature: #117960]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @HasChange INT = 0
		,@StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@OWPLeagueId INT
		,@OWPHomeTeamId INT
		,@OWPAwayTeamId INT
		,@OldKickOffTime TIME
		,@OldOWPLeagueName NVARCHAR(500)
		,@OldOWPHomeName NVARCHAR(200)
		,@OldOWPAwayName NVARCHAR(200)
		,@OldMatchNo NVARCHAR(200)
		,@Xml XML
		-- send message by condition date
		,@MinorBettype_FastMarket INT = - 88
		,@MinorBettype_AllInOne INT = - 89
		,@MinorBettype_Specific15Mins INT = - 1
		,@MinorBettype_Specific10Mins INT = - 2
		,@MinorBettype_Specific15MinsNoOfCorners INT = - 5
		,@MinorBettype_Specific15MinsTotalBooking INT = - 8
		,@UserReceivedAssigneeMessageMatchInfo TVP_INT
		,@UserReceivedWatcherMessageMatchInfo TVP_INT
		-- Notification Setting
		,@NotifyAssigneeMatchInfoUpdatedId INT = 5
		,@NotifyWatcherMatchInfoUpdatedId INT = 9
		,@MessageTemplate NVARCHAR(2000) = ''
		,@MessageTypeId INT
		,@OldValue NVARCHAR(500)
		,@NewValue NVARCHAR(500)
		,@ActorName NVARCHAR(30)

	SET @StartRun = GETDATE()

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

	IF @OldOWPLeagueName <> @LeagueName
	BEGIN
		SET @OWPLeagueId = (
				SELECT l.OWPLeagueId
				FROM dbo.OWPLeague AS l WITH (NOLOCK)
				WHERE l.OWPLeagueName = @LeagueName
				)

		IF @OWPLeagueId IS NULL
		BEGIN
			INSERT INTO dbo.OWPLeague (OWPLeagueName)
			VALUES (@LeagueName)

			SET @OWPLeagueId = SCOPE_IDENTITY();
		END

		UPDATE dbo.OWPMatch WITH (UPDLOCK, ROWLOCK)
		SET OWPLeagueId = @OWPLeagueId
		WHERE OWPMatchId = @OWPMatchId

		-- send message
		SET @HasChange = 1
	END

	IF @MatchNo IS NOT NULL
		AND @OldMatchNo <> @MatchNo
	BEGIN
		UPDATE dbo.OWPMatch WITH (UPDLOCK, ROWLOCK)
		SET MatchNo = @MatchNo
		WHERE OWPMatchId = @OWPMatchId

		SET @HasChange = 1
			-- send message
	END

	IF @OldOWPHomeName <> @HomeName
	BEGIN
		SET @OWPHomeTeamId = (
				SELECT l.OWPTeamId
				FROM dbo.OWPTeam AS l WITH (NOLOCK)
				WHERE l.OWPTeamName = @HomeName
				)

		IF @OWPHomeTeamId IS NULL
		BEGIN
			INSERT INTO dbo.OWPTeam (OWPTeamName)
			VALUES (@HomeName)

			SET @OWPHomeTeamId = SCOPE_IDENTITY();
		END

		UPDATE dbo.OWPMatch WITH (UPDLOCK, ROWLOCK)
		SET OWPHomeId = @OWPHomeTeamId
		WHERE OWPMatchId = @OWPMatchId

		SET @HasChange = 1
	END

	IF @OldOWPAwayName <> @AwayName
	BEGIN
		SET @OWPAwayTeamId = (
				SELECT l.OWPTeamId
				FROM dbo.OWPTeam AS l WITH (NOLOCK)
				WHERE l.OWPTeamName = @AwayName
				)

		IF @OWPAwayTeamId IS NULL
		BEGIN
			INSERT INTO dbo.OWPTeam (OWPTeamName)
			VALUES (@AwayName)

			SET @OWPAwayTeamId = SCOPE_IDENTITY();
		END

		UPDATE dbo.OWPMatch WITH (UPDLOCK, ROWLOCK)
		SET OWPAwayId = @OWPAwayTeamId
		WHERE OWPMatchId = @OWPMatchId

		SET @HasChange = 1
	END

	IF @OldKickOffTime <> @KickOffTime
	BEGIN
		DECLARE @EventDate DATETIME
			,@EventDateTime DATETIME

		SELECT @EventDate = EventDate
		FROM dbo.OWPMatch WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId

		SELECT @EventDateTime = CAST(@EventDate AS DATETIME) + CAST(@KickOffTime AS DATETIME)

		UPDATE dbo.OWPMatch WITH (ROWLOCK)
		SET MatchNo = @MatchNo
			,EventDate = @EventDate
			,KickOffTime = @KickOffTime
			,EventDateTime = @EventDateTime
		WHERE OWPMatchId = @OWPMatchId

		SET @HasChange = 1
	END

	-- send message
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
		AND (
			@MinorBettypeId IS NULL
			OR @MinorBettypeId NOT IN (
				@MinorBettype_FastMarket
				,@MinorBettype_AllInOne
				,@MinorBettype_Specific15Mins
				,@MinorBettype_Specific10Mins
				,@MinorBettype_Specific15MinsNoOfCorners
				,@MinorBettype_Specific15MinsTotalBooking
				)
			)
		AND @HasChange = 1
	BEGIN
		CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

		CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
			MemberId INT
			,UserReceivedWatcherId INT
			,NotificationSettingId INT
			)

		-- get all assignee in match (include main + minor)
		INSERT INTO #tblAllAssigneeOfMatch (UserId)
		SELECT a.UserId
		FROM dbo.fnc_GetAllAssigneeOfMatch(@OWPMatchId) AS a

		-- get list users received ASSIGNEE message update Match Info
		INSERT INTO @UserReceivedAssigneeMessageMatchInfo (Id)
		SELECT a.UserId
		FROM #tblAllAssigneeOfMatch AS a
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyAssigneeMatchInfoUpdatedId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = a.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

		-- get all SectionMemberOfUserReceivedWatcher
		INSERT INTO #tblSectionMemberOfUserReceivedWatcher (
			MemberId
			,UserReceivedWatcherId
			,NotificationSettingId
			)
		SELECT ISNULL(mem.UserId, r.UserId)
			,r.UserId
			,r.NotificationSettingId
		FROM (
			SELECT DISTINCT nm.UserId
				,u.SectionId
				,ns.NotificationSettingId
			FROM dbo.NotificationSetting AS ns WITH (NOLOCK)
			INNER JOIN dbo.NotificationSettingMapping AS nm WITH (NOLOCK) ON ns.NotificationSettingId = nm.NotificationSettingId
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON nm.UserId = u.UserId
			WHERE ns.IsWatcher = 1
				AND nm.Value = 'True'
				AND ns.NotificationSettingId IN (@NotifyWatcherMatchInfoUpdatedId)
			) AS r
		LEFT JOIN dbo.[User] AS mem WITH (NOLOCK) ON r.SectionId = mem.SectionId
			AND mem.SectionId IS NOT NULL

		-- get list users received WATCHER message change Match Info
		INSERT INTO @UserReceivedWatcherMessageMatchInfo (Id)
		SELECT DISTINCT sm.UserReceivedWatcherId
		FROM #tblAllAssigneeOfMatch AS a
		INNER JOIN #tblSectionMemberOfUserReceivedWatcher AS sm ON sm.MemberId = a.UserId
		WHERE sm.NotificationSettingId = @NotifyWatcherMatchInfoUpdatedId
			AND NOT EXISTS (
				-- ignore user received Assignee message
				SELECT 1
				FROM @UserReceivedAssigneeMessageMatchInfo AS ur
				WHERE ur.Id = sm.UserReceivedWatcherId
				)

		SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)

		SELECT @MessageTemplate = mt.MsgTemplateContent
			,@MessageTypeId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'EditMatch'

		SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', @ActorName), '<Match.No>', ISNULL(@MatchNo, '')), '<League>', @LeagueName), '<Event>', @HomeName + ' -vs- ' + @AwayName), '<OldMatch.No>', @OldMatchNo), '<OldLeague>', @OldOWPLeagueName), '<OldEvent>', @OldOWPHomeName + ' -vs- ' + @OldOWPAwayName);		 
		IF @MessageTemplate IS NOT NULL
		BEGIN
			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedAssigneeMessageMatchInfo
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedWatcherMessageMatchInfo
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
		END

		IF (
				@OldKickOffTime IS NOT NULL
				AND @KickOffTime IS NOT NULL
				AND @OldKickOffTime <> @KickOffTime
				)
		BEGIN
			SELECT @OldValue = ISNULL(CONVERT(NVARCHAR(10), @OldKickOffTime, 100), '')
				,@NewValue = ISNULL(CONVERT(NVARCHAR(10), @KickOffTime, 100), '')

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditKOTime'

			SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', @ActorName), '<Match.No>', ISNULL(@MatchNo, '')), '<League>', @LeagueName), '<Event>', @HomeName + ' -vs- ' + @AwayName), '<Old>', @OldValue), '<New>', @NewValue)
			IF @MessageTemplate IS NOT NULL
			BEGIN
				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedAssigneeMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 0
					,@SessionId = @SessionId

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedWatcherMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 1
					,@SessionId = @SessionId
			END
		END

		DROP TABLE #tblAllAssigneeOfMatch

		DROP TABLE #tblSectionMemberOfUserReceivedWatcher
	END

	SELECT @ErrCode = 0
		,@ErrMsg = 'The event has been edited successfully!'

	IF @HasChange = 1
	BEGIN
		SET @Xml = (
				SELECT @OWPMatchId AS '@mid'
					,@OldOWPLeagueName AS '@lname'
					,@OldOWPHomeName AS '@hname'
					,@OldOWPAwayName AS '@aname'
					,@OldMatchNo AS '@mno'
					,@OldKickOffTime AS '@ko'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @Xml = (
				SELECT @OWPMatchId AS '@mid'
					,@LeagueName AS '@lname'
					,@HomeName AS '@hname'
					,@AwayName AS '@aname'
					,@MatchNo AS '@mno'
					,@KickOffTime AS '@ko'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
			,@SPName = 'OWP_LiveGameAssignment_EditSingleMatch'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @LogData
			,@DataOld = @LogDataOld
	END
END