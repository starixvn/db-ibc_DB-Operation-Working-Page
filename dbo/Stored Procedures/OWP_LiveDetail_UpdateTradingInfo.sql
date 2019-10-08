
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateTradingInfo] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@NoOfHDPId INT = NULL
	,@MatchOfferIds NVARCHAR(100) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20190821@Leo.Vo
Task : update new Match Detail Info  
DB: bodb_OWP

Revisions:
	20190821@Leo.Vo: initial - [Redmine: #117960]
	20190927@Leo.Vo: Write log - [Feature: #120415]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@OldData NVARCHAR(MAX)
		,@NewData NVARCHAR(MAX)
		,@Xml XML
		,@OldNoOfHDPId INT
		,@OldMatchOfferIds NVARCHAR(100)
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
	
	SELECT @OldMatchOfferIds = COALESCE(@OldMatchOfferIds + ', ', '') + CAST(MatchOfferId AS NVARCHAR)
	FROM dbo.MatchOfferDetail WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- save old value 
	SELECT @OldNoOfHDPId = m.NoOfHDPId
	FROM dbo.MatchInfo m WITH (NOLOCK)
		LEFT JOIN dbo.OWPMatch om WITH (NOLOCK) ON om.OWPMatchId = m.OWPMatchId
	WHERE m.OWPMatchId = @OWPMatchId					 

	SELECT @NoOfHDPId = CASE WHEN @NoOfHDPId = 0 THEN NULL ELSE @NoOfHDPId END

	-- update new value
	UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
	SET NoOfHDPId = @NoOfHDPId
	WHERE OWPMatchId = @OWPMatchId

	-- handle changes of Match Offer
	DELETE
	FROM dbo.MatchOfferDetail
	WHERE OWPMatchId = @OWPMatchId
	
	IF (ISNULL(@MatchOfferIds, '') != '')
	BEGIN
		INSERT INTO dbo.MatchOfferDetail (
		OWPMatchId
		,MatchOfferId
		)
		SELECT @OWPMatchId
			,val
		FROM dbo.strSplit(ISNULL(@MatchOfferIds, ''), ',')
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
			AND ns.NotificationSettingId IN (@NotifyWatcherMatchInfoUpdatedId, @NotifyWatcherProviderInfoUpdatedId)
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

		-- Edit No Of HDP
		IF ISNULL(@OldNoOfHDPId, 0) <> ISNULL(@NoOfHDPId, 0)
		BEGIN
			SELECT @OldValue = ISNULL((SELECT [Value] FROM dbo.RefResource WITH (NOLOCK) WHERE ResourceId =  @OldNoOfHDPId AND RefName='NoOfHDP'),'None')
					,@NewValue = ISNULL((SELECT [Value] FROM dbo.RefResource WITH (NOLOCK) WHERE ResourceId =  @NoOfHDPId AND RefName='NoOfHDP'),'None')
			print 'old' + @OldValue
			print 'new' + @NewValue
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageTypeId = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'EditNoOfHDP'

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

		-- Edit MatchOffer
		TRUNCATE TABLE #tblOldItem
		TRUNCATE TABLE #tblNewItem

		INSERT INTO #tblOldItem (
			Id
			,[Text]
			)
		SELECT rr.ResourceId
			,rr.Value
		FROM dbo.RefResource AS rr WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(@OldMatchOfferIds, ',') AS f
		WHERE rr.RefName = 'MatchOffer'
			AND rr.ResourceId = f.val

		INSERT INTO #tblNewItem (
			Id
			,[Text]
			)
		SELECT rr.ResourceId
			,rr.Value
		FROM dbo.RefResource AS rr WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(@MatchOfferIds, ',') AS f
		WHERE rr.RefName = 'MatchOffer'
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
			WHERE mt.MsgTemplateCode = 'EditMatchOffer'

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
	
	SET @Xml = (
			SELECT @OWPMatchId AS '@mt'
				,@OldNoOfHDPId AS '@hdp'
				,@OldMatchOfferIds AS '@mo'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @OldData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')		 

	SET @Xml = (
			SELECT @OWPMatchId AS '@mt'
				,@NoOfHDPId AS '@hdp'
				,@MatchOfferIds AS '@mo'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @NewData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_LiveDetail_UpdateTradingInfo'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@Data = @NewData
		,@DataOld = @OldData
		
	SELECT @ErrMsg = 'The event has been edited successfully!.'
		,@ErrCode = 0
		 
	DROP TABLE #tblOldItem

	DROP TABLE #tblNewItem

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END