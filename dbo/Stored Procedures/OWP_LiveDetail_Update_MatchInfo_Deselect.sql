
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_MatchInfo_Deselect] @ActorId INT
	,@SessionId VARCHAR(50)
	,@OWPMatchId INT
AS
/*
Created: 20190920@Leo.Vo
Task : Remove match
DB: bodb_OWP

Revisions:
	20190920@Leo.Vo: InitialSP - [Redmine: #120496]
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
		
	CREATE TABLE #tblAssignee (
		OWPMatchId INT
		,UserId INT
		)
		
	CREATE TABLE #tblWatcher (
		OWPMatchId INT
		,UserId INT
	)
		
	CREATE TABLE #tblMessage (
		UserId INT
		,OWPMatchId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)
		
	CREATE TABLE #tblAssigneeMessage (
		UserId INT
		,OWPMatchId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		)
		
	CREATE TABLE #tblWatcherMessage (
		UserId INT
		,OWPMatchId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
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

	-- remove match market
	DELETE dbo.MatchMarket WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

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
		
		INSERT INTO #tblAssignee (
			OWPMatchId
			,UserId

		)
		SELECT DISTINCT CASE mm.MinorBettypeId
						WHEN @Specific15MinsNoOfCorners THEN @NoOfCornersMinorMatchId 
						WHEN @Specific15MinsTotalBooking THEN @TotalBookingMinorMatchId
						WHEN @Specific15Mins THEN mm.ParentMatchId
						WHEN @Specific10Mins THEN mm.ParentMatchId
						WHEN @FastMarket THEN mm.ParentMatchId
						WHEN @AllInOne THEN mm.ParentMatchId
						ELSE ass.OWPMatchId END
			,ass.UserId
		FROM #tblRemoveAssignment AS ass
		INNER JOIN @tblRemoveMatchInfo AS mi ON ass.OWPMatchId = mi.OWPMatchId
		LEFT JOIN @tblRemoveMinorMatch AS mm ON mm.MinorMatchId = mi.OWPMatchId
		WHERE UserId IS NOT NULL AND mi.MatchStatus = 'Live'
		
		-- create message content for assignee
		INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			,UserId
			,OWPMatchId
			)
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(@MessageDeleteAssignment
							,'<Event>', h.OWPTeamName + ' -vs- ' + a.OWPTeamName)
						,'<Bettype>', '')
					,'<League>', l.OWPLeagueName)
				,'<Match.No>', CASE WHEN m.MatchNo = '' THEN '' ELSE '#' + m.MatchNo END)
			,'<User>', @ActorName)
			,@MessageDeleteAssignmentId
			,ass.UserId
			,ass.OWPMatchId
		FROM #tblAssignee AS ass
			INNER JOIN @tblRemoveMatch AS m ON ass.OWPMatchId = m.OWPMatchId
			INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
			INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
		
		INSERT INTO #tblAssigneeMessage (
			MessageContent
			,MessageTypeId
			,UserId
			,OWPMatchId
		)
		SELECT m.MessageContent
			,m.MessageTypeId
			,m.UserId
			,m.OWPMatchId
		FROM #tblMessage AS m
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyMyAssignmentUpdatedId
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
					,1
					,m.MessageTypeId
					,0
					)
		OUTPUT inserted.MessageId
			,m.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
		
		TRUNCATE TABLE #tblMessage
		
		-- create message content for watcher
		INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			,UserId
			,OWPMatchId
		)
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageChangeOfAssignment, '<New>', '')
									,'<Old>', '#' + u.Username)
							,'<Event>', h.OWPTeamName + ' -vs- ' + a.OWPTeamName)
						,'<Bettype>', '')
					,'<League>', l.OWPLeagueName)
				,'<Match.No>', CASE WHEN m.MatchNo = '' THEN '' ELSE '#' + m.MatchNo END)
			,'<User>', @ActorName)
			,@MessageChangeOfAssignmentId
			,ass.UserId
			,ass.OWPMatchId
		FROM #tblAssignee AS ass
			INNER JOIN @tblRemoveMatch AS m ON ass.OWPMatchId = m.OWPMatchId
			INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
			INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
			INNER JOIN dbo.[User] AS u ON ass.UserId = u.UserId
			
		INSERT INTO #tblWatcher (
			OWPMatchId
			,UserId
		)
		SELECT DISTINCT ass.OWPMatchId
			,u2.UserId
		FROM #tblAssignee AS ass
		INNER JOIN dbo.[User] AS u1 ON ass.UserId = u1.UserId
		INNER JOIN dbo.[User] AS u2 ON u1.SectionId = u2.SectionId
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyWatcherTraderUpdatedId
		LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = u2.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		INSERT INTO #tblWatcherMessage (
			MessageContent
			,MessageTypeId
			,UserId
			,OWPMatchId
		)
		SELECT DISTINCT m.MessageContent
			,m.MessageTypeId
			,w.UserId
			,m.OWPMatchId
		FROM #tblMessage AS m
		CROSS JOIN #tblWatcher AS w

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
					,1
					)
		OUTPUT inserted.MessageId
			,msn.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
	END

	DROP TABLE #tblRemoveAssignment
	
	DROP TABLE #tblMessage
	
	DROP TABLE #tblAssigneeMessage
	
	DROP TABLE #tblWatcherMessage
	
	DROP TABLE #tblAssignee
	
	DROP TABLE #tblWatcher
END