
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Assignment_Create] @ActorId INT
	,@SessionId NVARCHAR(50)
	,@OWPMatchId INT
	,@BetType INT
	,@AssignmentType TINYINT
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
	20181126@Leo.Vo: Seperate change of assignment LA & Trader - [Redmine: #105043]
	20190213@Kane.Le: remove createdDate vs CreatedBy table MessageUser - [Redmine: #108723]
	20190304@Kane.Le: add Notification Watcher - [Redmine: #109560]
	20190325@Kane.Le: add @ErrMsg = @@IDENTITY - [Redmine: #110322]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20190704@Leo.Vo: Change message template - [Feature: #115459]
*/
BEGIN
	SET NOCOUNT ON

	IF EXISTS (
			SELECT 1
			FROM dbo.Assignment WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @BetType
				AND AssignmentType = @AssignmentType
				AND @AssignmentType = 1
			)
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'The main assignment is existed'

		RETURN
	END

	DECLARE @EventDateTime DATETIME
		,@MessageInsertAssignmentId INT
		,@MessageInsertAssignment NVARCHAR(500)
		,@MessageInsertOtherAssignmentId INT
		,@MessageInsertOtherAssignment NVARCHAR(500)
		,@MessageChangeOfAssignmentId INT
		,@MessageChangeOfAssignment NVARCHAR(500)
		--
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		-- Notification Setting
		,@NotifyMyAssignmentUpdatedId INT = 1 -- assignee
		,@NotifyAssigneeTraderUpdatedId INT = 2
		,@NotifyAssigneeLAUpdatedId INT = 10
		,@NotifyWatcherTraderUpdatedId INT = 6 -- watcher
		,@NotifyWatcherLAUpdatedId INT = 12
		--
		,@BettypeName NVARCHAR(200)
		,@LeagueName NVARCHAR(500)
		,@MatchNo VARCHAR(50)
		,@HomeTeam NVARCHAR(200)
		,@AwayTeam NVARCHAR(200)
		,@Username NVARCHAR(30)
		,@ActorName NVARCHAR(30)
		,@ChangeOfAssignmentNotificationSettingId INT
		,@WatcherNotificationSettingId INT
		,@BettypeLA INT = - 1002
		,@MessageChangeOfAssignmentContent NVARCHAR(2000)
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

	-- insert new assignment
	INSERT INTO dbo.Assignment (
		OWPMatchId
		,Bettype
		,AssignmentType
		,UserId
		,AssignmentNote
		)
	VALUES (
		@OWPMatchId
		,@BetType
		,@AssignmentType
		,@UserId
		,@AssignmentNote
		)

	SELECT @ErrMsg = @@IDENTITY

	SELECT @HomeTeam = h.OWPTeamName
		,@AwayTeam = a.OWPTeamName
		,@BettypeName = al.BetTypeName
		,@LeagueName = l.OWPLeagueName
		,@MatchNo = CASE WHEN m.MatchNo = '' THEN '' ELSE '#' + m.MatchNo END
		,@Username = CASE 
			WHEN u.UserId IS NULL THEN ''
			ELSE '#' + u.Username
			END
		,@EventDateTime = m.EventDateTime
	FROM (
		SELECT (CASE 
				WHEN mm.MinorMatchId IS NULL THEN d.OWPMatchId
				ELSE mm.ParentMatchId END
				) AS OWPMatchId
			,(CASE 
				WHEN mm.MinorMatchId IS NULL THEN mjb.ShortName
				ELSE mb.MinorBettypeName END
				) AS BetTypeName
			,d.UserId
		FROM (
			SELECT @OWPMatchId AS OWPMatchId
				,@BetType AS BetType
				,@UserId AS UserId
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
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = al.UserId

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

		SELECT @MessageInsertOtherAssignment = mt.MsgTemplateContent
			,@MessageInsertOtherAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'OtherAssignmentInsert'

		SELECT @MessageChangeOfAssignment = mt.MsgTemplateContent
			,@MessageChangeOfAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'ChangeOfAssignment'
		
		SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)

		IF @UserId IS NOT NULL
		BEGIN
			-------------- My Assignment -----------------
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
										ELSE REPLACE(@MessageInsertOtherAssignment, '<Note>', RTRIM(LTRIM(REPLACE(@AssignmentNote, '#<user>', ''))))
										END, 
									'<Event>', @HomeTeam + ' vs ' + @AwayTeam)
								,'<Bettype>', @BettypeName)
							,'<League>', @LeagueName)
						,'<Match.No>', @MatchNo)
					,'<User>', @ActorName) AS MessageContent
					,(CASE 
						WHEN @AssignmentNote IS NULL THEN @MessageInsertAssignmentId
						ELSE @MessageInsertOtherAssignmentId END
						) AS MessageTypeId
				) AS d
				LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyMyAssignmentUpdatedId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = d.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

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
		END

		-------------- ASSIGNEE --------------------
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
													ELSE RTRIM(LTRIM(REPLACE(@AssignmentNote, '#<user>', @Username)))
													END)
								,'<Old>', '')
							,'<Event>', @HomeTeam + ' vs ' + @AwayTeam)
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