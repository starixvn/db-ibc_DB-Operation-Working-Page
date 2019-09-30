
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_MatchInfo_OtherInfo] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@ParentMatchId INT
	,@MinorBettypeId INT
	,@Remark NVARCHAR(2000) = ''
	,@IsUpdateRemark BIT = 0
	,@InfoSiteMatchId INT = NULL
	,@IsUpdateInfoSiteMatchId BIT = 0
	,@Round NVARCHAR(2000) = ''
	,@IsUpdateRound BIT = 0
	,@Division NVARCHAR(2000) = ''
	,@IsUpdateDivision BIT = 0
	,@Venue NVARCHAR(100) = ''
	,@IsUpdateVenue BIT = 0
	,@OtherTime DATETIME = NULL
	,@IsUpdateOtherTime BIT = 0
	,@MarketIds NVARCHAR(100) = ''
	,@IsUpdateMarkets BIT = 0
	,@Website1 NVARCHAR(1000) = ''
	,@IsUpdateWebsite1 BIT = 0
	,@Website2 NVARCHAR(1000) = ''
	,@IsUpdateWebsite2 BIT = 0
	,@Website3 NVARCHAR(1000) = ''
	,@IsUpdateWebsite3 BIT = 0
	,@Website4 NVARCHAR(1000) = ''
	,@IsUpdateWebsite4 BIT = 0
	,@IsMatchInTimeRange BIT
