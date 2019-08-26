
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_MatchInfo] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@Remark NVARCHAR(2000) = ''
	,@InfoSiteMatchId INT = NULL
	,@IsSoloMatch BIT = 0
	,@Round NVARCHAR(2000) = ''
	,@Division NVARCHAR(2000) = ''
	,@Venue NVARCHAR(100) = ''
	,@OtherTime DATETIME = NULL
	,@MarketIds NVARCHAR(100) = ''
	,@Website1 NVARCHAR(1000) = ''
	,@Website2 NVARCHAR(1000) = ''
	,@Website3 NVARCHAR(1000) = ''
	,@Website4 NVARCHAR(1000) = ''
	,@MatchStatus NVARCHAR(15)
	,@IsSelected BIT = 0
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20190820@Tyler.Dang
Task : Update MatchInfo section Edit Event  
DB: bodb_OWP
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT @ErrMsg = 'The event has been edited successfully!'
		,@ErrCode = 0
	
	EXEC [dbo].[OWP_LiveDetail_MatchInfo_UpdateMatchStatus] @ActorId, @SessionId, @OWPMatchId, @MatchStatus, @ErrCode OUTPUT, @ErrMsg OUTPUT
	IF @ErrCode <> 0 RETURN

	EXEC [dbo].[OWP_MatchInfo_UpdateIsSelected] @ActorId, @OWPMatchId, @IsSelected, @ErrCode OUTPUT, @ErrMsg OUTPUT
	IF @ErrCode <> 0 RETURN

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML
		,@OldRemark NVARCHAR(2000)
		,@OldIsSoloMatch BIT
		,@OldRound NVARCHAR(2000)
		,@OldDivision NVARCHAR(2000)
		,@OldVenue NVARCHAR(100)
		,@OldOtherTime TIME
		,@OldInfoSiteMatchId INT
		,@OldMarketIds NVARCHAR(100)
		,@OldWebsite1 NVARCHAR(1000)
		,@OldWebsite2 NVARCHAR(1000)
		,@OldWebsite3 NVARCHAR(1000)
		,@OldWebsite4 NVARCHAR(1000)
		-- send message by condition date
		,@UserReceivedAssigneeMessageMatchInfo TVP_INT
		,@UserReceivedAssigneeMessageProviderInfo TVP_INT
		,@UserReceivedWatcherMessageMatchInfo TVP_INT
		,@UserReceivedWatcherMessageProviderInfo TVP_INT
		,@MessageTemplate NVARCHAR(2000) = ''
		,@MessageTypeId INT
		,@ActorName NVARCHAR(30)
		,@OldValue NVARCHAR(500)
		,@NewValue NVARCHAR(500)
		,@HomeTeamName NVARCHAR(200)
		,@AwayTeamName NVARCHAR(200)
		,@EventDateTime DATETIME
		,@NewOtherTime TIME
		,@CurrentDateTimeGMTplus8 DATETIME = DATEADD(HOUR, 12, GETDATE())
		,@MatchNo VARCHAR(50)
		,@League NVARCHAR(500)
		-- Notification Setting
		,@NotifyAssigneeMatchInfoUpdatedId INT = 5
		,@NotifyWatcherMatchInfoUpdatedId INT = 9

	CREATE TABLE #tblOldItem (
		Id INT
		,[Text] NVARCHAR(100)
		)

	CREATE TABLE #tblNewItem (
		Id INT
		,[Text] NVARCHAR(100)
		)
				
	CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
		,NotificationSettingId INT
		)
	
	SELECT @OldMarketIds = COALESCE(@OldMarketIds + ', ', '') + CAST(MarketId AS NVARCHAR)
	FROM dbo.MatchMarket WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId
	
	-- save old value 
	SELECT @OldRemark = m.Remark
		,@OldIsSoloMatch = m.IsSoloMatch
		,@OldRound = m.[Round]
		,@OldDivision = m.Division
		,@OldVenue = m.Venue
		,@OldOtherTime = om.OtherTime
		,@OldWebsite1 = m.Website1
		,@OldWebsite2 = m.Website2
		,@OldWebsite3 = m.Website3
		,@OldWebsite4 = m.Website4
		,@OldInfoSiteMatchId = om.InfoSiteMatchId
	FROM dbo.MatchInfo m WITH (NOLOCK)
		LEFT JOIN dbo.OWPMatch om WITH (NOLOCK) ON om.OWPMatchId = m.OWPMatchId
	WHERE m.OWPMatchId = @OWPMatchId					 
 
 -- Log  
	SET @StartRun = GETDATE()
	
	SET @Xml = (
			SELECT @OldRemark AS '@rm'
				,@OldIsSoloMatch AS '@sl'
				,@OldRound AS '@rd'
				,@OldDivision AS '@ds'
				,@OldVenue AS '@vn'
				,@OldOtherTime AS '@ot'
				,@OldWebsite1 AS '@ws1'
				,@OldWebsite2 AS '@ws2'
				,@OldWebsite3 AS '@ws3'
				,@OldWebsite4 AS '@ws4'
				,@OldInfoSiteMatchId AS '@ifi'
				,@OldMarketIds AS '@mk'
			FROM dbo.MatchInfo AS info WHERE info.OWPMatchId = @OWPMatchId
			FOR XML PATH('z')
				,ROOT('r')
			)
			 
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	-- update new value
	UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
	SET Remark = @Remark
		,IsSoloMatch = @IsSoloMatch
		,[Round] = @Round
		,Division = @Division
		,Venue = @Venue
		,Website1 = @Website1
		,Website2 = @Website2
		,Website3 = @Website3
		,Website4 = @Website4
	WHERE OWPMatchId = @OWPMatchId

	UPDATE dbo.OWPMatch WITH (ROWLOCK, UPDLOCK)
	SET OtherTime = @OtherTime
		,InfoSiteMatchId = @InfoSiteMatchId
	WHERE OWPMatchId = @OWPMatchId

	-- handle changes of Match Market
	DELETE
	FROM dbo.MatchMarket
	WHERE OWPMatchId = @OWPMatchId

	IF (ISNULL(@MarketIds, '') != '')
	BEGIN
		INSERT INTO dbo.MatchMarket (
		OWPMatchId
		,MarketId
		)
		SELECT @OWPMatchId
			,val
		FROM dbo.strSplit(ISNULL(@MarketIds, ''), ',')
	END
	
	-- send message edit if in time range
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)

		SELECT @HomeTeamName = home.OWPTeamName
			,@AwayTeamName = away.OWPTeamName
			,@EventDateTime = om.EventDateTime
			,@MatchNo = CASE WHEN om.MatchNo = '' THEN '' ELSE '#' + om.MatchNo END
			,@League = ol.OWPLeagueName
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			LEFT JOIN dbo.OWPLeague AS ol WITH (NOLOCK) ON om.OWPLeagueId = ol.OWPLeagueId
		WHERE om.OWPMatchId = @OWPMatchId

		SELECT @NewOtherTime = CAST(@OtherTime AS TIME)

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
			AND ns.NotificationSettingId = @NotifyWatcherMatchInfoUpdatedId
			) AS r
		LEFT JOIN dbo.[User] AS mem WITH (NOLOCK) ON r.SectionId = mem.SectionId AND mem.SectionId IS NOT NULL

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


		-- Edit Other time
		IF (
			@OldOtherTime IS NOT NULL
			AND @NewOtherTime IS NOT NULL
			AND @OldOtherTime <> @NewOtherTime
			)
		OR (
			@OldOtherTime IS NULL
			AND @NewOtherTime IS NOT NULL
			)
		OR (
			@OldOtherTime IS NOT NULL
			AND @NewOtherTime IS NULL
			)
		BEGIN
			SELECT @OldValue = ISNULL(CONVERT(NVARCHAR(10), @OldOtherTime, 100), '')
				,@NewValue = ISNULL(CONVERT(NVARCHAR(10), @NewOtherTime, 100), '')

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditOtherTime'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

		-- Edit Round
		IF @OldRound <> @Round
		BEGIN
			SELECT @OldValue = @OldRound
				,@NewValue = @Round

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditRound'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

		-- Edit Division
		IF @OldDivision <> @Division
		BEGIN
			SELECT @OldValue = @OldDivision
				,@NewValue = @Division

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditDivision'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

		-- Edit Remark
		IF @OldRemark <> @Remark
		BEGIN
			SELECT @OldValue = @OldRemark
				,@NewValue = @Remark

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditRemark'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

		-- Edit Venue
		IF @OldVenue <> @Venue
		BEGIN
			SELECT @OldValue = @OldVenue
				,@NewValue = @Venue

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditVenue'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

		-- Edit Market
		TRUNCATE TABLE #tblOldItem
		TRUNCATE TABLE #tblNewItem

		INSERT INTO #tblOldItem (
			Id
			,[Text]
			)
		SELECT rr.ResourceId
			,rr.Value
		FROM dbo.RefResource AS rr WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(@OldMarketIds, ',') AS f
		WHERE rr.RefName = 'Market'
			AND rr.ResourceId = f.val

		INSERT INTO #tblNewItem (
			Id
			,[Text]
			)
		SELECT rr.ResourceId
			,rr.Value
		FROM dbo.RefResource AS rr WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(@MarketIds, ',') AS f
		WHERE rr.RefName = 'Market'
			AND rr.ResourceId = f.val

		IF EXISTS (
				SELECT Id
				FROM #tblOldItem
				
				EXCEPT
				SELECT Id
				FROM #tblNewItem
				)
			OR EXISTS (
				SELECT Id
				FROM #tblNewItem
				
				EXCEPT
				SELECT Id
				FROM #tblOldItem
				)
		BEGIN
			SELECT @OldValue = ISNULL(STUFF((
							SELECT ', ' + [Text]
							FROM #tblOldItem WITH (NOLOCK)
							FOR XML PATH('')
							), 1, 2, ''), '')
				,@NewValue = ISNULL(STUFF((
							SELECT ', ' + [Text]
							FROM #tblNewItem WITH (NOLOCK)
							FOR XML PATH('')
							), 1, 2, ''), '')

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditMarket'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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
		
		-- Edit InfoSiteId
		IF @OldInfoSiteMatchId <> @InfoSiteMatchId
		BEGIN
			SELECT @OldValue = @OldInfoSiteMatchId
				,@NewValue = @InfoSiteMatchId

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditInfoSiteMatchId'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

		-- Edit Website1
		IF @OldWebsite1 <> @Website1
		BEGIN
			SELECT @OldValue = @OldWebsite1
				,@NewValue = @Website1

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditWebsite1'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

		-- Edit Website2
		IF @OldWebsite2 <> @Website2
		BEGIN
			SELECT @OldValue = @OldWebsite2
				,@NewValue = @Website2

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditWebsite2'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

		-- Edit Website3
		IF @OldWebsite3 <> @Website3
		BEGIN
			SELECT @OldValue = @OldWebsite3
				,@NewValue = @Website3

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditWebsite3'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

		-- Edit Website4
		IF @OldWebsite4 <> @Website4
		BEGIN
			SELECT @OldValue = @OldWebsite4
				,@NewValue = @Website4

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditWebsite4'

			SELECT @MessageTemplate = REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(@MessageTemplate, '<User>', @ActorName)
														, '<Match.No>', @MatchNo)
													, '<League>', @League)
												, '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
											, '<Old>', @OldValue)
										, '<New>', @NewValue)

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

	-- For write log  
	SET @Xml = (
			SELECT info.Remark AS '@rm'
					,info.IsSoloMatch AS '@sl'
					,info.[Round] AS '@rd'
					,info.Division AS '@ds'
					,info.Venue AS '@vn'
					,om.OtherTime AS '@ot'
					,info.Website1 AS '@ws1'
					,info.Website2 AS '@ws2'
					,info.Website3 AS '@ws3'
					,info.Website4 AS '@ws4'
					,om.InfoSiteMatchId AS '@ifi'
			FROM dbo.MatchInfo AS info WITH (NOLOCK)
				LEFT JOIN OWPMatch AS om WITH (NOLOCK) ON info.OWPMatchId = om.OWPMatchId
			WHERE @OWPMatchId = info.OWPMatchId
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_LiveDetail_Update_MatchInfo'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @ActorId
		,@Data = @LogData
		,@DataOld = @LogDataOld

	DROP TABLE #tblOldItem

	DROP TABLE #tblNewItem

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END