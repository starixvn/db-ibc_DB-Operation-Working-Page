
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
		,@EditLeagueMessageTemplate NVARCHAR(1000)
		,@EditLeagueMessageTemplateId INT
		,@EditTeamMessageTemplate NVARCHAR(1000)
		,@EditTeamMessageTemplateId INT
		,@MessageDeleteAssignmentId INT
		,@MessageDeleteAssignment NVARCHAR(500)
		,@MessageDeleteOtherAssignmentId INT
		,@MessageDeleteOtherAssignment NVARCHAR(500)
		,@MessageChangeOfAssignmentId INT
		,@MessageChangeOfAssignment NVARCHAR(500)
		,@MessageEditMaxbet NVARCHAR(500)
		,@MessageEditMaxbetId INT
		,@MessageEditMaxbetCN88 NVARCHAR(500)
		,@MessageEditMaxbetCN88Id INT
		,@MessageEditSpread NVARCHAR(500)
		,@MessageEditSpreadId INT
		,@MessageEditSpreadCN88 NVARCHAR(500)
		,@MessageEditSpreadCN88Id INT
		,@ActorName NVARCHAR(30)
		,@AssigneeMatchInfoNotificationSettingId INT = 5
		,@WatcherMatchInfoNotificationSettingId INT = 9
		,@MyAssignmentUpdatedNotificationSettingId INT = 1 -- assignee
		,@AssigneeTraderUpdatedNotificationSettingId INT = 2
		,@AssigneeLAUpdatedNotificationSettingId INT = 10
		,@WatcherTraderUpdatedNotificationSettingId INT = 6 -- watcher
		,@WatcherLAUpdatedNotificationSettingId INT = 12

	CREATE TABLE #tblAssignee (UserId INT)
	
	CREATE TABLE #tblAssigneeReceiver (
		UserId INT NOT NULL
		)
		
	CREATE TABLE #tblUserInSectionOfAssignee (
		UserId INT NOT NULL
		)
	
	CREATE TABLE #tblMessage (
		MessageContent NVARCHAR(MAX) NOT NULL
		,MessageTypeId INT NOT NULL
		,NotificationSettingId INT NOT NULL
		,UserId INT
		)
		
	CREATE TABLE #tblMessageUser (
		MessageId INT NOT NULL
		,NotificationSettingId INT NOT NULL
		,UserId INT
		)

	-- store current assignee
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
	
	SELECT @OldMatchNo = MatchNo
		,@OldLeagueName = l.OWPLeagueName
		,@OldHomeName = h.OWPTeamName
		,@OldAwayName = a.OWPTeamName
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
	WHERE OWPMatchId = @OWPMatchId

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

	-- create new MinorMatch
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
		,MaxbetCN88 MONEY
		,SpreadCN88 SMALLMONEY
		)

	DELETE ms
	OUTPUT deleted.OWPMatchId
		,deleted.Bettype
		,deleted.Maxbet
		,deleted.Spread
		,deleted.MaxbetCN88
		,deleted.SpreadCN88
	INTO @tblRemoveMatchSetting(OWPMatchId, Bettype, Maxbet, Spread, MaxbetCN88, SpreadCN88)
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

	-- message template
	DECLARE @NewMatchNo VARCHAR(50)
		,@NewLeagueName NVARCHAR(500)
		,@NewHomeName NVARCHAR(200)
		,@NewAwayName NVARCHAR(200)

	SELECT @NewMatchNo = m.MatchNo
		,@NewLeagueName = l.OWPLeagueName
		,@NewHomeName = h.OWPTeamName
		,@NewAwayName = a.OWPTeamName
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
	WHERE m.OWPMatchId = @ParentMatchId
	
	SELECT @EditLeagueMessageTemplateId = MsgTemplateId
		,@EditLeagueMessageTemplate = MsgTemplateContent
	FROM dbo.MessageTemplate WITH (NOLOCK)
	WHERE MsgTemplateCode = 'EditLeague'

	SELECT @EditTeamMessageTemplateId = MsgTemplateId
		,@EditTeamMessageTemplate = MsgTemplateContent
	FROM dbo.MessageTemplate WITH (NOLOCK)
	WHERE MsgTemplateCode = 'EditTeam'
	
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
	
	SELECT @MessageEditMaxbetCN88 = mt.MsgTemplateContent
		,@MessageEditMaxbetCN88Id = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditMaxbetCN88'
	
	SELECT @MessageEditSpread = mt.MsgTemplateContent
		,@MessageEditSpreadId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditSpread'
	
	SELECT @MessageEditSpreadCN88 = mt.MsgTemplateContent
		,@MessageEditSpreadCN88Id = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditSpreadCN88'
	
	SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)
	
	IF dbo.fnc_IsMatchInTimeRange(@OWPMatchId) = 0
	BEGIN
		-- send message for league changed and team changed
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
								@EditLeagueMessageTemplate,
								'<Match.No>', CASE WHEN @MatchNo = '' THEN '' ELSE '#' + @MatchNo END),
							'<League>', @LeagueName),
						'<Event>', @HomeName + ' -vs- ' + @AwayName),
					'<User>', @ActorName),
				'<Old>',@OldLeagueName) AS MessageContent
				,@EditLeagueMessageTemplateId
				,@AssigneeMatchInfoNotificationSettingId
				
			UNION
			
			SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								@EditTeamMessageTemplate,
								'<Match.No>', CASE WHEN @MatchNo = '' THEN '' ELSE '#' + @MatchNo END), 
							'<League>',@LeagueName),
						'<Event>',@HomeName + ' -vs- ' + @AwayName),
					'<User>', @ActorName),
				'<Old>',@OldHomeName + ' -vs- ' + @OldAwayName)AS MessageContent
				,@EditTeamMessageTemplateId
				,@AssigneeMatchInfoNotificationSettingId
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblMessage AS m ON 1 = 0
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
			,m.NotificationSettingId
		INTO #tblMessageUser(MessageId, NotificationSettingId);
		
		INSERT INTO #tblMessageUser(
			UserId
			,MessageId
			,NotificationSettingId
			)
		SELECT ass.UserId
			,m.MessageId
			,m.NotificationSettingId
		FROM #tblMessageUser AS m
			,#tblAssignee AS ass
		
		DELETE #tblMessageUser
		WHERE UserId IS NULL
		
		select * from #tblMessage
		select * from #tblMessageUser
		
		INSERT INTO dbo.MessageUser (
			MessageId
			,UserId
			,SessionId)
		OUTPUT inserted.UserId
		INTO #tblAssigneeReceiver(UserId)
		SELECT m.MessageId, m.UserId, @SessionId
		FROM (
			SELECT ass.UserId, m.MessageId, m.NotificationSettingId
			FROM #tblMessageUser AS m, #tblAssignee AS ass
			) AS m
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = m.NotificationSettingId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = m.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		-- send message for invalid assignment removed
		TRUNCATE TABLE #tblMessage
		TRUNCATE TABLE #tblMessageUser
		
		INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			,NotificationSettingId
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
				,@MyAssignmentUpdatedNotificationSettingId
				,a.UserId
		FROM (
			select 'LA' AS BettypeName
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
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblMessage AS m ON 1 = 0
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
			,m.NotificationSettingId
			,m.UserId
		INTO #tblMessageUser(MessageId, NotificationSettingId, UserId);
		
		select * from #tblMessage
		select * from #tblMessageUser
		
		INSERT INTO dbo.MessageUser (
			MessageId
			,UserId
			,SessionId)
		OUTPUT inserted.UserId
		INTO #tblAssigneeReceiver(UserId)
		SELECT m.MessageId
			,m.UserId
			,@SessionId
		FROM #tblMessageUser AS m
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = m.NotificationSettingId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = m.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
			
		-- send message to inform to match assignee about invalid assignment removed
		TRUNCATE TABLE #tblAssignee
		
		INSERT INTO #tblAssignee (UserId)
		SELECT UserId
		FROM dbo.Assignment WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId AND UserId IS NOT NULL
		
		TRUNCATE TABLE #tblMessage
		TRUNCATE TABLE #tblMessageUser
		
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
				,CASE WHEN a.IsLA = 1 THEN @AssigneeLAUpdatedNotificationSettingId ELSE @AssigneeTraderUpdatedNotificationSettingId END
		FROM (
			select 'LA' AS BettypeName
				,1 AS IsLA
				,a.AssignmentType
				,a.AssignmentNote
				,a.UserId
			FROM @tblRemoveAssignment AS a
			WHERE a.OWPMatchId = @OWPMatchId
			
			UNION
			
			SELECT mb.MinorBettypeName AS BettypeName
				,0 AS IsLA
				,a.AssignmentType
				,a.AssignmentNote
				,a.UserId
			FROM @tblRemoveAssignment AS a
			INNER JOIN @tblRemoveMatch AS rm ON a.OWPMatchId = rm.OWPMatchId
			LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.MinorBettypeId = rm.MinorBettypeId
			WHERE a.OWPMatchId <> @OWPMatchId
		) AS a
		LEFT JOIN dbo.[User] AS u ON a.UserId = u.UserId
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblMessage AS m ON 1 = 0
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
			,m.NotificationSettingId
			,m.UserId
		INTO #tblMessageUser(MessageId, NotificationSettingId, UserId);
		
		select * from #tblMessage
		select * from #tblMessageUser
		
		INSERT INTO dbo.MessageUser (
			MessageId
			,UserId
			,SessionId)
		OUTPUT inserted.UserId
		INTO #tblAssigneeReceiver(UserId)
		SELECT m.MessageId
			,m.UserId
			,@SessionId
		FROM #tblMessageUser AS m
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = m.NotificationSettingId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = m.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		-- send messsage for invalid MaxBet removed
		TRUNCATE TABLE #tblMessage
		TRUNCATE TABLE #tblMessageUser
		
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
									REPLACE(@MessageEditMaxbet
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.MinorBettypeName)
						,'<Old>', ms.Maxbet)
					,'<New>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', @MatchNo) AS MessageContent
			,@MessageEditMaxbetId
			,@AssigneeMatchInfoNotificationSettingId
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
									REPLACE(@MessageEditMaxbetCN88
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.MinorBettypeName)
						,'<Old>', ms.MaxbetCN88)
					,'<New>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', @MatchNo) AS MessageContent
			,@MessageEditMaxbetCN88Id
			,@AssigneeMatchInfoNotificationSettingId
		FROM @tblRemoveMatchSetting AS ms
		INNER JOIN @tblRemoveMatch AS m ON ms.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON m.MinorBettypeId = mb.MinorBettypeId
		WHERE ms.MaxbetCN88 IS NOT NULL
		
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
			,@AssigneeMatchInfoNotificationSettingId
		FROM @tblRemoveMatchSetting AS ms
		INNER JOIN @tblRemoveMatch AS m ON ms.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON m.MinorBettypeId = mb.MinorBettypeId
		WHERE ms.Spread IS NOT NULL
		
		UNION
		
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageEditSpreadCN88
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.MinorBettypeName)
						,'<Old>', ms.SpreadCN88)
					,'<New>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', @MatchNo) AS MessageContent
			,@MessageEditSpreadCN88Id
			,@AssigneeMatchInfoNotificationSettingId
		FROM @tblRemoveMatchSetting AS ms
		INNER JOIN @tblRemoveMatch AS m ON ms.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON m.MinorBettypeId = mb.MinorBettypeId
		WHERE ms.SpreadCN88 IS NOT NULL
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblMessage AS m ON 1 = 0
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
			,m.NotificationSettingId
			,m.UserId
		INTO #tblMessageUser(MessageId, NotificationSettingId, UserId);
		
		INSERT INTO #tblMessageUser(
			UserId
			,MessageId
			,NotificationSettingId
			)
		SELECT ass.UserId
			,m.MessageId
			,m.NotificationSettingId
		FROM #tblMessageUser AS m
			,#tblAssignee AS ass
		
		DELETE #tblMessageUser
		WHERE UserId IS NULL
		
		select * from #tblMessage
		select * from #tblMessageUser
		
		INSERT INTO dbo.MessageUser (
			MessageId
			,UserId
			,SessionId)
		OUTPUT inserted.UserId
		INTO #tblAssigneeReceiver(UserId)
		SELECT m.MessageId
			,m.UserId
			,@SessionId
		FROM #tblMessageUser AS m
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = m.NotificationSettingId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = m.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
	END
	
	IF dbo.fnc_IsMatchInTimeRange(@ParentMatchId) = 0
	BEGIN
		-- send message to parent match assignee to know about new minor match assignment
		TRUNCATE TABLE #tblAssignee
		TRUNCATE TABLE #tblMessage
		TRUNCATE TABLE #tblMessageUser
		
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
							,'<Bettype>', mb.ShortName)
						,'<League>', @LeagueName)
					,'<Match.No>', @MatchNo)
				,'<User>', @ActorName)
				,@MessageChangeOfAssignmentId
				,@AssigneeTraderUpdatedNotificationSettingId
		FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN dbo.MajorBettype AS mb WITH (NOLOCK) ON a.Bettype = mb.BettypeId
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
		WHERE a.OWPMatchId = @OWPMatchId
		
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

		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblMessage AS m ON 1 = 0
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
			,m.NotificationSettingId
		INTO #tblMessageUser(MessageId, NotificationSettingId);
		
		INSERT INTO #tblMessageUser(
			UserId
			,MessageId
			,NotificationSettingId
			)
		SELECT ass.UserId
			,m.MessageId
			,m.NotificationSettingId
		FROM #tblMessageUser AS m
			,#tblAssignee AS ass
			
		DELETE #tblMessageUser
		WHERE UserId IS NULL
		
		select * from #tblMessage
		select * from #tblMessageUser
		
		INSERT INTO dbo.MessageUser (
			MessageId
			,UserId
			,SessionId)
		OUTPUT inserted.UserId
		INTO #tblAssigneeReceiver(UserId)
		SELECT m.MessageId, m.UserId, @SessionId
		FROM (
			SELECT ass.UserId, m.MessageId, m.NotificationSettingId
			FROM #tblMessageUser AS m, #tblAssignee AS ass
			) AS m
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = m.NotificationSettingId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = m.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		-- send message to parent match assignee to know about new match setting
		TRUNCATE TABLE #tblMessage
		TRUNCATE TABLE #tblMessageUser
		
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
									REPLACE(@MessageEditMaxbet
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.ShortName)
						,'<New>', ms.Maxbet)
					,'<Old>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', @MatchNo) AS MessageContent
			,@MessageEditMaxbetId
			,@AssigneeMatchInfoNotificationSettingId
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
									REPLACE(@MessageEditMaxbetCN88
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.ShortName)
						,'<New>', ms.MaxbetCN88)
					,'<Old>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', @MatchNo) AS MessageContent
			,@MessageEditMaxbetCN88Id
			,@AssigneeMatchInfoNotificationSettingId
		FROM dbo.MatchSetting AS ms
		INNER JOIN dbo.MajorBettype as mb ON ms.Bettype = mb.BettypeId
		WHERE ms.OWPMatchId = @OWPMatchId AND ms.MaxbetCN88 IS NOT NULL
		
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
			,'<Match.No>', @MatchNo) AS MessageContent
			,@MessageEditSpreadId
			,@AssigneeMatchInfoNotificationSettingId
		FROM dbo.MatchSetting AS ms
		INNER JOIN dbo.MajorBettype as mb ON ms.Bettype = mb.BettypeId
		WHERE ms.OWPMatchId = @OWPMatchId AND ms.Spread IS NOT NULL
		
		UNION
		
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageEditSpreadCN88
									,'<User>', @ActorName)
								,'<Event>', @HomeName + ' -vs- ' + @AwayName)
							,'<Bettype>', mb.ShortName)
						,'<New>', ms.SpreadCN88)
					,'<Old>', '')
				,'<League>', @LeagueName)
			,'<Match.No>', @MatchNo) AS MessageContent
			,@MessageEditSpreadCN88Id
			,@AssigneeMatchInfoNotificationSettingId
		FROM dbo.MatchSetting AS ms
		INNER JOIN dbo.MajorBettype as mb ON ms.Bettype = mb.BettypeId
		WHERE ms.OWPMatchId = @OWPMatchId AND ms.SpreadCN88 IS NOT NULL
		
		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblMessage AS m ON 1 = 0
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
			,@AssigneeMatchInfoNotificationSettingId
		INTO #tblMessageUser(MessageId, NotificationSettingId);
		
		INSERT INTO #tblMessageUser(
			UserId
			,MessageId
			,NotificationSettingId
			)
		SELECT ass.UserId
			,m.MessageId
			,m.NotificationSettingId
		FROM #tblMessageUser AS m
			,#tblAssignee AS ass
			
		DELETE #tblMessageUser
		WHERE UserId IS NULL
		
		select * from #tblMessage
		select * from #tblMessageUser
		
		INSERT INTO dbo.MessageUser (
			MessageId
			,UserId
			,SessionId)
		OUTPUT inserted.UserId
		INTO #tblAssigneeReceiver(UserId)
		SELECT m.MessageId, m.UserId, @SessionId
		FROM (
			SELECT ass.UserId, m.MessageId, m.NotificationSettingId
			FROM #tblMessageUser AS m, #tblAssignee AS ass
			) AS m
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = m.NotificationSettingId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = m.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
	END
	
	SELECT @ErrCode = 0
		,@ErrMsg = 'The event has been updated successfully!'
	
	DROP TABLE #tblAssignee
	
	DROP TABLE #tblAssigneeReceiver
	
	DROP TABLE #tblUserInSectionOfAssignee
	
	DROP TABLE #tblMessageUser
	
	DROP TABLE #tblMessage
END