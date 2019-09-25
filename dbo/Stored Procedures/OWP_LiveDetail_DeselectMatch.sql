
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_DeselectMatch] @ActorId INT
	,@SessionId VARCHAR(50)
	,@OWPMatchId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
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
	
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

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
		,@MyAssignmentUpdatedNotificationSettingId INT = 1 -- assignee
		,@WatcherTraderUpdatedNotificationSettingId INT = 6 -- watcher
		,@WatcherLAUpdatedNotificationSettingId INT = 12
		
	SET @StartRun = GETDATE()

	CREATE TABLE #tblRemoveMatchRecommendOddsIds (MatchRecommendOddsId INT)

	CREATE TABLE #tblRemoveMatchIds (OWPMatchId INT)

	CREATE TABLE #tblRemoveMatch (
		OWPMatchId INT
		,MatchNo VARCHAR(50)
		,OWPLeagueId INT
		,OWPHomeId INT
		,OWPAwayId INT
		)
		
	CREATE TABLE #tblRemoveMinorMatch (
		MinorMatchId INT
		,MinorBettypeId INT
		,ParentMatchId INT
		)

	CREATE TABLE #tblRemoveMatchInfo (
		OWPMatchId INT
		,MatchStatus VARCHAR(15)
		)

	CREATE TABLE #tblRemoveAssignment (
		OWPMatchId INT
		,Bettype INT
		,AssignmentType TINYINT
		,UserId INT
		,AssignmentNote NVARCHAR(200)
		)
		
	CREATE TABLE #tblAssignee (
		OWPMatchId INT
		,UserId INT
		)
		
	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
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

	SELECT @ParentMatchId = ParentMatchId
		,@MinorBettypeId = MinorBettypeId
	FROM dbo.MinorMatch WITH (NOLOCK)
	WHERE MinorMatchId = @OWPMatchId

	IF @ParentMatchId IS NULL
	BEGIN
		INSERT INTO #tblRemoveMatchIds (OWPMatchId)
		SELECT MinorMatchId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId
	END
	ELSE
	BEGIN
		IF @MinorBettypeId = @NoOfCorners
		BEGIN
			INSERT INTO #tblRemoveMatchIds (OWPMatchId)
			SELECT MinorMatchId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId
				AND MinorBettypeId = @Specific15MinsNoOfCorners
		END
		ELSE IF @MinorBettypeId = @TotalBooking
		BEGIN
			INSERT INTO #tblRemoveMatchIds (OWPMatchId)
			SELECT MinorMatchId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId
				AND MinorBettypeId = @Specific15MinsTotalBooking
		END
	END

	INSERT INTO #tblRemoveMatchIds (OWPMatchId)
	VALUES (@OWPMatchId)

	SELECT @ErrMsg = 'The event has been edited successfully!'
		,@ErrCode = 0

	-- remove match market
	DELETE dbo.MatchMarket WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match offers
	DELETE t
	FROM dbo.MatchOfferDetail AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match agent
	DELETE t
	FROM dbo.MatchAgent AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match tv
	DELETE t
	FROM dbo.MatchTelevision AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match provider
	DELETE t
	FROM dbo.MatchProvider AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match other provider
	DELETE t
	FROM dbo.MatchOtherProvider AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match setting
	DELETE t
	FROM dbo.MatchSetting AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remote match odds
	DELETE t
	OUTPUT deleted.MatchRecommendOddsId
	INTO #tblRemoveMatchRecommendOddsIds(MatchRecommendOddsId)
	FROM dbo.MatchRecommendOdds AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	DELETE t
	FROM dbo.MatchRecommendOddsDetail AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchRecommendOddsIds AS s ON t.MatchRecommendOddsId = s.MatchRecommendOddsId

	-- remove match note
	DELETE dbo.MatchNote WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match info
	DELETE t
	OUTPUT deleted.OWPMatchId
		,deleted.MatchStatus
	INTO #tblRemoveMatchInfo(OWPMatchId, MatchStatus)
	FROM dbo.MatchInfo AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- remove match
	DELETE t
	OUTPUT deleted.OWPMatchId
		,deleted.MatchNo
		,deleted.OWPLeagueId
		,deleted.OWPHomeId
		,deleted.OWPAwayId
	INTO #tblRemoveMatch(OWPMatchId, MatchNo, OWPLeagueId, OWPHomeId, OWPAwayId)
	FROM dbo.OWPMatch AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId
		
	-- remove minor match
	DELETE t
	OUTPUT deleted.MinorMatchId
		,deleted.MinorBettypeId
		,deleted.ParentMatchId
	INTO #tblRemoveMinorMatch (
		MinorMatchId
		,MinorBettypeId
		,ParentMatchId
	)
	FROM dbo.MinorMatch AS t WITH (ROWLOCK)
	INNER JOIN #tblRemoveMatch AS m ON t.MinorMatchId = m.OWPMatchId

	-- remove assignment
	DELETE t
	OUTPUT deleted.OWPMatchId
		,deleted.Bettype
		,deleted.AssignmentType
		,deleted.UserId
		,deleted.AssignmentNote
	INTO #tblRemoveAssignment(OWPMatchId, Bettype, AssignmentType, UserId, AssignmentNote)
	FROM dbo.Assignment AS t WITH (ROWLOCK)
		INNER JOIN #tblRemoveMatchIds AS m ON m.OWPMatchId = t.OWPMatchId

	-- send message
	IF @IsMatchInTimeRange = 1
	BEGIN
		SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)
		
		INSERT INTO #tblAssignee (
			OWPMatchId
			,UserId
		)
		SELECT DISTINCT CASE WHEN mm.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking) THEN mm.ParentMatchId ELSE ass.OWPMatchId END
			,ass.UserId
		FROM #tblRemoveAssignment AS ass
		INNER JOIN #tblRemoveMatchInfo AS mi ON ass.OWPMatchId = mi.OWPMatchId
		LEFT JOIN #tblRemoveMinorMatch AS mm ON mm.MinorMatchId = mi.OWPMatchId
		WHERE UserId IS NOT NULL AND mi.MatchStatus = 'Live'
		
		SELECT @MessageDeleteAssignment = mt.MsgTemplateContent
			,@MessageDeleteAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'AssignmentDelete'
		
		SELECT @MessageChangeOfAssignment = mt.MsgTemplateContent
			,@MessageChangeOfAssignmentId = mt.MsgTemplateId
		FROM dbo.MessageTemplate mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'ChangeOfAssignment'
		
		-- create message content for assignee
		INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			,UserId
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
		FROM #tblAssignee AS ass
			INNER JOIN #tblRemoveMatch AS m ON ass.OWPMatchId = m.OWPMatchId
			INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
			INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
		
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
		
		TRUNCATE TABLE #tblMessage
				INSERT INTO #tblMessage (
			MessageContent
			,MessageTypeId
			,UserId
			)
		SELECT REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageChangeOfAssignment, '<New>', '')
									,'<Old>', u.Username)
							,'<Event>', h.OWPTeamName + ' -vs- ' + a.OWPTeamName)
						,'<Bettype>', '')
					,'<League>', l.OWPLeagueName)
				,'<Match.No>', CASE WHEN m.MatchNo = '' THEN '' ELSE '#' + m.MatchNo END)
			,'<User>', @ActorName)
			,@MessageChangeOfAssignmentId
			,ass.UserId
		FROM #tblAssignee AS ass
			INNER JOIN #tblRemoveMatch AS m ON ass.OWPMatchId = m.OWPMatchId
			INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
			INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
			INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
			INNER JOIN dbo.[User] As u WITH (NOLOCK) ON u.UserId = ass.UserId
		
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
			FROM #tblMessage AS m
				INNER JOIN dbo.[User] AS u ON m.UserId = u.UserId
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
					,1
					)
		OUTPUT inserted.MessageId
			,msn.UserId
			,@SessionId
		INTO dbo.MessageUser([MessageId], [UserId], [SessionId]);
	END
	
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_LiveDetail_DeselectMatch'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@Data = NULL
		,@DataOld = NULL

	DROP TABLE #tblRemoveMatchRecommendOddsIds

	DROP TABLE #tblRemoveMatchIds

	DROP TABLE #tblRemoveMatch
	
	DROP TABLE #tblRemoveMinorMatch

	DROP TABLE #tblRemoveMatchInfo

	DROP TABLE #tblRemoveAssignment
	
	DROP TABLE #tblMessage
	
	DROP TABLE #tblAssigneeMessage
	
	DROP TABLE #tblWatcherMessage
	
	DROP TABLE #tblAssignee
END