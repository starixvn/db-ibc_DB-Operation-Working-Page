
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_EditMainMatchToMinorMatch] @OWPMatchId INT
	,@MinorBettypeId INT
	,@ParentMatchId INT
	,@LeagueName NVARCHAR(500)
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@MatchNo VARCHAR(50)
	,@ActorId INT
	,@SessionId VARCHAR(50)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
 Created: 20190816@Leo.Vo
 Task : Change main match to minor match
 DB: bodb_OWP

 Revisions:
	20190816@Leo.Vo: Initial SP - [Feature: #117960]
	20190927@Kane.Le: Update message MatchNo - [Feature: #120415]
	20191021@Kane.Le: Fix MinorBettypeId IS NULL - [Feature: #120415]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @MajorBettype_XMin INT = - 1001
		,@MajorBettype_LA INT = - 1002
		,@MajorBettype_FastMarket INT = - 1003
		,@MajorBettype_AllInOne INT = - 1004
		,@MinorBettype_FastMarket INT = - 88
		,@MinorBettype_AllInOne INT = - 89
		,@MinorBettype_TotalBooking INT = - 6
		,@MinorBettype_NoOfCorner INT = - 3
		,@MinorBettype_Specific15Mins INT = - 1
		,@MinorBettype_Specific10Mins INT = - 2
		,@MinorBettype_Specific15MinsNoOfCorners INT = - 5
		,@MinorBettype_Specific15MinsTotalBooking INT = - 8
	DECLARE @OldMatchNo VARCHAR(50)
		,@OldLeagueName NVARCHAR(500)
		,@OldHomeName NVARCHAR(200)
		,@OldAwayName NVARCHAR(200)
		,@OldMatchStatus NVARCHAR(15)
		,@ParentMatchStatus NVARCHAR(15)
		,@EditMatchNoMessageTemplate NVARCHAR(1000)
		,@EditMatchNoMessageTemplateId INT
		,@EditMatchMessageTemplate NVARCHAR(1000)
		,@EditMatchMessageTemplateId INT
		,@MessageDeleteAssignmentId INT
		,@MessageDeleteAssignment NVARCHAR(500)
		,@MessageDeleteOtherAssignmentId INT
		,@MessageDeleteOtherAssignment NVARCHAR(500)
		,@MessageChangeOfAssignmentId INT
		,@MessageChangeOfAssignment NVARCHAR(500)
		,@MessageEditMaxbet NVARCHAR(500)
		,@MessageEditMaxbetId INT
		,@MessageEditSpread NVARCHAR(500)
		,@MessageEditSpreadId INT		
		,@ActorName NVARCHAR(30)
		,@AssigneeMatchInfoNotificationSettingId INT = 5
		,@WatcherMatchInfoNotificationSettingId INT = 9
		,@MyAssignmentUpdatedNotificationSettingId INT = 1 -- assignee
		,@AssigneeTraderUpdatedNotificationSettingId INT = 2
		,@AssigneeLAUpdatedNotificationSettingId INT = 10
		,@WatcherTraderUpdatedNotificationSettingId INT = 6 -- watcher
		,@WatcherLAUpdatedNotificationSettingId INT = 12
		,@MatchIsInTimeRange BIT = 0
		,@ParentMatchIsInTimeRange BIT = 0
		
	SELECT @MatchIsInTimeRange = 1
	WHERE dbo.fnc_IsMatchInTimeRange(@OWPMatchId) = 1
	
	SELECT @ParentMatchIsInTimeRange = 1
	WHERE dbo.fnc_IsMatchInTimeRange(@ParentMatchId) = 1

	CREATE TABLE #tblAssignee (UserId INT)
	
	CREATE TABLE #tblWatcher (UserId INT)
	
	DECLARE @tblAssigneeReceiver TVP_INT
	DECLARE @tblWatcherReceiver TVP_INT
	
	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		,NotificationSettingId INT
		)
		
	CREATE TABLE #tblAssigneeMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)
		
	CREATE TABLE #tblWatcherMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)

	SELECT @OldMatchNo = MatchNo
		,@OldLeagueName = l.OWPLeagueName
		,@OldHomeName = h.OWPTeamName
		,@OldAwayName = a.OWPTeamName
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
	WHERE OWPMatchId = @OWPMatchId
	
	SELECT @OldMatchStatus = MatchStatus
	FROM dbo.MatchInfo WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId
	
	SELECT @ParentMatchStatus = MatchStatus
	FROM dbo.MatchInfo WITH (NOLOCK)
	WHERE OWPMatchId = @ParentMatchId

	-- create league, match if not existed
	DECLARE @LeagueId INT
		,@HomeId INT
		,@AwayId INT
		,@KickOffTime TIME(7)
		,@EventDateTime DATETIME

	SELECT @LeagueId = OWPLeagueId
	FROM dbo.OWPLeague WITH (NOLOCK)
	WHERE OWPLeagueName = @LeagueName

	IF @LeagueId IS NULL
	BEGIN
		INSERT INTO dbo.OWPLeague (OWPLeagueName)
		VALUES (@LeagueName)

		SELECT @LeagueId = SCOPE_IDENTITY()
	END

	SELECT @HomeId = OWPTeamId
	FROM dbo.OWPTeam AS t WITH (NOLOCK)
	WHERE OWPTeamName = @HomeName

	IF @HomeId IS NULL
	BEGIN
		INSERT INTO dbo.OWPTeam (OWPTeamName)
		VALUES (@HomeName)

		SELECT @HomeId = SCOPE_IDENTITY()
	END

	SELECT @AwayId = OWPTeamId
	FROM dbo.OWPTeam AS t WITH (NOLOCK)
	WHERE OWPTeamName = @AwayName

	IF @AwayId IS NULL
	BEGIN
		INSERT INTO dbo.OWPTeam (OWPTeamName)
		VALUES (@AwayName)

		SELECT @AwayId = SCOPE_IDENTITY()
	END

	-- update OWPMatch
	SELECT @KickOffTime = KickOffTime
		,@EventDateTime = EventDateTime
	FROM dbo.OWPMatch WITH (NOLOCK)
	WHERE OWPMatchId = @ParentMatchId

	UPDATE m
	SET OWPLeagueId = @LeagueId
		,OWPHomeId = @HomeId
		,OWPAwayId = @AwayId
		,MatchNo = @MatchNo
		,KickOffTime = @KickOffTime
		,EventDateTime = @EventDateTime
	FROM dbo.OWPMatch AS m WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId
	
	SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)
	
	
	-- send message for match no, league, team changed, match status change
	IF @MatchIsInTimeRange = 1
	BEGIN
		INSERT INTO #tblAssignee (UserId)
		SELECT DISTINCT a.UserId
		FROM (
			SELECT @OWPMatchId AS OWPMatchId
			
			UNION
			SELECT mm.MinorMatchId AS OWPMatchId
			FROM dbo.MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.ParentMatchId = @OWPMatchId
			) AS m
			INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
			AND mi.MatchStatus = 'Live'
			INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
			AND a.UserId IS NOT NULL
			
		SELECT @EditMatchMessageTemplateId = MsgTemplateId
			,@EditMatchMessageTemplate = MsgTemplateContent
		FROM dbo.MessageTemplate WITH (NOLOCK)
		WHERE MsgTemplateCode = 'EditMatch'
		
		DECLARE @MessageContent NVARCHAR(MAX)
			
		INSERT INTO @tblAssigneeReceiver (Id)
		SELECT a.UserId
		FROM #tblAssignee AS a
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @AssigneeMatchInfoNotificationSettingId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = a.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		INSERT INTO @tblWatcherReceiver (Id)
		SELECT DISTINCT w.UserId
		FROM #tblAssignee AS a
			INNER JOIN dbo.[User] AS u ON a.UserId = u.UserId
			INNER JOIN (
				SELECT w.UserId
					,u.SectionId
				FROM dbo.fnc_GetWatcherToSendMessage(@WatcherMatchInfoNotificationSettingId) AS w
					INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
				) AS w ON u.SectionId = w.SectionId
		WHERE NOT EXISTS (
			SELECT 1
			FROM @tblAssigneeReceiver AS ur
			WHERE ur.Id = w.UserId
		)
		
		PRINT 'send message for match changed'
		
		SELECT @MessageContent = REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										@EditMatchMessageTemplate,
										'<Match.No>', CASE WHEN @MatchNo = '' THEN '' ELSE '#' + @MatchNo END),
									'<League>', @LeagueName),
								'<Event>', @HomeName + ' -vs- ' + @AwayName),
							'<User>', @ActorName),
						'<OldMatch.No>',@OldMatchNo),
					'<OldLeague>',@OldLeagueName),
				'<OldEvent>',@OldHomeName + ' -vs- ' + @OldAwayName)
				
		EXEC dbo.OWP_MessageInsert @UserId = @ActorId
			,@MessageContent = @MessageContent
			,@MessageType = @EditMatchMessageTemplateId
			,@MessageTo = @tblAssigneeReceiver
			,@IsImportant = 1
			,@IsWatcher = 0
			,@SessionId = @SessionId
			
		EXEC dbo.OWP_MessageInsert @UserId = @ActorId
			,@MessageContent = @MessageContent
			,@MessageType = @EditMatchMessageTemplateId
			,@MessageTo = @tblWatcherReceiver
			,@IsImportant = 0
			,@IsWatcher = 1
			,@SessionId = @SessionId
	END
	
	
	-- update match status & send message
	IF @OldMatchStatus <> @ParentMatchStatus AND @ParentMatchStatus IN ('Cancel', 'Postponed', 'Suspended')
	BEGIN
		EXEC dbo.OWP_LiveDetail_MatchInfo_UpdateMatchStatus @UserId=@ActorId, @SessionId=@SessionId, @OWPMatchId=@OWPMatchId, @MatchStatus=@ParentMatchStatus
	END
	

	-- create new MinorMatch
	IF @MinorBettypeId IS NOT NULL
	BEGIN
	INSERT INTO dbo.MinorMatch (
		MinorMatchId
		,ParentMatchId
		,MinorBettypeId
		,IsRepresented
		)
	VALUES (
		@OWPMatchId
		,@ParentMatchId
		,@MinorBettypeId
		,1
		)
	END
	-- if minor match is total booking or no of corner then also change 15' minor match
	DECLARE @tblMappingMinorMatch TABLE (
		MinorBettypeId INT
		,NewMinorBettypeId INT
		)

	IF @MinorBettypeId = @MinorBettype_NoOfCorner
	BEGIN
		INSERT INTO @tblMappingMinorMatch (
			MinorBettypeId
			,NewMinorBettypeId
			)
		VALUES (
			@MinorBettype_Specific15Mins
			,@MinorBettype_Specific15MinsNoOfCorners
			)
	END

	IF @MinorBettypeId = @MinorBettype_TotalBooking
	BEGIN
		INSERT INTO @tblMappingMinorMatch (
			MinorBettypeId
			,NewMinorBettypeId
			)
		VALUES (
			@MinorBettype_Specific15Mins
			,@MinorBettype_Specific15MinsTotalBooking
			)
	END

	UPDATE mm
	SET MinorBettypeId = mapping.NewMinorBettypeId
		,ParentMatchId = @ParentMatchId
	FROM dbo.MinorMatch AS mm WITH (ROWLOCK)
		INNER JOIN @tblMappingMinorMatch AS mapping ON mm.MinorBettypeId = mapping.MinorBettypeId
	WHERE mm.ParentMatchId = @OWPMatchId

	-- remove invalid match
	DECLARE @tblRemoveMatch TABLE (
		OWPMatchId INT
		,MinorBettypeId INT)

	DELETE dbo.MinorMatch WITH (ROWLOCK)
	OUTPUT deleted.MinorMatchId, deleted.MinorBettypeId
	INTO @tblRemoveMatch(OWPMatchId, MinorBettypeId)
	WHERE ParentMatchId = @OWPMatchId

	DELETE m
	FROM dbo.OWPMatch AS m WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatch AS rm ON m.OWPMatchId = rm.OWPMatchId

	-- remove invalid match setting
	DECLARE @tblRemoveMatchSetting TABLE (
		OWPMatchId INT
		,Bettype INT
		,Maxbet MONEY
		,Spread SMALLMONEY
		)

	DELETE ms
	OUTPUT deleted.OWPMatchId
		,deleted.Bettype
		,deleted.Maxbet
		,deleted.Spread
	INTO @tblRemoveMatchSetting(OWPMatchId, Bettype, Maxbet, Spread)
	FROM dbo.MatchSetting AS ms WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatch AS rm ON ms.OWPMatchId = rm.OWPMatchId

	-- remove invalid match assignment
	DECLARE @tblRemoveAssignment TABLE (
		OWPMatchId INT
		,Bettype INT
		,AssignmentType TINYINT
		,UserId INT
		,AssignmentNote NVARCHAR(200)
		)

	DELETE a
	OUTPUT deleted.OWPMatchId
		,deleted.Bettype
		,deleted.AssignmentType
		,deleted.UserId
		,deleted.AssignmentNote
	INTO @tblRemoveAssignment(OWPMatchId, Bettype, AssignmentType, UserId, AssignmentNote)
	FROM dbo.Assignment AS a WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId
		AND Bettype = @MajorBettype_LA

	DELETE a
	OUTPUT deleted.OWPMatchId
		,deleted.Bettype
		,deleted.AssignmentType
		,deleted.UserId
		,deleted.AssignmentNote
	INTO @tblRemoveAssignment(OWPMatchId, Bettype, AssignmentType, UserId, AssignmentNote)
	FROM dbo.Assignment AS a WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatch AS rm ON a.OWPMatchId = rm.OWPMatchId
	
	IF @MatchIsInTimeRange = 1 AND @ParentMatchStatus NOT IN ('Cancel', 'Postponed', 'Postponed')
	BEGIN
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
		
		SELECT @MessageEditMaxbet = mt.MsgTemplateContent
			,@MessageEditMaxbetId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'EditMaxbet'
				
		SELECT @MessageEditSpread = mt.MsgTemplateContent
			,@MessageEditSpreadId = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'EditSpread'
						
		PRINT 'send message for invalid assignment removed'
		
		INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			,UserId
			)
		SELECT REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(CASE 
										WHEN a.AssignmentType = 1 THEN @MessageDeleteAssignment
										ELSE REPLACE(@MessageDeleteOtherAssignment, '<Note>', RTRIM(LTRIM(REPLACE(a.AssignmentNote, '#<user>', ''))))
										END
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', a.BettypeName)
						,'<League>', @LeagueName)
					,'<Match.No>', @MatchNo)
				,'<User>', @ActorName)
				,CASE 
					WHEN a.AssignmentType = 1 THEN @MessageDeleteAssignmentId
					ELSE @MessageDeleteOtherAssignmentId
					END
				,a.UserId
		FROM (
			SELECT 'LA' AS BettypeName
				,a.AssignmentType
				,a.AssignmentNote
				,a.UserId
			FROM @tblRemoveAssignment AS a
			WHERE a.OWPMatchId = @OWPMatchId
			
			UNION
			
			SELECT mb.MinorBettypeName AS BettypeName
				,a.AssignmentType
				,a.AssignmentNote
				,a.UserId
			FROM @tblRemoveAssignment AS a
			INNER JOIN @tblRemoveMatch AS rm ON a.OWPMatchId = rm.OWPMatchId
			LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.MinorBettypeId = rm.MinorBettypeId
			WHERE a.OWPMatchId <> @OWPMatchId
		) AS a
			
		INSERT INTO #tblAssigneeMessage (
			MessageContent
			,MessageTypeId
			,UserId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,m.UserId
		FROM #tblMessage AS m
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @MyAssignmentUpdatedNotificationSettingId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = m.UserId
				WHERE m.UserId IS NOT NULL
			AND ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblAssigneeMessage AS m ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,IsImportant
					,MessageType
					,IsWatcher
					)
				VALUES (
					m.MessageContent
					,@ActorId
					,1
					,m.MessageTypeId
					,0
					)
		OUTPUT inserted.MessageId
			,m.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
			
		-- send message to inform to match assignee about invalid assignment removed
		PRINT 'send message to inform to match assignee about invalid assignment removed'
		
		TRUNCATE TABLE #tblAssignee
		
		INSERT INTO #tblAssignee (UserId)
		SELECT UserId
		FROM dbo.Assignment WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId AND UserId IS NOT NULL
		
		TRUNCATE TABLE #tblMessage
		
		INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			,NotificationSettingId
			)
		SELECT REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(@MessageChangeOfAssignment
											,'<New>', CASE
														WHEN a.AssignmentType = 1 THEN '#' + u.Username
														ELSE RTRIM(LTRIM(REPLACE(a.AssignmentNote, '#<user>', CASE WHEN u.UserId IS NULL THEN '' ELSE '#' + u.Username END)))
														END)
									,'<Old>', '')
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', BettypeName)
						,'<League>', @LeagueName)
					,'<Match.No>', @MatchNo)
				,'<User>', @ActorName)
				,@MessageChangeOfAssignmentId
				,a.NotificationSettingId
		FROM (
			SELECT 'LA' AS BettypeName
				,@AssigneeLAUpdatedNotificationSettingId AS NotificationSettingId
				,a.AssignmentType
				,a.AssignmentNote
				,a.UserId
			FROM @tblRemoveAssignment AS a
			WHERE a.OWPMatchId = @OWPMatchId
			
			UNION
			
			SELECT mb.MinorBettypeName AS BettypeName
				,@AssigneeTraderUpdatedNotificationSettingId AS NotificationSettingId
				,a.AssignmentType
				,a.AssignmentNote
				,a.UserId
			FROM @tblRemoveAssignment AS a
			INNER JOIN @tblRemoveMatch AS rm ON a.OWPMatchId = rm.OWPMatchId
			LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.MinorBettypeId = rm.MinorBettypeId
			WHERE a.OWPMatchId <> @OWPMatchId
		) AS a
		LEFT JOIN dbo.[User] AS u ON a.UserId = u.UserId
		
		-- send to assignee
		TRUNCATE TABLE #tblAssigneeMessage
		
		INSERT INTO #tblAssigneeMessage (
			MessageContent
			,MessageTypeId
			,UserId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,ass.UserId
		FROM #tblMessage AS m
		CROSS JOIN #tblAssignee AS ass
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = m.NotificationSettingId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = m.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING (
			SELECT m.UserId
				,m.MessageContent
				,m.MessageTypeId
			FROM #tblAssigneeMessage AS m
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
					,0
					)
		OUTPUT inserted.MessageId
			,msn.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
		
		-- send to watcher
		TRUNCATE TABLE #tblWatcherMessage
		
		INSERT INTO #tblWatcherMessage (
			MessageContent
			,MessageTypeId
			,UserId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,ass.UserId
		FROM #tblMessage AS m
		CROSS JOIN (SELECT DISTINCT w.UserId
			FROM #tblAssignee AS a
				INNER JOIN dbo.[User] AS u ON a.UserId = u.UserId
				INNER JOIN (
					SELECT w.UserId
						,u.SectionId
					FROM dbo.fnc_GetWatcherToSendMessage(@WatcherTraderUpdatedNotificationSettingId) AS w
						INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
					) AS w ON u.SectionId = w.SectionId
			WHERE NOT EXISTS (
				SELECT 1
				FROM #tblAssigneeMessage AS ur
				WHERE ur.UserId = w.UserId
			)) AS ass
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING (
			SELECT m.UserId
				,m.MessageContent
				,m.MessageTypeId
			FROM #tblWatcherMessage AS m
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
					,0
					)
		OUTPUT inserted.MessageId
			,msn.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
		
		
		PRINT 'send messsage for invalid MaxBet removed'
		
		TRUNCATE TABLE #tblMessage
	
		INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			)
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageEditMaxbet
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.MinorBettypeName)
						,'<Old>', ms.Maxbet)
					,'<New>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', @MatchNo) AS MessageContent
			,@MessageEditMaxbetId
		FROM @tblRemoveMatchSetting AS ms
		INNER JOIN @tblRemoveMatch AS m ON ms.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON m.MinorBettypeId = mb.MinorBettypeId
		WHERE ms.Maxbet IS NOT NULL
		
		UNION
				
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageEditSpread
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.MinorBettypeName)
						,'<Old>', ms.Spread)
					,'<New>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', @MatchNo) AS MessageContent
			,@MessageEditSpreadId
		FROM @tblRemoveMatchSetting AS ms
		INNER JOIN @tblRemoveMatch AS m ON ms.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON m.MinorBettypeId = mb.MinorBettypeId
		WHERE ms.Spread IS NOT NULL
		
		-- send to assignee
		TRUNCATE TABLE #tblAssigneeMessage
		
		INSERT INTO #tblAssigneeMessage (
			MessageContent
			,MessageTypeId
			,UserId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,ass.UserId
		FROM #tblMessage AS m
		CROSS JOIN #tblAssignee AS ass
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @AssigneeMatchInfoNotificationSettingId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = m.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblAssigneeMessage AS m ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,IsImportant
					,MessageType
					,IsWatcher
					)
				VALUES (
					m.MessageContent
					,@ActorId
					,0
					,m.MessageTypeId
					,0
					)
		OUTPUT inserted.MessageId
			,m.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
		
		-- send to watcher
		TRUNCATE TABLE #tblWatcherMessage
		
		INSERT INTO #tblWatcherMessage (
			MessageContent
			,MessageTypeId
			,UserId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,ass.UserId
		FROM #tblMessage AS m
		CROSS JOIN (SELECT DISTINCT w.UserId
			FROM #tblAssignee AS a
				INNER JOIN dbo.[User] AS u ON a.UserId = u.UserId
				INNER JOIN (
					SELECT w.UserId
						,u.SectionId
					FROM dbo.fnc_GetWatcherToSendMessage(@WatcherMatchInfoNotificationSettingId) AS w
						INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
					) AS w ON u.SectionId = w.SectionId
			WHERE NOT EXISTS (
				SELECT 1
				FROM #tblAssigneeMessage AS ur
				WHERE ur.UserId = w.UserId
			)) AS ass
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblWatcherMessage AS m ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,IsImportant
					,MessageType
					,IsWatcher
					)
				VALUES (
					m.MessageContent
					,@ActorId
					,0
					,m.MessageTypeId
					,1
					)
		OUTPUT inserted.MessageId
			,m.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
	END
	
	IF @ParentMatchIsInTimeRange = 1
	BEGIN
		-- load assignee for parent match
		TRUNCATE TABLE #tblAssignee
		
		INSERT INTO #tblAssignee
		SELECT DISTINCT a.UserId
		FROM (
			SELECT @ParentMatchId AS OWPMatchId
			UNION
			SELECT MinorMatchId AS OWPMatchId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId AND MinorMatchId <> @OWPMatchId
			) AS m
			INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
			AND mi.MatchStatus = 'Live'
			INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
			AND a.UserId IS NOT NULL
			
		-- send message to parent match assignee to know about new minor match assignment
		PRINT 'send message to parent match assignee to know about new minor match assignment'
		
		TRUNCATE TABLE #tblMessage
		
		INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			)
		SELECT REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(@MessageChangeOfAssignment
											,'<New>', CASE
														WHEN a.AssignmentType = 1 THEN '#' + u.Username
														ELSE RTRIM(LTRIM(REPLACE(a.AssignmentNote, '#<user>', CASE WHEN u.UserId IS NULL THEN '' ELSE '#' + u.Username END)))
														END)
									,'<Old>', '')
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.ShortName)
						,'<League>', @LeagueName)
					,'<Match.No>', @MatchNo)
				,'<User>', @ActorName)
				,@MessageChangeOfAssignmentId
		FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN dbo.MajorBettype AS mb WITH (NOLOCK) ON a.Bettype = mb.BettypeId
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
		WHERE a.OWPMatchId = @OWPMatchId
		
		-- send to assignee
		TRUNCATE TABLE #tblAssigneeMessage
		
		INSERT INTO #tblAssigneeMessage (
			MessageContent
			,MessageTypeId
			,UserId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,ass.UserId
		FROM #tblMessage AS m
		CROSS JOIN #tblAssignee AS ass
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @AssigneeTraderUpdatedNotificationSettingId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = m.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblAssigneeMessage AS m ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,IsImportant
					,MessageType
					,IsWatcher
					)
				VALUES (
					m.MessageContent
					,@ActorId
					,0
					,m.MessageTypeId
					,0
					)
		OUTPUT inserted.MessageId
			,m.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
		
		-- send to watcher
		TRUNCATE TABLE #tblWatcherMessage
		
		INSERT INTO #tblWatcherMessage (
			MessageContent
			,MessageTypeId
			,UserId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,ass.UserId
		FROM #tblMessage AS m
		CROSS JOIN (SELECT DISTINCT w.UserId
			FROM #tblAssignee AS a
				INNER JOIN dbo.[User] AS u ON a.UserId = u.UserId
				INNER JOIN (
					SELECT w.UserId
						,u.SectionId
					FROM dbo.fnc_GetWatcherToSendMessage(@WatcherTraderUpdatedNotificationSettingId) AS w
						INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
					) AS w ON u.SectionId = w.SectionId
			WHERE NOT EXISTS (
				SELECT 1
				FROM #tblAssigneeMessage AS ur
				WHERE ur.UserId = w.UserId
			)) AS ass
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblWatcherMessage AS m ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,IsImportant
					,MessageType
					,IsWatcher
					)
				VALUES (
					m.MessageContent
					,@ActorId
					,0
					,m.MessageTypeId
					,1
					)
		OUTPUT inserted.MessageId
			,m.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
		
		
		PRINT 'send message to parent match assignee to know about new match setting'
		
		TRUNCATE TABLE #tblMessage
		
		INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			)
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageEditMaxbet
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.ShortName)
						,'<New>', ms.Maxbet)
					,'<Old>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', CASE 
								WHEN ISNULL(@MatchNo, '') = ''
									THEN ''
								ELSE '#' + @MatchNo
								END) AS MessageContent
			,@MessageEditMaxbetId
		FROM dbo.MatchSetting AS ms
		INNER JOIN dbo.MajorBettype as mb ON ms.Bettype = mb.BettypeId
		WHERE ms.OWPMatchId = @OWPMatchId AND ms.Maxbet IS NOT NULL
		
		UNION
		
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageEditSpread
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.ShortName)
						,'<New>', ms.Spread)
					,'<Old>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', CASE 
								WHEN ISNULL(@MatchNo, '') = ''
									THEN ''
								ELSE '#' + @MatchNo
								END) AS MessageContent
			,@MessageEditSpreadId
		FROM dbo.MatchSetting AS ms
		INNER JOIN dbo.MajorBettype as mb ON ms.Bettype = mb.BettypeId
		WHERE ms.OWPMatchId = @OWPMatchId AND ms.Spread IS NOT NULL
				
		-- send to assignee
		TRUNCATE TABLE #tblAssigneeMessage
		
		INSERT INTO #tblAssigneeMessage (
			MessageContent
			,MessageTypeId
			,UserId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,ass.UserId
		FROM #tblMessage AS m
		CROSS JOIN #tblAssignee AS ass
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @AssigneeMatchInfoNotificationSettingId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = m.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblAssigneeMessage AS m ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,IsImportant
					,MessageType
					,IsWatcher
					)
				VALUES (
					m.MessageContent
					,@ActorId
					,0
					,m.MessageTypeId
					,0
					)
		OUTPUT inserted.MessageId
			,m.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
		
		-- send to watcher
		TRUNCATE TABLE #tblWatcherMessage
		
		INSERT INTO #tblWatcherMessage (
			MessageContent
			,MessageTypeId
			,UserId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,ass.UserId
		FROM #tblMessage AS m
		CROSS JOIN (SELECT DISTINCT w.UserId
			FROM #tblAssignee AS a
				INNER JOIN dbo.[User] AS u ON a.UserId = u.UserId
				INNER JOIN (
					SELECT w.UserId
						,u.SectionId
					FROM dbo.fnc_GetWatcherToSendMessage(@WatcherMatchInfoNotificationSettingId) AS w
						INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
					) AS w ON u.SectionId = w.SectionId
			WHERE NOT EXISTS (
				SELECT 1
				FROM #tblAssigneeMessage AS ur
				WHERE ur.UserId = w.UserId
			)) AS ass
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblWatcherMessage AS m ON 1 = 0
		WHEN NOT MATCHED THEN
				INSERT (
					MessageContent
					,CreatedBy
					,IsImportant
					,MessageType
					,IsWatcher
					)
				VALUES (
					m.MessageContent
					,@ActorId
					,0
					,m.MessageTypeId
					,1
					)
		OUTPUT inserted.MessageId
			,m.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
	END
	
	SELECT @ErrCode = 0
		,@ErrMsg = 'The event has been updated successfully!'
	
	DROP TABLE #tblAssignee
	
	DROP TABLE #tblWatcher
	
	DROP TABLE #tblAssigneeMessage
	
	DROP TABLE #tblWatcherMessage
	
	DROP TABLE #tblMessage
END