AS
/*
Created: 20190820@Leo.Vo
Task : Update other match info called from SP
DB: bodb_OWP

Revisions:
	20190820@Leo.Vo: Initial SP - [Redmine: #120496]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @UserReceivedAssigneeMessageMatchInfo TVP_INT
		,@UserReceivedAssigneeMessageProviderInfo TVP_INT
		,@UserReceivedWatcherMessageMatchInfo TVP_INT
		,@UserReceivedWatcherMessageProviderInfo TVP_INT
		,@CurrentDateTimeGMTplus8 DATETIME = DATEADD(HOUR, 12, GETDATE())
		-- Notification Setting
		,@NotifyAssigneeMatchInfoUpdatedId INT = 5
		,@NotifyWatcherMatchInfoUpdatedId INT = 9
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8

	-- build relevant matches
	CREATE TABLE #tblRelevantMatches (
		OWPMatchId INT
		,MinorBettypeId INT
		)

	INSERT INTO #tblRelevantMatches (
		OWPMatchId
		,MinorBettypeId
		)
	VALUES (
		@OWPMatchId
		,@MinorBettypeId
		)

	IF @ParentMatchId IS NULL
	BEGIN
		INSERT INTO #tblRelevantMatches (
			OWPMatchId
			,MinorBettypeId
			)
		SELECT MinorMatchId
			,MinorBettypeId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId
			AND MinorBettypeId IN (@FastMarket, @AllInOne, @Specific10Mins, @Specific15Mins)
	END
	ELSE
	BEGIN
		IF @MinorBettypeId = @NoOfCorners
		BEGIN
			INSERT INTO #tblRelevantMatches (
				OWPMatchId
				,MinorBettypeId
				)
			SELECT MinorMatchId
				,MinorBettypeId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId
				AND MinorBettypeId = @Specific15MinsNoOfCorners
		END
		ELSE IF @MinorBettypeId = @TotalBooking
		BEGIN
			INSERT INTO #tblRelevantMatches (
				OWPMatchId
				,MinorBettypeId
				)
			SELECT MinorMatchId
				,MinorBettypeId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId
				AND MinorBettypeId = @TotalBooking
		END
	END

	DECLARE @OldRemark NVARCHAR(2000)
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
		,@OldMarket NVARCHAR(2000)
		,@NewRemark NVARCHAR(2000)
		,@NewRound NVARCHAR(2000)
		,@NewDivision NVARCHAR(2000)
		,@NewVenue NVARCHAR(100)
		,@NewOtherTime TIME
		,@NewInfoSiteMatchId INT
		,@NewMarketIds NVARCHAR(100)
		,@NewWebsite1 NVARCHAR(1000)
		,@NewWebsite2 NVARCHAR(1000)
		,@NewWebsite3 NVARCHAR(1000)
		,@NewWebsite4 NVARCHAR(1000)
		,@NewMarket NVARCHAR(2000)

	SELECT @OldRemark = mi.Remark
		,@OldRound = mi.[Round]
		,@OldDivision = mi.Division
		,@OldVenue = mi.Venue
		,@OldOtherTime = m.OtherTime
		,@OldWebsite1 = mi.Website1
		,@OldWebsite2 = mi.Website2
		,@OldWebsite3 = mi.Website3
		,@OldWebsite4 = mi.Website4
		,@OldInfoSiteMatchId = m.InfoSiteMatchId
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
	WHERE m.OWPMatchId = @OWPMatchId

	SELECT @NewRemark = CASE 
			WHEN @IsUpdateRemark = 1 THEN @Remark
			ELSE @OldRemark
			END
		,@NewRound = CASE 
			WHEN @IsUpdateRound = 1 THEN @Round
			ELSE @OldRound
			END
		,@NewDivision = CASE 
			WHEN @IsUpdateDivision = 1 THEN @Division
			ELSE @OldDivision
			END
		,@NewVenue = CASE 
			WHEN @IsUpdateVenue = 1 THEN @Venue
			ELSE @OldVenue
			END
		,@NewOtherTime = CASE 
			WHEN @IsUpdateOtherTime = 1 THEN @OtherTime
			ELSE @OldOtherTime
			END
		,@NewWebsite1 = CASE 
			WHEN @IsUpdateWebsite1 = 1 THEN @Website1
			ELSE @OldWebsite1
			END
		,@NewWebsite2 = CASE 
			WHEN @IsUpdateWebsite2 = 1 THEN @Website2
			ELSE @OldWebsite2
			END
		,@NewWebsite3 = CASE 
			WHEN @IsUpdateWebsite3 = 1 THEN @Website3
			ELSE @OldWebsite3
			END
		,@NewWebsite4 = CASE 
			WHEN @IsUpdateWebsite4 = 1 THEN @Website4
			ELSE @OldWebsite4
			END
		,@NewInfoSiteMatchId = CASE 
			WHEN @IsUpdateInfoSiteMatchId = 1 THEN @InfoSiteMatchId
			ELSE @OldInfoSiteMatchId
			END

	UPDATE m
	SET m.InfoSiteMatchId = @NewInfoSiteMatchId
		,m.OtherTime = @NewOtherTime
	FROM dbo.OWPMatch AS m WITH (ROWLOCK)
		INNER JOIN #tblRelevantMatches AS rm ON m.OWPMatchId = rm.OWPMatchId

	UPDATE mi
	SET mi.Remark = @NewRemark
		,mi.[Round] = @NewRound
		,mi.Division = @NewDivision
		,mi.Venue = @NewVenue
		,mi.Website1 = @NewWebsite1
		,mi.Website2 = @NewWebsite2
		,mi.Website3 = @NewWebsite3
		,mi.Website4 = @NewWebsite4
	FROM dbo.MatchInfo AS mi WITH (ROWLOCK)
		INNER JOIN #tblRelevantMatches AS rm ON mi.OWPMatchId = rm.OWPMatchId
		
	IF @IsUpdateMarkets = 1
	BEGIN
		DECLARE @tblNewMarketIds TABLE (
			MarketId INT
		)
		INSERT INTO @tblNewMarketIds (
			MarketId
			)
		SELECT val
		FROM dbo.strSplit(ISNULL(@MarketIds, ''), ',')
		
		SELECT @OldMarket = ISNULL(STUFF((
			SELECT ', ' + CAST(r.Value AS NVARCHAR)
			FROM dbo.MatchMarket AS mk WITH (NOLOCK)
			INNER JOIN dbo.RefResource AS r WITH (NOLOCK) ON mk.MarketId = r.ResourceId AND r.RefName = 'Market'
			WHERE OWPMatchId = @OWPMatchId
			FOR XML PATH('')
			), 1, 2, ''), '')
			
		SELECT @NewMarket = ISNULL(STUFF((
			SELECT ', ' + CAST(r.Value AS NVARCHAR)
			FROM @tblNewMarketIds AS mk
			INNER JOIN dbo.RefResource AS r WITH (NOLOCK) ON mk.MarketId = r.ResourceId AND r.RefName = 'Market'
			FOR XML PATH('')
			), 1, 2, ''), '')
			
		IF @OldMarket <> @NewMarket
		BEGIN
			DELETE dbo.MatchMarket WITH (ROWLOCK)
			WHERE OWPMatchId = @OWPMatchId
			
			INSERT INTO dbo.MatchMarket (
				OWPMatchId
				,MarketId
			)
			SELECT @OWPMatchId
				,MarketId
			FROM @tblNewMarketIds
		END
	END
	
	CREATE TABLE #tblMessage (
		MessageContent NVARCHAR(MAX)
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
		DECLARE @EventName NVARCHAR(MAX)
			,@MatchNo VARCHAR(50)
			,@LeagueName NVARCHAR(500)
			,@ActorName VARCHAR(30)
			,@MessageTemplate NVARCHAR(2000) = ''
			,@MessageTypeId INT
			,@MessageContent NVARCHAR(MAX) = ''
			,@OldValue NVARCHAR(2000)
			,@NewValue NVARCHAR(2000)
			
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
		
		SELECT @OldValue = @OldMarket
			,@NewValue = @NewMarket
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditMarket'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = @OldInfoSiteMatchId
			,@NewValue = @NewInfoSiteMatchId
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditInfositeMatchId'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = ISNULL(CONVERT(NVARCHAR(10), @OldOtherTime, 100), '')
			,@NewValue = ISNULL(CONVERT(NVARCHAR(10), @NewOtherTime, 100), '')
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditOtherTime'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = @OldRemark
			,@NewValue = @NewRemark
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditRemark'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = @OldVenue
			,@NewValue = @NewVenue
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditVenue'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = @OldRound
			,@NewValue = @NewRound
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditRound'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = @OldDivision
			,@NewValue = @NewDivision
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditDivision'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = @OldWebsite1
			,@NewValue = @NewWebsite1
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditWebsite1'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = @OldWebsite2
			,@NewValue = @NewWebsite2
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditWebsite2'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = @OldWebsite3
			,@NewValue = @NewWebsite3
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditWebsite3'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		SELECT @OldValue = @OldWebsite4
			,@NewValue = @NewWebsite4
		IF @OldValue <> @NewValue
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditWebsite4'

			SELECT @MessageContent = 
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(@MessageTemplate, '<User>', @ActorName)
								,'<Match.No>', @MatchNo)
							,'<League>', @LeagueName)
						,'<Event>', @EventName)
					,'<Old>', @OldValue)
				,'<New>', @NewValue)
				
			INSERT INTO #tblMessage (MessageTypeId ,MessageContent)
			VALUES(@MessageTypeId, @MessageContent)
		END
		
		IF EXISTS (
			SELECT 1
			FROM #tblMessage
			)
		BEGIN
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
						,0
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