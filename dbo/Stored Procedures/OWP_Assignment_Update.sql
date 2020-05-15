
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Assignment_Update] @ActorId INT
	,@SessionId VARCHAR(50)
	,@AssignmentId INT
	,@UserId INT = NULL
	,@AssignmentNote NVARCHAR(200) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20180816@Leo
Task: Update Assignments at Live Detail.
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
	20181123@Leo.Vo: Fix notify message assignee - [Redmine: #104291]
	20181126@Leo.Vo: Seperate change of assignment LA & Trader - [Redmine: #105043]
	20190213@Kane.Le: remove createdDate vs CreatedBy table MessageUser - [Redmine: #108723]
	20190304@Kane.Le: add Notification Watcher - [Redmine: #109560]
	20190704@Leo.Vo: Change message template - [Feature: #115459]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OldUserId INT = NULL
		,@OldAssignmentNote NVARCHAR(200)
		,@EventDateTime DATETIME
		,@MessageInsertAssignmentId INT
		,@MessageInsertAssignment NVARCHAR(500)
		,@MessageDeleteAssignmentId INT
		,@MessageDeleteAssignment NVARCHAR(500)
		,@MessageInsertOtherAssignmentId INT
		,@MessageInsertOtherAssignment NVARCHAR(500)
		,@MessageDeleteOtherAssignmentId INT
		,@MessageDeleteOtherAssignment NVARCHAR(500)
		,@MessageUpdateOtherAssignmentId INT
		,@MessageUpdateOtherAssignment NVARCHAR(500)
		,@MessageChangeOfAssignmentId INT
		,@MessageChangeOfAssignment NVARCHAR(500)
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@OWPMatchId INT
		-- Notification Setting
		,@NotifyMyAssignmentUpdatedId INT = 1 -- assignee
		,@NotifyAssigneeTraderUpdatedId INT = 2
		,@NotifyAssigneeLAUpdatedId INT = 10
		,@NotifyWatcherTraderUpdatedId INT = 6 -- watcher
		,@NotifyWatcherLAUpdatedId INT = 12
		--
		,@Bettype INT
		,@Username NVARCHAR(30) = ''
		,@OldUsername NVARCHAR(30) = ''
		,@BettypeName NVARCHAR(200)
		,@LeagueName NVARCHAR(500)
		,@MatchNo VARCHAR(50)
		,@HomeTeam NVARCHAR(200)
		,@AwayTeam NVARCHAR(200)
		,@ActorName NVARCHAR(30)
		,@ChangeOfAssignmentNotificationSettingId INT
		,@WatcherNotificationSettingId INT
		,@BettypeLA INT = - 1002
		,@MessageChangeOfAssignmentContent NVARCHAR(2000)

	-- validate & Update assignment 
	SELECT @OWPMatchId = OWPMatchId
		,@Bettype = Bettype
		,@OldUserId = UserId
		,@OldAssignmentNote = AssignmentNote
	FROM dbo.Assignment WITH (NOLOCK)
	WHERE AssignmentId = @AssignmentId

	IF @OWPMatchId IS NULL
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Assignment is not existed or deleted'

		RETURN
	END

	IF(@UserId IS NOT NULL)
	BEGIN
		UPDATE dbo.Assignment WITH (ROWLOCK)
			SET UserId = @UserId
				,AssignmentNote = @AssignmentNote
			WHERE AssignmentId = @AssignmentId
				AND (
					UserId <> @UserId
					OR AssignmentNote <> @AssignmentNote
					)
		IF (@@ROWCOUNT = 0) RETURN
	END

	IF(ISNULL(@AssignmentNote, '') <> '' AND @UserId IS NULL AND @OldUserId IS NOT NULL AND @AssignmentNote LIKE '%Same%')
	BEGIN
		DECLARE @OldOtherAssignmentUserId INT

		SELECT @OldOtherAssignmentUserId = UserId
		FROM dbo.Assignment WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId
			AND Bettype = @Bettype
			AND AssignmentType = 1
		
		UPDATE dbo.Assignment WITH (ROWLOCK)
		SET AssignmentNote = @AssignmentNote
			,UserId = @OldOtherAssignmentUserId
			,@UserId = @OldOtherAssignmentUserId
		WHERE AssignmentId = @AssignmentId
			AND AssignmentNote <> @AssignmentNote
		IF (@@ROWCOUNT = 0) RETURN
	END

	IF(@UserId IS NOT NULL AND @UserId <> ISNULL(@OldUserId, 0) AND ISNULL(@AssignmentNote, '') = ''
		AND EXISTS(
				SELECT 1 
				FROM dbo.Assignment WITH(NOLOCK) 
				WHERE OWPMatchId = @OWPMatchId 
					AND Bettype = @Bettype 
					AND AssignmentType = 2 
					AND AssignmentNote LIKE '%Same%')
					)
	BEGIN
		DECLARE @UpdatedAssignmentNote NVARCHAR(200)
			,@RemoveAssigmentId INT
		
		SELECT @UpdatedAssignmentNote = AssignmentNote
			, @RemoveAssigmentId = AssignmentId
		FROM dbo.[Assignment] WITH(NOLOCK) 
		WHERE OWPMatchId = @OWPMatchId 
			AND Bettype = @BetType 
			AND AssignmentType = 2 
			AND AssignmentNote LIKE '%Same%'
		
		EXEC dbo.OWP_Assignment_Delete @ActorId = @ActorId
				,@SessionId = @SessionId
				,@AssignmentId = @RemoveAssigmentId

		EXEC dbo.OWP_Assignment_Create @ActorId = @ActorId
				,@SessionId = @SessionId
				,@OWPMatchId = @OWPMatchId
				,@BetType = @Bettype
				,@AssignmentType = 2
				,@UserId = @UserId
				,@AssignmentNote = @UpdatedAssignmentNote
	END

	DECLARE @UserReceivedAssigneeMessageChangeAssignment TVP_INT
		,@UserReceivedWatcherMessageChangeAssignment TVP_INT

	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		,IsImportant BIT
		)

	CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
		)

	SELECT @HomeTeam = h.OWPTeamName
		,@AwayTeam = a.OWPTeamName
		,@BettypeName = al.BetTypeName
		,@EventDateTime = m.EventDateTime
		,@LeagueName = l.OWPLeagueName
		,@MatchNo = CASE WHEN m.MatchNo = '' THEN '' ELSE '#' + m.MatchNo END
	FROM (
		SELECT (CASE 
				WHEN mm.MinorMatchId IS NULL THEN d.OWPMatchId
				ELSE mm.ParentMatchId END
				) AS OWPMatchId
			,(CASE 
				WHEN mm.MinorMatchId IS NULL THEN mjb.ShortName
				ELSE mb.MinorBettypeName END
				) AS BetTypeName
			,mm.MinorBettypeId
		FROM (
			SELECT @OWPMatchId AS OWPMatchId
				,@Bettype AS Bettype
			) AS d
			LEFT JOIN dbo.MajorBettype AS mjb WITH (NOLOCK) ON d.BetType = mjb.BettypeId
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON d.OWPMatchId = mm.MinorMatchId
			LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
			AND d.BetType = mb.InheritedBettypeId
		) AS al
		INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON al.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId

	-- insert data trade 5 match per day
	IF @UserId IS NOT NULL
	BEGIN
		EXEC dbo.OWP_Trade5MatchPerDay_RunAfterInsertAssignment @EventDateTime
			,@UserId
	END

	-- send message
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		SELECT @FromTimeSendMessage = FromTime
			,@ToTimeSendMessage = ToTime
			,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
			,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
		FROM dbo.fnc_GetDateTimeForTraderViewTime()

		SELECT @MessageInsertAssignment = mt.MsgTemplateContent
			,@MessageInsertAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'AssignmentInsert'

		SELECT @MessageDeleteAssignment = mt.MsgTemplateContent
			,@MessageDeleteAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'AssignmentDelete'

		SELECT @MessageInsertOtherAssignment = mt.MsgTemplateContent
			,@MessageInsertOtherAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'OtherAssignmentInsert'

		SELECT @MessageDeleteOtherAssignment = mt.MsgTemplateContent
			,@MessageDeleteOtherAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'OtherAssignmentDelete'

		SELECT @MessageUpdateOtherAssignment = mt.MsgTemplateContent
			,@MessageUpdateOtherAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'OtherAssignmentUpdate'

		SELECT @MessageChangeOfAssignment = mt.MsgTemplateContent
			,@MessageChangeOfAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'ChangeOfAssignment'
		
		SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)

		IF @OldUserId IS NOT NULL
			AND @OldUserId <> ISNULL(@UserId, 0)
		BEGIN
			-- send message to trader unassigned
			INSERT INTO #tblMessage (
				UserId
				,MessageContent
				,MessageTypeId
				,IsImportant
				)
			SELECT d.UserId
				,d.MessageContent
				,d.MessageTypeId
				,1
			FROM (
				SELECT @OldUserId AS UserId
					,REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(CASE 
											WHEN @OldAssignmentNote IS NULL THEN @MessageDeleteAssignment
											ELSE REPLACE(@MessageDeleteOtherAssignment, '<Note>', RTRIM(LTRIM(REPLACE(REPLACE(@OldAssignmentNote, '#<user>', ''), 'Same', ''))))
											END
									,'<Event>', @HomeTeam + ' -vs- ' + @AwayTeam)
								,'<Bettype>', @BettypeName)
							,'<League>', @LeagueName)
						,'<Match.No>', @MatchNo)
					,'<User>', @ActorName) AS MessageContent
					,(CASE 
						WHEN @OldAssignmentNote IS NULL THEN @MessageDeleteAssignmentId
						ELSE @MessageDeleteOtherAssignmentId END
						) AS MessageTypeId
				) AS d
				INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = @OldUserId
				LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyMyAssignmentUpdatedId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = @OldUserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		END

		IF @UserId IS NOT NULL
			AND @UserId <> ISNULL(@OldUserId, 0)
		BEGIN
			-- send message to trader assigned
			INSERT INTO #tblMessage (
				UserId
				,MessageContent
				,MessageTypeId
				,IsImportant
				)
			SELECT d.UserId
				,d.MessageContent
				,d.MessageTypeId
				,1
			FROM (
				SELECT @UserId AS UserId
					,REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(CASE 
											WHEN @AssignmentNote IS NULL THEN @MessageInsertAssignment
											ELSE REPLACE(@MessageInsertOtherAssignment, '<Note>', RTRIM(LTRIM(REPLACE(REPLACE(@AssignmentNote, '#<user>', ''), 'Same', ''))))
											END
									,'<Event>', @HomeTeam + ' -vs- ' + @AwayTeam)
								,'<Bettype>', @BettypeName)
							,'<League>', @LeagueName)
						,'<Match.No>', @MatchNo)
					,'<User>', @ActorName) AS MessageContent
					,(CASE 
						WHEN @AssignmentNote IS NULL THEN @MessageInsertAssignmentId
						ELSE @MessageInsertOtherAssignmentId END
						) AS MessageTypeId
				) AS d
				INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = @UserId
				LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyMyAssignmentUpdatedId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = @UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		END

		IF @UserId IS NOT NULL
			AND @UserId = ISNULL(@OldUserId, 0)
		BEGIN
			-- send message to trader edited
			INSERT INTO #tblMessage (
				UserId
				,MessageContent
				,MessageTypeId
				,IsImportant
				)
			SELECT d.UserId
				,d.MessageContent
				,d.MessageTypeId
				,1
			FROM (
				SELECT @UserId AS UserId
					,REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(@MessageUpdateOtherAssignment,
											'<New>', RTRIM(LTRIM(REPLACE(REPLACE(@AssignmentNote, '#<user>', ''), 'Same', ''))))
										,'<Old>', RTRIM(LTRIM(REPLACE(REPLACE(@OldAssignmentNote, '#<user>', ''), 'Same', ''))))
									,'<Event>', @HomeTeam + ' -vs- ' + @AwayTeam)
								,'<Bettype>', @BettypeName)
							,'<League>', @LeagueName)
						,'<Match.No>', @MatchNo)
					,'<User>', @ActorName) AS MessageContent
					,@MessageUpdateOtherAssignmentId AS MessageTypeId
				) AS d
				INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = @UserId
				LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyMyAssignmentUpdatedId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = @UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		END

		-------------- My Assignment --------------------
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING (
			SELECT m.UserId
				,m.MessageContent
				,m.MessageTypeId
				,m.IsImportant
			FROM #tblMessage AS m
			) AS msn ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,IsImportant
					,MessageType
					,IsWatcher
					)
				VALUES (
					msn.MessageContent
					,@ActorId
					,msn.IsImportant
					,msn.MessageTypeId
					,0
					)
		OUTPUT inserted.MessageId
			,msn.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);

		-------------- ASSIGNEE --------------------
		-- send message to traders have match assigned
		IF @UserId IS NOT NULL
			SET @Username = '#' + dbo.[fnc_GetUsernameByUserId](@UserId)

		IF @OldUserId IS NOT NULL
			SET @OldUsername = '#' + dbo.[fnc_GetUsernameByUserId](@OldUserId)

		SELECT @MessageChangeOfAssignmentContent = 
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageChangeOfAssignment
									,'<New>', CASE 
												WHEN @AssignmentNote IS NULL THEN @Username
												ELSE RTRIM(LTRIM(REPLACE(REPLACE(@AssignmentNote, '#<user>', @Username), 'Same', '')))
												END)
								,'<Old>', CASE 
											WHEN @OldAssignmentNote IS NULL THEN @OldUsername
											ELSE RTRIM(LTRIM(REPLACE(REPLACE(@OldAssignmentNote, '#<user>', @OldUsername), 'Same', '')))
											END)
							,'<Event>', @HomeTeam + ' -vs- ' + @AwayTeam)
						,'<Bettype>', @BettypeName)
					,'<League>', @LeagueName)
				,'<Match.No>', @MatchNo)
			,'<User>', @ActorName)
			
		SELECT @ChangeOfAssignmentNotificationSettingId = CASE 
				WHEN @BetType = @BettypeLA THEN @NotifyAssigneeLAUpdatedId
				ELSE @NotifyAssigneeTraderUpdatedId
				END

		-- get all assignee in match (include main + minor)
		INSERT INTO #tblAllAssigneeOfMatch (UserId)
		SELECT a.UserId
		FROM dbo.fnc_GetAllAssigneeOfMatch(@OWPMatchId) AS a

		-- get list users received assignee message change assignment
		INSERT INTO @UserReceivedAssigneeMessageChangeAssignment (Id)
		SELECT a.UserId
		FROM #tblAllAssigneeOfMatch AS a
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @ChangeOfAssignmentNotificationSettingId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = a.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

		EXEC dbo.OWP_MessageInsert @UserId = @ActorId
			,@MessageContent = @MessageChangeOfAssignmentContent
			,@MessageType = @MessageChangeOfAssignmentId
			,@MessageTo = @UserReceivedAssigneeMessageChangeAssignment
			,@IsImportant = 0
			,@IsWatcher = 0
			,@SessionId = @SessionId

		-------------- WATCHER --------------------
		SELECT @WatcherNotificationSettingId = CASE 
				WHEN @BetType = @BettypeLA THEN @NotifyWatcherLAUpdatedId
				ELSE @NotifyWatcherTraderUpdatedId
				END

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
			FROM dbo.fnc_GetWatcherToSendMessage(@WatcherNotificationSettingId) AS w
				LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
			) AS r
			LEFT JOIN dbo.[User] AS mem WITH (NOLOCK) ON r.SectionId = mem.SectionId
			AND mem.SectionId IS NOT NULL

		-- get list users received watcher message change assignment
		INSERT INTO @UserReceivedWatcherMessageChangeAssignment (Id)
		SELECT DISTINCT sm.UserReceivedWatcherId
		FROM #tblAllAssigneeOfMatch AS a
			INNER JOIN #tblSectionMemberOfUserReceivedWatcher AS sm ON sm.MemberId = a.UserId
		WHERE NOT EXISTS (
				-- ignore user received Assignee message
				SELECT 1
				FROM @UserReceivedAssigneeMessageChangeAssignment AS ur
				WHERE ur.Id = sm.UserReceivedWatcherId
				)

		EXEC dbo.OWP_MessageInsert @UserId = @ActorId
			,@MessageContent = @MessageChangeOfAssignmentContent
			,@MessageType = @MessageChangeOfAssignmentId
			,@MessageTo = @UserReceivedWatcherMessageChangeAssignment
			,@IsImportant = 0
			,@IsWatcher = 1
			,@SessionId = @SessionId
	END

	DROP TABLE #tblMessage

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END