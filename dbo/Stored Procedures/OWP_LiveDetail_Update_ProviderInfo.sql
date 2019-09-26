
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_ProviderInfo] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@Channel NVARCHAR(100) = ''
	,@WB NVARCHAR(100) = ''
	,@Phone NVARCHAR(200) = ''
	,@TVIds NVARCHAR(500) = ''
	,@OtherProviderIds NVARCHAR(100) = ''
	,@ProviderIds NVARCHAR(100) = ''
	,@AgentIds NVARCHAR(100) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20190820@Kane.Le
Task : update new Provider Info  
DB: bodb_OWP

Revisions:    
	20190820@Kane.Le: init SP - [Redmine: #117960]
	20190823@Carlos.Nguyen: Prevent send notification - [Redmine: #120415]	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@OldData NVARCHAR(MAX)
		,@NewData NVARCHAR(MAX)
		,@Xml XML
		,@OldChannel NVARCHAR(100)
		,@OldWB NVARCHAR(100)
		,@OldPhone NVARCHAR(200)
		,@OldRemark NVARCHAR(2000)
		,@OldNoOfHDPId INT
		,@OldIsSoloMatch BIT
		,@OldRound NVARCHAR(2000)
		,@OldDivision NVARCHAR(2000)
		,@OldVenue NVARCHAR(100)
		,@OldOtherTime TIME
		,@OldTVIds NVARCHAR(500)
		,@OldOtherProviderIds NVARCHAR(100)
		,@OldProviderIds NVARCHAR(100)
		,@OldAgentIds NVARCHAR(100)
		
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
		,@NotifyAssigneeProviderInfoUpdatedId INT = 11
		,@NotifyWatcherMatchInfoUpdatedId INT = 9
		,@NotifyWatcherProviderInfoUpdatedId INT = 13

	SET @StartRun = GETDATE()

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

	--BEGIN TRY

	-- save old value 
	SELECT @OldChannel = m.Channel
		,@OldWB = m.WB
		,@OldPhone = m.Phone
		,@OldRemark = m.Remark
		,@OldNoOfHDPId = m.NoOfHDPId
		,@OldIsSoloMatch = m.IsSoloMatch
		,@OldRound = m.[Round]
		,@OldDivision = m.Division
		,@OldVenue = m.Venue
		,@OldOtherTime = om.OtherTime
	--,@OldTVIds = m.TVCode
	--,@OldOtherProviderIds = m.OtherProvider
	--,@OldProviderIds = m.[Provider]
	--,@OldAgentIds = m.Agent
	FROM dbo.MatchInfo m WITH (NOLOCK)
	LEFT JOIN dbo.OWPMatch om WITH (NOLOCK) ON om.OWPMatchId = m.OWPMatchId
	WHERE m.OWPMatchId = @OWPMatchId

	SELECT @OldTVIds = ISNULL(STUFF((
					SELECT ', ' + CAST(TVId AS NVARCHAR)
					FROM dbo.MatchTelevision WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	SELECT @OldOtherProviderIds = ISNULL(STUFF((
					SELECT ', ' + CAST(OtherProviderId AS NVARCHAR)
					FROM dbo.MatchOtherProvider WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	SELECT @OldProviderIds = ISNULL(STUFF((
					SELECT ', ' + CAST(ProviderId AS NVARCHAR)
					FROM dbo.MatchProvider WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	SELECT @OldAgentIds = ISNULL(STUFF((
					SELECT ', ' + CAST(AgentId AS NVARCHAR)
					FROM dbo.MatchAgent WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	-- update new value
	UPDATE dbo.MatchInfo
	WITH (
			ROWLOCK
			,UPDLOCK
			)

	SET Channel = @Channel
		,WB = @WB
		,Phone = @Phone
	--,OtherProvider = @OtherProviderIds
	--,[Provider] = @ProviderIds
	--,TVCode = @TVIds
	--,Agent = @AgentIds
	WHERE OWPMatchId = @OWPMatchId

	-- handle changes TVIds
	
DELETE
	FROM dbo.MatchTelevision WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId
	IF (ISNULL(@TVIds, '') != '')
	
	BEGIN
		INSERT INTO dbo.MatchTelevision (
			OWPMatchId
			,TVId
			)
		SELECT @OWPMatchId
			,val
		FROM dbo.strSplit(ISNULL(@TVIds, ''), ',')
	END

	-- handle changes OtherProvider
	
DELETE
	FROM dbo.MatchOtherProvider WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId
	IF (ISNULL(@OtherProviderIds, '') != '')
	
	BEGIN
		INSERT INTO dbo.MatchOtherProvider (
			OWPMatchId
			,OtherProviderId
			)
		SELECT @OWPMatchId
			,val
		FROM dbo.strSplit(ISNULL(@OtherProviderIds, ''), ',')
	END

	-- handle changes Provider
	
DELETE
	FROM dbo.MatchProvider WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId
	IF (ISNULL(@ProviderIds, '') != '')
	
	BEGIN
		INSERT INTO dbo.MatchProvider (
			OWPMatchId
			,ProviderId
			)
		SELECT @OWPMatchId
			,val
		FROM dbo.strSplit(ISNULL(@ProviderIds, ''), ',')
	END

	-- handle changes MatchAgent
	
DELETE
	FROM dbo.MatchAgent WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId
	IF (ISNULL(@AgentIds, '') != '')
	
	BEGIN
		INSERT INTO dbo.MatchAgent (
			OWPMatchId
			,AgentId
			)
		SELECT @OWPMatchId
			,val
		FROM dbo.strSplit(ISNULL(@AgentIds, ''), ',')
	END

	DECLARE
		@MinorBettype_FastMarket INT = - 88
		,@MinorBettype_AllInOne INT = - 89
		,@MinorBettype_Specific15Mins INT = - 1
		,@MinorBettype_Specific10Mins INT = - 2
		,@MinorBettype_Specific15MinsNoOfCorners INT = - 5
		,@MinorBettype_Specific15MinsTotalBooking INT = - 8
		,@MinorBettypeId INT = NULL
	
	SET @MinorBettypeId = (SELECT TOP 1 MinorBettypeId FROM MinorMatch WHERE MinorMatchId = @OWPMatchId)
	
	-- send message edit if in time range
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
		AND (
			@MinorBettypeId IS NULL
			OR @MinorBettypeId NOT IN (
				@MinorBettype_FastMarket
				,@MinorBettype_AllInOne
				,@MinorBettype_Specific15Mins
				,@MinorBettype_Specific10Mins
				,@MinorBettype_Specific15MinsNoOfCorners
				,@MinorBettype_Specific15MinsTotalBooking
				)
			)
	BEGIN
		SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)

		SELECT @HomeTeamName = home.OWPTeamName
			,@AwayTeamName = away.OWPTeamName
			,@EventDateTime = om.EventDateTime
			,@MatchNo = CASE 
				WHEN om.MatchNo = ''
					THEN ''
				ELSE '#' + om.MatchNo
				END
			,@League = ol.OWPLeagueName
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
		LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
		LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
		LEFT JOIN dbo.OWPLeague AS ol WITH (NOLOCK) ON om.OWPLeagueId = ol.OWPLeagueId
		WHERE om.OWPMatchId = @OWPMatchId

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

		-- get list users received ASSIGNEE message update Provider Info
		INSERT INTO @UserReceivedAssigneeMessageProviderInfo (Id)
		SELECT a.UserId
		FROM #tblAllAssigneeOfMatch AS a
		LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyAssigneeProviderInfoUpdatedId
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
				AND ns.NotificationSettingId IN (
					@NotifyWatcherMatchInfoUpdatedId
					,@NotifyWatcherProviderInfoUpdatedId
					)
			) AS r
		LEFT JOIN dbo.[User] AS mem WITH (NOLOCK) ON r.SectionId = mem.SectionId
			AND mem.SectionId IS NOT NULL

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

		-- get list users received WATCHER message change Provider Info
		INSERT INTO @UserReceivedWatcherMessageProviderInfo (Id)
		SELECT DISTINCT sm.UserReceivedWatcherId
		FROM #tblAllAssigneeOfMatch AS a
		INNER JOIN #tblSectionMemberOfUserReceivedWatcher AS sm ON sm.MemberId = a.UserId
		WHERE sm.NotificationSettingId = @NotifyWatcherProviderInfoUpdatedId
			AND NOT EXISTS (
				-- ignore user received Assignee message
				SELECT 1
				FROM @UserReceivedAssigneeMessageProviderInfo AS ur
				WHERE ur.Id = sm.UserReceivedWatcherId
				)

		-- Edit TV--
		INSERT INTO #tblOldItem (
			Id
			,[Text]
			)
		SELECT tv.TVId
			,tv.TVCode
		FROM dbo.Television AS tv WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(@OldTVIds, ',') AS f
		WHERE tv.TVId = f.val

		INSERT INTO #tblNewItem (
			Id
			,[Text]
			)
		SELECT tv.TVId
			,tv.TVCode
		FROM dbo.Television AS tv WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(@TVIds, ',') AS f
		WHERE tv.TVId = f.val

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
			WHERE mt.MsgTemplateCode = 'EditTV'

			SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', @ActorName), '<Match.No>', @MatchNo), '<League>', @League), '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName), '<Old>', @OldValue), '<New>', @NewValue)

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedAssigneeMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedWatcherMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
		END

		-- Edit Other Provider
		TRUNCATE TABLE #tblOldItem

		TRUNCATE TABLE #tblNewItem

		INSERT INTO #tblOldItem (
			Id
			,[Text]
			)
		SELECT op.OtherProviderId
			,op.OtherProviderName
		FROM dbo.OtherProvider AS op WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(@OldOtherProviderIds, ',') AS f
		WHERE op.OtherProviderId = f.val

		INSERT INTO #tblNewItem (
			Id
			,[Text]
			)
		SELECT op.OtherProviderId
			,op.OtherProviderName
		FROM dbo.OtherProvider AS op WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(@OtherProviderIds, ',') AS f
		WHERE op.OtherProviderId = f.val

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
			WHERE mt.MsgTemplateCode = 'EditOtherProvider'

			SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', @ActorName), '<Match.No>', @MatchNo), '<League>', @League), '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName), '<Old>', @OldValue), '<New>', @NewValue)

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedAssigneeMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedWatcherMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
		END

		-- Edit Provider
		TRUNCATE TABLE #tblOldItem

		TRUNCATE TABLE #tblNewItem

		INSERT INTO #tblOldItem (
			Id
			,[Text]
			)
		SELECT p.ProviderId
			,p.ProviderName
		FROM dbo.[Provider] AS p WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(@OldProviderIds, ',') AS f
		WHERE p.ProviderId = f.val

		INSERT INTO #tblNewItem (
			Id
			,[Text]
			)
		SELECT p.ProviderId
			,p.ProviderName
		FROM dbo.[Provider] AS p WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(@ProviderIds, ',') AS f
		WHERE p.ProviderId = f.val

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
			WHERE mt.MsgTemplateCode = 'EditProvider'

			SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', @ActorName), '<Match.No>', @MatchNo), '<League>', @League), '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName), '<Old>', @OldValue), '<New>', @NewValue)

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedAssigneeMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedWatcherMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
		END

		-- Edit Agent
		TRUNCATE TABLE #tblOldItem

		TRUNCATE TABLE #tblNewItem

		INSERT INTO #tblOldItem (
			Id
			,[Text]
			)
		SELECT a.AgentId
			,a.AgentName
		FROM dbo.Agent AS a WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(@OldAgentIds, ',') AS f
		WHERE a.AgentId = f.val

		INSERT INTO #tblNewItem (
			Id
			,[Text]
			)
		SELECT a.AgentId
			,a.AgentName
		FROM dbo.Agent AS a WITH (NOLOCK)
		CROSS APPLY dbo.fnc_SplitStrings(@AgentIds, ',') AS f
		WHERE a.AgentId = f.val

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
			WHERE mt.MsgTemplateCode = 'EditAgent'

			SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', @ActorName), '<Match.No>', @MatchNo), '<League>', @League), '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName), '<Old>', @OldValue), '<New>', @NewValue)

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedAssigneeMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedWatcherMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
		END

		-- Edit Phone
		IF @OldPhone <> @Phone
			AND DATEDIFF(MINUTE, @CurrentDateTimeGMTplus8, @EventDateTime) <= 60
		BEGIN
			SELECT @OldValue = @OldPhone
				,@NewValue = @Phone

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditPhone'

			SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', @ActorName), '<Match.No>', @MatchNo), '<League>', @League), '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName), '<Old>', @OldValue), '<New>', @NewValue)

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedAssigneeMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedWatcherMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
		END

		-- Edit Channel
		IF @OldChannel <> @Channel
		BEGIN
			SELECT @OldValue = @OldChannel
				,@NewValue = @Channel

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditChannel'

			SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', @ActorName), '<Match.No>', @MatchNo), '<League>', @League), '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName), '<Old>', @OldValue), '<New>', @NewValue)

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedAssigneeMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedWatcherMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
		END

		-- Edit WB
		IF @OldWB <> @WB
		BEGIN
			SELECT @OldValue = @OldWB
				,@NewValue = @WB

			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditWB'

			SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<User>', @ActorName), '<Match.No>', @MatchNo), '<League>', @League), '<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName), '<Old>', @OldValue), '<New>', @NewValue)

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedAssigneeMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId

			EXEC dbo.OWP_MessageInsert @UserId = @ActorId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageTypeId
				,@MessageTo = @UserReceivedWatcherMessageProviderInfo
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
		END
	END

		BEGIN
		SET @Xml = (
				SELECT @OWPMatchId AS '@mt'
					,@OldTVIds AS '@tv'
					,@OldChannel AS '@ch'
					,@OldWB AS '@wb'
					,@OldProviderIds AS '@pv'					
					,@OldOtherProviderIds AS '@opv'
					,@OldPhone AS '@ph'
					,@OldAgentIds AS '@ag'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @OldData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')		 

		SET @Xml = (
				SELECT @OWPMatchId AS '@mt'
					,@TVIds AS '@tv'
					,@Channel AS '@ch'
					,@WB AS '@wb'
					,@ProviderIds AS '@pv'
					,@OtherProviderIds AS '@opv'					
					,@Phone AS '@ph'
					,@AgentIds AS '@ag'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @NewData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
			,@SPName = 'OWP_LiveDetail_Update_ProviderInfo'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @NewData
			,@DataOld = @OldData
	END

	SELECT @ErrMsg = 'The event has been edited successfully!.'
		,@ErrCode = 0

	DROP TABLE #tblOldItem

	DROP TABLE #tblNewItem

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END