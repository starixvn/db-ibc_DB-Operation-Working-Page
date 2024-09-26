
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_MatchInfo_Deselect] @ActorId INT
	,@SessionId VARCHAR(50)
	,@OWPMatchId INT
AS
/*
Created: 20190920@Leo.Vo
Task : Remove match
DB: bodb_OWP#

Revisions:
	20190920@Leo.Vo: InitialSP - [Redmine: #120496]
	20191217@Leo.Vo: Change Market column - [Redmine: #124448]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @ParentMatchId INT
		,@MinorBettypeId INT
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@MessageDeleteAssignmentId INT
		,@MessageDeleteAssignment NVARCHAR(500)
		,@MessageDeleteOtherAssignmentId INT
		,@MessageDeleteOtherAssignment NVARCHAR(500)
		,@MessageChangeOfAssignmentId INT
		,@MessageChangeOfAssignment NVARCHAR(500)
		,@ActorName NVARCHAR(30)
		,@IsMatchInTimeRange BIT = dbo.[fnc_IsMatchInTimeRange](@OWPMatchId)
		,@NotifyMyAssignmentUpdatedId INT = 1 -- assignee
		,@NotifyAssigneeTraderUpdatedId INT = 2
		,@NotifyAssigneeLAUpdatedId INT = 10
		,@NotifyWatcherTraderUpdatedId INT = 6 -- watcher
		,@NotifyWatcherLAUpdatedId INT = 12

	DECLARE @tblRemoveMatchIds TABLE (OWPMatchId INT)
	
	DECLARE @tblRemoveMatchRecommendOddsIds TABLE (MatchRecommendOddsId INT)

	DECLARE @tblRemoveMatch TABLE (
		OWPMatchId INT
		,MatchNo VARCHAR(50)
		,OWPLeagueId INT
		,OWPHomeId INT
		,OWPAwayId INT
		)
		
	DECLARE @tblRemoveMinorMatch TABLE (
		MinorMatchId INT
		,MinorBettypeId INT
		,ParentMatchId INT
		)

	DECLARE @tblRemoveMatchInfo TABLE (
		OWPMatchId INT
		,MatchStatus VARCHAR(15)
		)

	CREATE TABLE #tblRemoveAssignment (
		AssignmentId INT
		,OWPMatchId INT
		,Bettype INT
		,AssignmentType TINYINT
		,UserId INT
		,AssignmentNote NVARCHAR(200)
		)
	
	CREATE TABLE #tblMessage (
		MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)
		
	CREATE TABLE #tblAssigneeMessageIds (
		MessageId INT
	)
	
	CREATE TABLE #tblAssigneeMessageUser (
		MessageId INT
		,UserId INT
	)
	
	CREATE TABLE #tblWatcherMessageIds (
		MessageId INT
	)
		
	CREATE TABLE #tblUserMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)
		
	CREATE TABLE #tblAssigneeReceivingNotification (
		UserId INT
		)
	
	CREATE TABLE #tblWatcherReceivingNotification (
		UserId INT
		)

	SELECT @ParentMatchId = ParentMatchId
		,@MinorBettypeId = MinorBettypeId
	FROM dbo.MinorMatch WITH (NOLOCK)
	WHERE MinorMatchId = @OWPMatchId
	
	INSERT INTO @tblRemoveMatchIds (OWPMatchId)
	VALUES (@OWPMatchId)

	IF @ParentMatchId IS NULL
	BEGIN
		INSERT INTO @tblRemoveMatchIds (OWPMatchId)
		SELECT MinorMatchId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId
	END
	ELSE
	BEGIN
		IF @MinorBettypeId = @NoOfCorners
		BEGIN
			INSERT INTO @tblRemoveMatchIds (OWPMatchId)
			SELECT MinorMatchId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId
				AND MinorBettypeId = @Specific15MinsNoOfCorners
		END
		ELSE IF @MinorBettypeId = @TotalBooking
		BEGIN
			INSERT INTO @tblRemoveMatchIds (OWPMatchId)
			SELECT MinorMatchId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId
				AND MinorBettypeId = @Specific15MinsTotalBooking
		END
	END

	-- remove match offers
	DELETE t
	FROM dbo.MatchOfferDetail AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match agent
	DELETE t
	FROM dbo.MatchAgent AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match tv
	DELETE t
	FROM dbo.MatchTelevision AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match provider
	DELETE t
	FROM dbo.MatchProvider AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match other provider
	DELETE t
	FROM dbo.MatchOtherProvider AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match setting
	DELETE t
	FROM dbo.MatchSetting AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remote match odds
	DELETE t
	OUTPUT deleted.MatchRecommendOddsId
	INTO @tblRemoveMatchRecommendOddsIds(MatchRecommendOddsId)
	FROM dbo.MatchRecommendOdds AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	DELETE t
	FROM dbo.MatchRecommendOddsDetail AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchRecommendOddsIds AS s ON t.MatchRecommendOddsId = s.MatchRecommendOddsId

	-- remove match note
	DELETE dbo.MatchNote WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match info
	DELETE t
	OUTPUT deleted.OWPMatchId
		,deleted.MatchStatus
	INTO @tblRemoveMatchInfo(OWPMatchId, MatchStatus)
	FROM dbo.MatchInfo AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match
	DELETE t
	OUTPUT deleted.OWPMatchId
		,deleted.MatchNo
		,deleted.OWPLeagueId
		,deleted.OWPHomeId
		,deleted.OWPAwayId
	INTO @tblRemoveMatch(OWPMatchId, MatchNo, OWPLeagueId, OWPHomeId, OWPAwayId)
	FROM dbo.OWPMatch AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId
		
	-- remove minor match
	DELETE t
	OUTPUT deleted.MinorMatchId
		,deleted.MinorBettypeId
		,deleted.ParentMatchId
	INTO @tblRemoveMinorMatch (
		MinorMatchId
		,MinorBettypeId
		,ParentMatchId
	)
	FROM dbo.MinorMatch AS t WITH (ROWLOCK)
	INNER JOIN @tblRemoveMatch AS m ON t.MinorMatchId = m.OWPMatchId

	-- remove assignment
	DELETE t
	OUTPUT deleted.AssignmentId
		,deleted.OWPMatchId
		,deleted.Bettype
		,deleted.AssignmentType
		,deleted.UserId
		,deleted.AssignmentNote
	INTO #tblRemoveAssignment(AssignmentId, OWPMatchId, Bettype, AssignmentType, UserId, AssignmentNote)
	FROM dbo.Assignment AS t WITH (ROWLOCK)
		INNER JOIN @tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- send message
	IF @IsMatchInTimeRange = 1
	BEGIN
		SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)
		
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
		
		DECLARE @NoOfCornersMinorMatchId INT
			,@TotalBookingMinorMatchId INT
			
		SELECT @NoOfCornersMinorMatchId = MinorMatchId
		FROM @tblRemoveMinorMatch
		WHERE ParentMatchId = @ParentMatchId AND MinorBettypeId = @NoOfCorners
		
		SELECT @TotalBookingMinorMatchId = MinorMatchId
		FROM @tblRemoveMinorMatch
		WHERE ParentMatchId = @ParentMatchId AND MinorBettypeId = @TotalBooking
		
		DECLARE @tblAssignment TABLE (
			OWPMatchId INT
			,AssignmentType TINYINT
			,UserId INT
			,AssignmentNote NVARCHAR(200)
			,LeagueName NVARCHAR(500)
			,EventName NVARCHAR(500)
			,MatchNo NVARCHAR(100)
		)
		
		INSERT INTO @tblAssignment (
			OWPMatchId
			,AssignmentType
			,UserId
			,AssignmentNote
		)
		SELECT DISTINCT CASE mm.MinorBettypeId
						WHEN @Specific15MinsNoOfCorners THEN @NoOfCornersMinorMatchId 
						WHEN @Specific15MinsTotalBooking THEN @TotalBookingMinorMatchId
						WHEN @Specific15Mins THEN mm.ParentMatchId
						WHEN @Specific10Mins THEN mm.ParentMatchId
						WHEN @FastMarket THEN mm.ParentMatchId
						WHEN @AllInOne THEN mm.ParentMatchId
						ELSE ass.OWPMatchId END
			,ass.AssignmentType
			,ass.UserId
			,ass.AssignmentNote
		FROM #tblRemoveAssignment AS ass
		INNER JOIN @tblRemoveMatchInfo AS mi ON ass.OWPMatchId = mi.OWPMatchId
		LEFT JOIN @tblRemoveMinorMatch AS mm ON mm.MinorMatchId = mi.OWPMatchId
		WHERE mi.MatchStatus = 'Live'
		
		UPDATE ass
		SET ass.MatchNo = CASE WHEN m.MatchNo = '' THEN '' ELSE '#' + m.MatchNo END
			,ass.EventName = h.OWPTeamName + ' -vs- ' + a.OWPTeamName
			,ass.LeagueName = l.OWPLeagueName
		FROM @tblAssignment AS ass
		INNER JOIN @tblRemoveMatch AS m ON ass.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
		
		-- create message content for assignment removed
		INSERT INTO #tblUserMessage (
			MessageContent
			,MessageTypeId
			,UserId
			)
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(CASE 
									WHEN ass.AssignmentType = 1 THEN @MessageDeleteAssignment
									ELSE REPLACE(@MessageDeleteOtherAssignment, '<Note>', RTRIM(LTRIM(REPLACE(ass.AssignmentNote, '#<user>', ''))))
									END
							,'<Event>', ass.EventName)
						,'<Bettype>', '')
					,'<League>', ass.LeagueName)
				,'<Match.No>', ass.MatchNo)
			,'<User>', @ActorName)
			,CASE 
				WHEN ass.AssignmentType = 1 THEN @MessageDeleteAssignmentId
				ELSE @MessageDeleteOtherAssignmentId
				END
			,ass.UserId
		FROM @tblAssignment AS ass
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyMyAssignmentUpdatedId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = ass.UserId
		WHERE ass.UserId IS NOT NULL
			AND ISNULL(nsm.Value, ns.DefaultValue) = 'True'

		MERGE dbo.[Message] WITH (ROWLOCK) AS ms
		USING #tblUserMessage AS m ON 1 = 0
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
		
		-- create message content for assignment updated
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
									REPLACE(@MessageChangeOfAssignment, '<New>', '')
									,'<Old>', CASE 
										WHEN ass.AssignmentType = 1 THEN '#' + u.Username
										ELSE RTRIM(LTRIM(REPLACE(ass.AssignmentNote, '#<user>', CASE WHEN u.UserId IS NULL THEN '' ELSE '#' + u.Username END)))
										END)
							,'<Event>', ass.EventName)
						,'<Bettype>', '')
					,'<League>', ass.LeagueName)
				,'<Match.No>', ass.MatchNo)
			,'<User>', @ActorName)
			,@MessageChangeOfAssignmentId
		FROM @tblAssignment AS ass
		LEFT JOIN dbo.[User] AS u ON ass.UserId = u.UserId
		
		SELECT @ParentMatchId = ISNULL(@ParentMatchId, @OWPMatchId)
		
		INSERT INTO #tblAssigneeReceivingNotification (
			UserId
			)
		SELECT ass.UserId
		FROM (
			SELECT a.UserId
			FROM (
				SELECT @ParentMatchId AS OWPMatchId
				
				UNION
				
				SELECT MinorMatchId AS OWPMatchId
				FROM dbo.MinorMatch WITH (NOLOCK)
				WHERE ParentMatchId = @ParentMatchId
				) AS m
			INNER JOIN dbo.Assignment AS a ON m.OWPMatchId = a.OWPMatchId
			WHERE a.UserId IS NOT NULL
			
			UNION
			
			SELECT ass.UserId
			FROM @tblAssignment AS ass
			WHERE ass.UserId IS NOT NULL
		) AS ass
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyAssigneeTraderUpdatedId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = ass.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		IF EXISTS(
			SELECT 1
			FROM #tblAssigneeReceivingNotification
			)
		BEGIN
			INSERT INTO dbo.[Message] (
				MessageContent
				,CreatedBy
				,IsImportant
				,MessageType
				,IsWatcher
				)
			OUTPUT inserted.MessageId
			INTO #tblAssigneeMessageIds(MessageId)
			SELECT m.MessageContent
				,@ActorId
				,0
				,m.MessageTypeId
				,0
			FROM #tblMessage AS m
			
			INSERT INTO dbo.MessageUser (
				MessageId
				,UserId
				,SessionId
				)
			OUTPUT inserted.MessageId, inserted.UserId
			INTO #tblAssigneeMessageUser (MessageId, UserId)
			SELECT m.MessageId
				,u.UserId
				,@SessionId
			FROM #tblAssigneeMessageIds AS m
			CROSS JOIN #tblAssigneeReceivingNotification AS u
		END
		
		-- create message content for watcher
		INSERT INTO #tblWatcherReceivingNotification (
			UserId
		)
		SELECT DISTINCT u2.UserId
		FROM @tblAssignment AS ass
		INNER JOIN dbo.[User] AS u1 ON ass.UserId = u1.UserId
		INNER JOIN dbo.[User] AS u2 ON u1.SectionId = u2.SectionId
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyWatcherTraderUpdatedId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = u2.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		IF EXISTS(
			SELECT 1
			FROM #tblWatcherReceivingNotification
			)
		BEGIN
			INSERT INTO dbo.[Message] (
				MessageContent
				,CreatedBy
				,IsImportant
				,MessageType
				,IsWatcher
				)
			OUTPUT inserted.MessageId
			INTO #tblWatcherMessageIds (MessageId)
			SELECT m.MessageContent
				,@ActorId
				,0
				,m.MessageTypeId
				,1
			FROM #tblMessage AS m
			
			INSERT INTO dbo.MessageUser (
				MessageId
				,UserId
				,SessionId
				)
			SELECT m.MessageId
				,u.UserId
				,@SessionId
			FROM #tblWatcherMessageIds AS mid
			INNER JOIN dbo.[Message] AS m ON mid.MessageId = m.MessageId
			CROSS JOIN #tblWatcherReceivingNotification AS u
			WHERE NOT EXISTS (
				SELECT 1
				FROM #tblAssigneeMessageUser AS mu
				INNER JOIN dbo.[Message] AS m2 ON mu.MessageId = m2.MessageId
				WHERE mu.UserId = u.UserId
					AND m2.MessageContent = m.MessageContent
			)
		END
	END

	DROP TABLE #tblRemoveAssignment
	
	DROP TABLE #tblUserMessage
	
	DROP TABLE #tblMessage
	
	DROP TABLE #tblAssigneeMessageIds
	
	DROP TABLE #tblWatcherMessageIds
	
	DROP TABLE #tblAssigneeMessageUser
	
	DROP TABLE #tblAssigneeReceivingNotification
	
	DROP TABLE #tblWatcherReceivingNotification
END