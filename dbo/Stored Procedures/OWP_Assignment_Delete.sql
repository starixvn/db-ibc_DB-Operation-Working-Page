
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Assignment_Delete] @ActorId INT
	,@SessionId NVARCHAR(50)
	,@AssignmentId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20180816@Leo
Task: Delete Assignment at Live Detail.
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
	20181123@Leo.Vo: Fix notify message assignee - [Redmine: #104291]
	20181126@Leo.Vo: Seperate change of assignment LA & Trader - [Redmine: #105043]
	20190213@Kane.Le: remove createdDate vs CreatedBy table MessageUser - [Redmine: #108723]
	20190304@Kane.Le: add Notification Watcher - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @EventDateTime DATETIME
		,@MessageDeleteAssignmentId INT
		,@MessageDeleteAssignment NVARCHAR(500)
		,@MessageDeleteOtherAssignmentId INT
		,@MessageDeleteOtherAssignment NVARCHAR(500)
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
		,@OWPMatchId INT
		,@Bettype INT
		,@AssignmentType INT
		,@BettypeName NVARCHAR(200)
		,@HomeTeam NVARCHAR(200)
		,@AwayTeam NVARCHAR(200)
		,@ActorName NVARCHAR(30)
		,@ChangeOfAssignmentNotificationSettingId INT
		,@WatcherNotificationSettingId INT
		,@BettypeLA INT = - 1002
		,@MessageChangeOfAssignmentContent NVARCHAR(2000)

	SELECT @OWPMatchId = OWPMatchId
		,@Bettype = Bettype
		,@AssignmentType = AssignmentType
	FROM dbo.Assignment WITH (NOLOCK)
	WHERE AssignmentId = @AssignmentId

	IF @OWPMatchId IS NULL
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Assignment is not existed or deleted'
		RETURN
	END

	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		,IsImportant BIT
		)

	CREATE TABLE #tblRemoveAssignment (
		AssignmentId INT
		,Bettype INT NOT NULL
		,AssignmentType TINYINT NOT NULL
		,UserId INT
		,AssignmentNote NVARCHAR(200)
		)

	CREATE TABLE #tblInsertedAssigneeMessageChangeAssignment (
		MessageId INT

		,AssignmentId INT
		,MessageContent NVARCHAR(2000)
		)

	CREATE TABLE #tblInsertedWatcherMessageChangeAssignment (
		MessageId INT
		,AssignmentId INT
		)

	CREATE TABLE #tblUserReceivedAssigneeMessageChangeAssignment (
		UserId INT
		,AssignmentId INT
		,MessageId INT
	)

	CREATE TABLE #tblAllAssigneeOfMatch(
		UserId INT NOT NULL
	)

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher(
		MemberId INT
		,UserReceivedWatcherId INT
	)

	DELETE
	FROM dbo.Assignment WITH (ROWLOCK)
	OUTPUT deleted.AssignmentId
		,deleted.Bettype
		,deleted.AssignmentType
		,deleted.UserId
		,deleted.AssignmentNote
	INTO #tblRemoveAssignment(AssignmentId, Bettype, AssignmentType, UserId, AssignmentNote)
	WHERE AssignmentId = @AssignmentId

	IF @AssignmentType = 1
	BEGIN
		-- remove other assignments
		DELETE
		FROM dbo.Assignment WITH (ROWLOCK)
		OUTPUT deleted.AssignmentId
			,deleted.Bettype
			,deleted.AssignmentType
			,deleted.UserId
			,deleted.AssignmentNote
		INTO #tblRemoveAssignment(AssignmentId, Bettype, AssignmentType, UserId, AssignmentNote)
		WHERE OWPMatchId = @OWPMatchId
			AND Bettype = @Bettype
	END

	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		SELECT @HomeTeam = h.OWPTeamName
			,@AwayTeam = a.OWPTeamName
			,@BettypeName = al.BetTypeName
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
				,mm.MinorBettypeId
			FROM (
				SELECT @OWPMatchId AS OWPMatchId
					,@BetType AS BetType
				) AS d
				LEFT JOIN dbo.MajorBettype AS mjb WITH (NOLOCK) ON d.BetType = mjb.BettypeId
				LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON d.OWPMatchId = mm.MinorMatchId
				LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
				AND d.BetType = mb.InheritedBettypeId
			) AS al
			INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON al.OWPMatchId = m.OWPMatchId
			INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
			INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId

		SELECT @MessageDeleteAssignment = mt.MsgTemplateContent
			,@MessageDeleteAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'AssignmentDelete'

		SELECT @MessageDeleteOtherAssignment = mt.MsgTemplateContent
			,@MessageDeleteOtherAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'OtherAssignmentDelete'

		SELECT @MessageChangeOfAssignment = mt.MsgTemplateContent
			,@MessageChangeOfAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'ChangeOfAssignment'

		-------------- My Assignment --------------------
		-- send message to trader unassigned
		INSERT INTO #tblMessage (
			UserId
			,MessageContent
			,MessageTypeId
			,IsImportant
			)
		SELECT a.UserId
			,REPLACE(CASE 
					WHEN a.AssignmentType = 1 THEN @MessageDeleteAssignment
					ELSE REPLACE(@MessageDeleteOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(a.AssignmentNote, '#<user>', ''))))
					END, '<event>', @HomeTeam + ' vs ' + @AwayTeam + ' - bettype: ' + @BettypeName)
			,CASE 
				WHEN a.AssignmentType = 1 THEN @MessageDeleteAssignmentId
				ELSE @MessageDeleteOtherAssignmentId
				END
			,1
		FROM #tblRemoveAssignment AS a
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyMyAssignmentUpdatedId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = a.UserId
		WHERE a.UserId IS NOT NULL
			AND ISNULL(nsm.Value, ns.DefaultValue) = 'True'

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
		SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)

		SELECT @ChangeOfAssignmentNotificationSettingId = CASE 
				WHEN @BetType = @BettypeLA THEN @NotifyAssigneeLAUpdatedId
				ELSE @NotifyAssigneeTraderUpdatedId
				END

		-- get all assignee in match (include main + minor)
		INSERT INTO #tblAllAssigneeOfMatch (
			UserId
		)
		SELECT a.UserId
		FROM dbo.fnc_GetAllAssigneeOfMatch(@OWPMatchId) AS a

		UNION
		SELECT r.UserId
		FROM #tblRemoveAssignment AS r
		WHERE r.UserId IS NOT NULL

		--
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING (
			SELECT s.AssignmentId
				,REPLACE(REPLACE(REPLACE(REPLACE(@MessageChangeOfAssignment, '<oldAssignee>', CASE 
									WHEN s.AssignmentNote IS NULL THEN '#' + ISNULL(us.Nickname, us.Username)
									ELSE RTRIM(LTRIM(REPLACE(s.AssignmentNote, '#<user>', CASE 
														WHEN us.UserId IS NULL THEN ''
														ELSE '#' + ISNULL(us.Nickname, us.Username)
														END)))
									END), '<event>', @HomeTeam + ' vs ' + @AwayTeam + ' - bettype: ' + @BettypeName), '<user>', @ActorName), '<newAssignee>', '') AS MessageContent
			FROM #tblRemoveAssignment AS s
			LEFT JOIN dbo.[User] AS us WITH (NOLOCK) ON s.UserId = us.UserId
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
					,0
					,@MessageChangeOfAssignmentId
					,0
					)
		OUTPUT inserted.MessageId
			,msn.AssignmentId
			,msn.MessageContent
		INTO #tblInsertedAssigneeMessageChangeAssignment([MessageId], AssignmentId, MessageContent);

		-- get list users received assignee message change assignment
		INSERT INTO #tblUserReceivedAssigneeMessageChangeAssignment(
			UserId
			,AssignmentId
			,MessageId
		)
		SELECT a.UserId
			,im.AssignmentId
			,im.MessageId
		FROM #tblInsertedAssigneeMessageChangeAssignment AS im
		CROSS JOIN #tblAllAssigneeOfMatch AS a
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @ChangeOfAssignmentNotificationSettingId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = a.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
			AND NOT EXISTS (-- ignore user received 'MyAssignmentMessage'	
				SELECT 1 
				FROM #tblRemoveAssignment AS r
				WHERE r.UserId = a.UserId
				)

		INSERT INTO dbo.MessageUser(
			MessageId
			,UserId
			,SessionId			
		)
		SELECT u.MessageId
			,u.UserId
			,@SessionId
		FROM #tblUserReceivedAssigneeMessageChangeAssignment AS u

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
		LEFT JOIN dbo.[User] AS mem WITH (NOLOCK) ON r.SectionId = mem.SectionId AND mem.SectionId IS NOT NULL

		--
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING (
			SELECT ia.MessageContent
				,ia.AssignmentId
			FROM #tblInsertedAssigneeMessageChangeAssignment AS ia
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
					,0
					,@MessageChangeOfAssignmentId
					,1
					)
		OUTPUT inserted.MessageId
			,msn.AssignmentId
		INTO #tblInsertedWatcherMessageChangeAssignment([MessageId], AssignmentId);

		-- get list users received watcher message change assignment
		INSERT INTO dbo.MessageUser(
			MessageId
			,UserId
			,SessionId			
		)
		SELECT DISTINCT im.MessageId
			,sm.UserReceivedWatcherId	
			,@SessionId	
		FROM #tblInsertedWatcherMessageChangeAssignment AS im
		CROSS JOIN	#tblAllAssigneeOfMatch AS a
		INNER JOIN #tblSectionMemberOfUserReceivedWatcher AS sm ON sm.MemberId = a.UserId
		WHERE NOT EXISTS (-- ignore user received 'MyAssignmentMessage'	
				SELECT 1 
				FROM #tblRemoveAssignment AS r
				WHERE r.UserId = sm.UserReceivedWatcherId
				)			
			AND NOT EXISTS ( -- ignore user received Assignee message
				SELECT 1
				FROM #tblUserReceivedAssigneeMessageChangeAssignment AS ur
				WHERE ur.UserId = sm.UserReceivedWatcherId
					AND ur.AssignmentId = im.AssignmentId
			)
				
	END

	DROP TABLE #tblMessage

	DROP TABLE #tblRemoveAssignment

	DROP TABLE #tblInsertedAssigneeMessageChangeAssignment

	DROP TABLE #tblInsertedWatcherMessageChangeAssignment

	DROP TABLE #tblUserReceivedAssigneeMessageChangeAssignment

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END