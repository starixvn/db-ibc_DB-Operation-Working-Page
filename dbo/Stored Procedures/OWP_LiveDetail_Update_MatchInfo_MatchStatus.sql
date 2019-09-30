/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_MatchInfo_MatchStatus] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@ParentMatchId INT
	,@MinorBettypeId INT
	,@MatchStatus NVARCHAR(15)
	,@IsMatchInTimeRange BIT
AS
/*
Created: 20190820@Leo.Vo
Task : update Match status called from SP
DB: bodb_OWP

Revisions:
	20190820@Leo.Vo: Initial SP - [Redmine: #120496]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OldMatchStatus NVARCHAR(15)

	SELECT @OldMatchStatus = m.MatchStatus
	FROM dbo.MatchInfo AS m WITH (NOLOCK)
	WHERE m.OWPMatchId = @OWPMatchId

	IF @OldMatchStatus = @MatchStatus RETURN
	
	DECLARE @EventName NVARCHAR(MAX)
		,@MatchNo VARCHAR(50)
		,@LeagueName NVARCHAR(500)
		-- message template
		,@MessageInsertAssignment NVARCHAR(MAX)
		,@MessageInsertAssignmentId INT
		,@MessageInsertOtherAssignment NVARCHAR(MAX)
		,@MessageInsertOtherAssignmentId INT
		,@MessageMatchStatus NVARCHAR(MAX)
		,@MessageMatchStatusId INT
		,@MessageMinorMatchStatus NVARCHAR(MAX)
		,@MessageMinorMatchStatusId INT
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@NotifyMyAssignmentUpdatedId INT = 1
		,@NotifyAssigneeMatchInfoUpdatedId SMALLINT = 5
		,@NotifyWatcherMatchInfoUpdatedId SMALLINT = 9
		,@UserReceivedAssigneeMessageMatchInfo TVP_INT
		,@UserReceivedWatcherMessageMatchInfo TVP_INT
		,@ActorName VARCHAR(30)
	
	-- build relevant matches
	CREATE TABLE #tblRelevantMatches (
		OWPMatchId INT
		,MinorBettypeId INT
		)
	INSERT INTO #tblRelevantMatches (OWPMatchId, MinorBettypeId)
	VALUES (@OWPMatchId, @MinorBettypeId)
	
	IF @ParentMatchId IS NULL
	BEGIN
		INSERT INTO #tblRelevantMatches (OWPMatchId, MinorBettypeId)
		SELECT MinorMatchId, MinorBettypeId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId AND MinorBettypeId IN (@FastMarket, @AllInOne, @Specific10Mins, @Specific15Mins)
	END
	ELSE
	BEGIN
		IF @MinorBettypeId = @NoOfCorners
		BEGIN
			INSERT INTO #tblRelevantMatches (OWPMatchId, MinorBettypeId)
			SELECT MinorMatchId, MinorBettypeId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId AND MinorBettypeId = @Specific15MinsNoOfCorners
		END
		ELSE IF @MinorBettypeId = @TotalBooking
		BEGIN
			INSERT INTO #tblRelevantMatches (OWPMatchId, MinorBettypeId)
			SELECT MinorMatchId, MinorBettypeId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId AND MinorBettypeId = @TotalBooking
		END
	END
	
	-- update status
	UPDATE mi
	SET MatchStatus = @MatchStatus
	FROM dbo.MatchInfo AS mi WITH (ROWLOCK)
	INNER JOIN #tblRelevantMatches AS m ON mi.OWPMatchId = m.OWPMatchId

	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)
		
	CREATE TABLE #tblAssignee (
		UserId INT
	)
	
	CREATE TABLE #tblAssigneeRecevingNotification (
		UserId INT
	)
	
	CREATE TABLE #tblWatcher (
		UserId INT
	)
		
	IF @IsMatchInTimeRange = 1
	BEGIN
		SELECT @EventName = home.OWPTeamName + ' -vs- ' + away.OWPTeamName
			,@MatchNo = CASE 
				WHEN om.MatchNo = '' THEN ''
				ELSE '#' + om.MatchNo
				END
			,@LeagueName = l.OWPLeagueName
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON om.OWPLeagueId = l.OWPLeagueId
		WHERE om.OWPMatchId = @OWPMatchId

		SELECT @ActorName = dbo.fnc_GetUsernameByUserId(@ActorId)
		
		IF @MatchStatus = 'Live'
		BEGIN
			SELECT @MessageInsertAssignment = mt.MsgTemplateContent
				,@MessageInsertAssignmentId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'AssignmentInsert'

			SELECT @MessageInsertOtherAssignment = mt.MsgTemplateContent
				,@MessageInsertOtherAssignmentId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'OtherAssignmentInsert'

			INSERT INTO #tblMessage (
				UserId
				,MessageContent
				,MessageTypeId
				)
			SELECT a.UserId
				,REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(CASE 
										WHEN a.AssignmentType = 1 THEN @MessageInsertAssignment
										ELSE REPLACE(@MessageInsertOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(a.AssignmentNote, '#<user>', ''))))
										END
								,'<Event>', @EventName)
							, '<League>', @LeagueName)
						,'<Match.No>', @MatchNo)
					,'<Bettype>', mb.ShortName)
				,'<User>', @ActorName)
				,CASE 
					WHEN a.AssignmentType = 1 THEN @MessageInsertAssignmentId
					ELSE @MessageInsertOtherAssignmentId
					END
			FROM dbo.Assignment AS a WITH (NOLOCK)
				INNER JOIN #tblRelevantMatches AS m ON a.OWPMatchId = m.OWPMatchId
				INNER JOIN dbo.MajorBettype AS mb ON mb.BettypeId = a.Bettype
			
			MERGE dbo.[Message] AS ms
			USING (
				SELECT m.UserId
					,m.MessageContent
					,m.MessageTypeId
				FROM #tblMessage AS m
				) AS msn ON 1 = 0
			WHEN NOT MATCHED THEN
					INSERT (
						MessageContent
						,CreatedBy
						,IsImportant
						,MessageType
						)
					VALUES (
						msn.MessageContent
						,@ActorId
						,1
						,msn.MessageTypeId
						)
			OUTPUT inserted.MessageId
				,msn.UserId
				,@SessionId
			INTO dbo.MessageUser(MessageId, UserId, SessionId);
		END
		ELSE
		BEGIN
			SELECT @MessageMatchStatus = mt.MsgTemplateContent
				,@MessageMatchStatusId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'MatchStatus'

			-- Get message content
			INSERT INTO #tblMessage (
				MessageContent
				,MessageTypeId
				)
			SELECT REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(@MessageMatchStatus
								,'<Event>', @EventName)
							,'<Match.No>', @MatchNo)
						,'<League>', @LeagueName)
					,'<Status>', @MatchStatus)
				,'<User>', @ActorName)
				,@MessageMatchStatusId
			
			INSERT INTO #tblAssignee (UserId)
			SELECT DISTINCT a.UserId
			FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN (SELECT MinorMatchId AS OWPMatchId
				FROM dbo.MinorMatch WITH (NOLOCK)
				WHERE ParentMatchId = ISNULL(@ParentMatchId, @OWPMatchId)
				UNION
				SELECT @OWPMatchId  AS OWPMatchId) AS m ON a.OWPMatchId = m.OWPMatchId
			WHERE a.UserId IS NOT NULL
			
			INSERT INTO #tblAssigneeRecevingNotification (UserId)
			SELECT a.UserId
			FROM #tblAssignee AS a
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyAssigneeMatchInfoUpdatedId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = a.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
			
			MERGE dbo.[Message] AS ms
			USING (
				SELECT a.UserId
					,m.MessageContent
					,m.MessageTypeId
				FROM #tblMessage AS m
				CROSS JOIN #tblAssigneeRecevingNotification AS a
				) AS msn ON 1 = 0
			WHEN NOT MATCHED THEN
					INSERT (
						MessageContent
						,CreatedBy
						,IsImportant
						,MessageType
						)
					VALUES (
						msn.MessageContent
						,@ActorId
						,1
						,msn.MessageTypeId
						)
			OUTPUT inserted.MessageId
				,msn.UserId
				,@SessionId
			INTO dbo.MessageUser(MessageId, UserId, SessionId);
			
			INSERT INTO #tblWatcher (UserId)
			SELECT DISTINCT u.UserId
			FROM dbo.[User] AS u WITH (NOLOCK)
			WHERE EXISTS (
				SELECT 1
				FROM #tblAssignee AS a
				INNER JOIN dbo.[User] AS u2 ON a.UserId = u2.UserId
				WHERE u2.SectionId = u.SectionId
			) AND NOT EXISTS (
				SELECT 1
				FROM #tblAssigneeRecevingNotification AS a
				WHERE u.UserId = a.UserId
			)

			MERGE dbo.[Message] AS ms
			USING (
				SELECT a.UserId
					,m.MessageContent
					,m.MessageTypeId
				FROM #tblMessage AS m
				CROSS JOIN #tblWatcher AS a
				LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyWatcherMatchInfoUpdatedId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
					AND nsm.UserId = a.UserId
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
						,msn.MessageTypeId
						,1
						)
			OUTPUT inserted.MessageId
				,msn.UserId
				,@SessionId
			INTO dbo.MessageUser(MessageId, UserId, SessionId);
		END
	END

	DROP TABLE #tblRelevantMatches

	DROP TABLE #tblMessage
	
	DROP TABLE #tblAssignee
	
	DROP TABLE #tblAssigneeRecevingNotification
	
	DROP TABLE #tblWatcher
END