/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_LiveDetail_Update_ProviderInfo_Single] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@ParentMatchId INT
	,@MinorBettypeId INT
	,@IsMatchInTimeRange BIT
	,@Channel NVARCHAR(100) = ''
	,@IsUpdateChannel BIT = 0
	,@IpTv NVARCHAR(100) = ''
	,@IsUpdateIpTv BIT = 0
	,@WB NVARCHAR(100) = ''
	,@IsUpdateWB BIT = 0
	,@Phone NVARCHAR(200) = ''
	,@IsUpdatePhone BIT = 0
	,@TVIds TVP_INT READONLY
	,@IsUpdateTVs BIT = 0
	,@OtherProvider VARCHAR(900) = ''
	,@IsUpdateOtherProviders BIT = 0
	,@Provider VARCHAR(900) = ''
	,@IsUpdateProviders BIT = 0
	,@AgentIds TVP_INT READONLY
	,@IsUpdateAgents BIT = 0
AS
/*
Created: 20190820@Leo.Vo
Task : Update provider info called from SP
DB: bodb_OWP

Revisions:
	20190820@Leo.Vo: Initial SP - [Redmine: #120496]
	20191017@Kane.Le: Change Provider, OtherProvider - [Feature: #122194]
	20191117@Carlos: Fix phone notification - [Feature: #123167]
	20200723@Esther.Nguyen: Build Home name (N) - [Feature: #137417]
	20200728@carlos.Nguyen: Update data Streaming sync from InfoSite - [Redmine: #137755]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @NotifyAssigneeProviderInfoUpdatedId INT = 11
		,@NotifyWatcherProviderInfoUpdatedId INT = 13
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
		,@OtherProviderId INT
		,@ProviderId INT
	-- build relevant matches
	DECLARE @tblRelevantMatches TABLE (
		OWPMatchId INT PRIMARY KEY CLUSTERED
		,MinorBettypeId INT
		)

	INSERT INTO @tblRelevantMatches (
		OWPMatchId
		,MinorBettypeId
		)
	VALUES (
		@OWPMatchId
		,@MinorBettypeId
		)

	IF @ParentMatchId IS NULL
	BEGIN
		INSERT INTO @tblRelevantMatches (
			OWPMatchId
			,MinorBettypeId
			)
		SELECT MinorMatchId
			,MinorBettypeId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId
			AND MinorBettypeId IN (
				@FastMarket
				,@AllInOne
				,@Specific10Mins
				,@Specific15Mins
				)
	END
	ELSE
	BEGIN
		IF @MinorBettypeId = @NoOfCorners
		BEGIN
			INSERT INTO @tblRelevantMatches (
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
			INSERT INTO @tblRelevantMatches (
				OWPMatchId
				,MinorBettypeId
				)
			SELECT MinorMatchId
				,MinorBettypeId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId
				AND MinorBettypeId = @Specific15MinsTotalBooking
		END
	END

	DECLARE @OldChannel NVARCHAR(100) = ''
		,@OldIpTv NVARCHAR(100) = ''
		,@OldWB NVARCHAR(100) = ''
		,@OldPhone NVARCHAR(200) = ''
		,@OldTV NVARCHAR(2000) = ''
		,@OldProvider NVARCHAR(2000) = ''
		,@OldOtherProvider NVARCHAR(2000) = ''
		,@OldAgent NVARCHAR(2000) = ''
		,@NewChannel NVARCHAR(100) = ''
		,@NewIpTv NVARCHAR(100) = ''
		,@NewWB NVARCHAR(100) = ''
		,@NewPhone NVARCHAR(200) = ''
		,@NewTV NVARCHAR(2000) = ''
		,@NewProvider NVARCHAR(2000) = ''
		,@NewOtherProvider NVARCHAR(2000) = ''
		,@NewAgent NVARCHAR(2000) = ''

	SELECT @OldChannel = mi.Channel
		,@OldIpTv=mi.IPTV
		,@OldWB = mi.WB
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
	WHERE m.OWPMatchId = @OWPMatchId

	SELECT @NewChannel = CASE 
			WHEN @IsUpdateChannel = 1
				THEN @Channel
			ELSE @OldChannel
			END
		,@NewWB = CASE 
			WHEN @IsUpdateWB = 1
				THEN @WB
			ELSE @OldWB
			END
		,@NewPhone = CASE 
			WHEN @IsUpdatePhone = 1
				THEN @Phone
			ELSE @OldPhone
			END
		,@NewIpTv = CASE
			WHEN @IsUpdateIpTv = 1
				THEN @IpTv
			ELSE @OldIpTv
			END
			
	SELECT @OldPhone=mi.Phone
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	WHERE mi.OWPMatchId=@OWPMatchId
	
	UPDATE mi
	SET mi.Channel = @NewChannel
		,mi.IPTV=@NewIpTv
		,mi.WB = @NewWB
		,mi.Phone = @NewPhone
	FROM dbo.MatchInfo AS mi WITH (ROWLOCK)
	INNER JOIN @tblRelevantMatches AS rm ON mi.OWPMatchId = rm.OWPMatchId

	IF @IsUpdateTVs = 1
	BEGIN
		SELECT @OldTV = ISNULL(STUFF((
						SELECT ', ' + tv.TVCode
						FROM dbo.MatchTelevision AS mtv WITH (NOLOCK)
						INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON mtv.TVId = tv.TVId
						WHERE mtv.OWPMatchId = @OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')

		SELECT @NewTV = ISNULL(STUFF((
						SELECT ', ' + tv.TVCode
						FROM @TVIds AS t
						INNER JOIN dbo.Television AS tv WITH (NOLOCK) ON t.Id = tv.TVId
						FOR XML PATH('')
						), 1, 2, ''), '')

		IF @OldTV <> @NewTV
		BEGIN
			DELETE dbo.MatchTelevision
			WITH (ROWLOCK)
			WHERE OWPMatchId = @OWPMatchId

			INSERT INTO dbo.MatchTelevision (
				OWPMatchId
				,TVId
				)
			SELECT @OWPMatchId
				,Id
			FROM @TVIds
		END
	END

	IF @IsUpdateProviders = 1
	BEGIN
		SELECT @OldProvider = ISNULL(STUFF((
						SELECT ', ' + p.ProviderName
						FROM dbo.MatchProvider AS mp WITH (NOLOCK)
						INNER JOIN dbo.Provider AS p WITH (NOLOCK) ON mp.ProviderId = p.ProviderId
						WHERE mp.OWPMatchId = @OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')

		DELETE dbo.MatchProvider
		WITH (ROWLOCK)
		WHERE OWPMatchId = @OWPMatchId

		IF (ISNULL(@Provider, '') != '')
		BEGIN
			SELECT @ProviderId = ProviderId
			FROM dbo.[Provider] WITH (NOLOCK)
			WHERE ProviderName = @Provider

			IF @ProviderId IS NULL
			BEGIN
				INSERT INTO dbo.[Provider] (ProviderName)
				VALUES (@Provider)

				SET @ProviderId = SCOPE_IDENTITY()
			END

			INSERT INTO dbo.MatchProvider (
				OWPMatchId
				,ProviderId
				)
			VALUES (
				@OWPMatchId
				,@ProviderId
				)
		END
	END

	IF @IsUpdateOtherProviders = 1
	BEGIN
		SELECT @OldOtherProvider = ISNULL(STUFF((
						SELECT ', ' + op.OtherProviderName
						FROM dbo.MatchOtherProvider AS mop WITH (NOLOCK)
						INNER JOIN dbo.OtherProvider AS op ON mop.OtherProviderId = op.OtherProviderId
						WHERE mop.OWPMatchId = @OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')

		DELETE dbo.MatchOtherProvider
		WITH (ROWLOCK)
		WHERE OWPMatchId = @OWPMatchId

		IF (ISNULL(@OtherProvider, '') != '')
		BEGIN
			SELECT @OtherProviderId = OtherProviderId
			FROM dbo.OtherProvider WITH (NOLOCK)
			WHERE OtherProviderName = @OtherProvider

			IF @OtherProviderId IS NULL
			BEGIN
				INSERT INTO dbo.OtherProvider (OtherProviderName)
				VALUES (@OtherProvider)

				SET @OtherProviderId = SCOPE_IDENTITY()
			END

			INSERT INTO dbo.MatchOtherProvider
			WITH (ROWLOCK) (
					OWPMatchId
					,OtherProviderId
					)
			VALUES (
				@OWPMatchId
				,@OtherProviderId
				)
		END
	END

	IF @IsUpdateAgents = 1
	BEGIN
		SELECT @OldAgent = ISNULL(STUFF((
						SELECT ', ' + a.AgentName
						FROM dbo.MatchAgent AS ma WITH (NOLOCK)
						INNER JOIN dbo.Agent AS a ON ma.AgentId = a.AgentId
						WHERE ma.OWPMatchId = @OWPMatchId
						FOR XML PATH('')
						), 1, 2, ''), '')

		SELECT @NewAgent = ISNULL(STUFF((
						SELECT ', ' + a.AgentName
						FROM @AgentIds AS t
						INNER JOIN dbo.Agent AS a ON t.Id = a.AgentId
						FOR XML PATH('')
						), 1, 2, ''), '')

		IF @OldAgent <> @NewAgent
		BEGIN
			DELETE dbo.MatchAgent
			WITH (ROWLOCK)
			WHERE OWPMatchId = @OWPMatchId

			INSERT INTO dbo.MatchAgent (
				OWPMatchId
				,AgentId
				)
			SELECT @OWPMatchId
				,Id
			FROM @AgentIds
		END
	END

	CREATE TABLE #tblAssignee (UserId INT)

	CREATE TABLE #tblAssigneeRecevingNotification (UserId INT)

	CREATE TABLE #tblWatcher (UserId INT)

	IF @IsMatchInTimeRange = 1
	BEGIN
		DECLARE @EventName NVARCHAR(MAX)
			,@MatchNo VARCHAR(50)
			,@LeagueName NVARCHAR(500)
			,@ActorName VARCHAR(30)

		SELECT @EventName = (CASE WHEN om.IsNeutral = 1 THEN home.OWPTeamName + ' (N)' ELSE home.OWPTeamName END) + ' -vs- ' + away.OWPTeamName
			,@MatchNo = CASE 
				WHEN om.MatchNo = ''
					THEN ''
				ELSE '#' + om.MatchNo
				END
			,@LeagueName = l.OWPLeagueName
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON om.OWPLeagueId = l.OWPLeagueId
		WHERE om.OWPMatchId = @OWPMatchId

		SELECT @ActorName = dbo.fnc_GetUsernameByUserId(@ActorId)

		DECLARE @tblMessageChangeLog TABLE (
			OldValue NVARCHAR(2000)
			,NewValue NVARCHAR(2000)
			,TemplateCode NVARCHAR(50)
			)
		DECLARE @tblMessage TABLE (
			MessageContent NVARCHAR(MAX)
			,MessageTypeId INT
			)

		-- send message notification for provider info
		INSERT INTO @tblMessageChangeLog (
			OldValue
			,NewValue
			,TemplateCode
			)
		VALUES (
			@OldProvider
			,@Provider
			,'EditProvider'
			)
			,(
			@OldOtherProvider
			,@OtherProvider
			,'EditOtherProvider'
			)
			,(
			@OldAgent
			,@NewAgent
			,'EditAgent'
			)
			,(
			@OldChannel
			,@NewChannel
			,'EditChannel'
			)
			,(
			@OldIpTv
			,@NewIpTv
			,'EditIPTV'
			)
			,(
			@OldWB
			,@NewWB
			,'EditWB'
			)
			,(
			@OldPhone
			,@NewPhone
			,'EditPhone'
			)

		INSERT INTO @tblMessage (
			MessageTypeId
			,MessageContent
			)
		SELECT mt.MsgTemplateId
			,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(mt.MsgTemplateContent, '<User>', @ActorName), '<Match.No>', @MatchNo), '<League>', @LeagueName), '<Event>', @EventName), '<Old>', l.OldValue), '<New>', l.NewValue)
		FROM @tblMessageChangeLog AS l
		INNER JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON l.TemplateCode = mt.MsgTemplateCode
		WHERE l.OldValue <> l.NewValue

		IF EXISTS (
				SELECT 1
				FROM @tblMessage
				)
		BEGIN
			INSERT INTO #tblAssignee (UserId)
			SELECT DISTINCT a.UserId
			FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN (
				SELECT MinorMatchId AS OWPMatchId
				FROM dbo.MinorMatch WITH (NOLOCK)
				WHERE ParentMatchId = ISNULL(@ParentMatchId, @OWPMatchId)
				
				UNION
				
				SELECT @OWPMatchId AS OWPMatchId
				) AS m ON a.OWPMatchId = m.OWPMatchId
			WHERE a.UserId IS NOT NULL

			INSERT INTO #tblAssigneeRecevingNotification (UserId)
			SELECT a.UserId
			FROM #tblAssignee AS a
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyAssigneeProviderInfoUpdatedId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = a.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

			MERGE dbo.[Message] AS ms
			USING (
				SELECT a.UserId
					,m.MessageContent
					,m.MessageTypeId
				FROM @tblMessage AS m
				CROSS JOIN #tblAssigneeRecevingNotification AS a
				) AS msn
				ON 1 = 0
			WHEN NOT MATCHED
				THEN
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
					)
				AND NOT EXISTS (
					SELECT 1
					FROM #tblAssigneeRecevingNotification AS a
					WHERE u.UserId = a.UserId
					)

		END

		-- send message notification for match info
		DELETE
		FROM @tblMessageChangeLog

		INSERT INTO @tblMessageChangeLog (
			OldValue
			,NewValue
			,TemplateCode
			)
		VALUES (
			@OldTV
			,@NewTV
			,'EditTV'
			)

		DELETE
		FROM @tblMessage

		INSERT INTO @tblMessage (
			MessageTypeId
			,MessageContent
			)
		SELECT mt.MsgTemplateId
			,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(mt.MsgTemplateContent, '<User>', @ActorName), '<Match.No>', @MatchNo), '<League>', @LeagueName), '<Event>', @EventName), '<Old>', l.OldValue), '<New>', l.NewValue)
		FROM @tblMessageChangeLog AS l
		INNER JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON l.TemplateCode = mt.MsgTemplateCode
		WHERE l.OldValue <> l.NewValue

		IF EXISTS (
				SELECT 1
				FROM @tblMessage
				)
		BEGIN
			TRUNCATE TABLE #tblAssignee

			INSERT INTO #tblAssignee (UserId)
			SELECT DISTINCT a.UserId
			FROM dbo.Assignment AS a WITH (NOLOCK)
			INNER JOIN (
				SELECT MinorMatchId AS OWPMatchId
				FROM dbo.MinorMatch WITH (NOLOCK)
				WHERE ParentMatchId = ISNULL(@ParentMatchId, @OWPMatchId)
				
				UNION
				
				SELECT @OWPMatchId AS OWPMatchId
				) AS m ON a.OWPMatchId = m.OWPMatchId
			WHERE a.UserId IS NOT NULL

			TRUNCATE TABLE #tblAssigneeRecevingNotification

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
				FROM @tblMessage AS m
				CROSS JOIN #tblAssigneeRecevingNotification AS a
				) AS msn
				ON 1 = 0
			WHEN NOT MATCHED
				THEN
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

			TRUNCATE TABLE #tblWatcher

			INSERT INTO #tblWatcher (UserId)
			SELECT DISTINCT u.UserId
			FROM dbo.[User] AS u WITH (NOLOCK)
			WHERE EXISTS (
					SELECT 1
					FROM #tblAssignee AS a
					INNER JOIN dbo.[User] AS u2 ON a.UserId = u2.UserId
					WHERE u2.SectionId = u.SectionId
					)
				AND NOT EXISTS (
					SELECT 1
					FROM #tblAssigneeRecevingNotification AS a
					WHERE u.UserId = a.UserId
					)
		END
	END

	DROP TABLE #tblAssignee

	DROP TABLE #tblAssigneeRecevingNotification

	DROP TABLE #tblWatcher
END