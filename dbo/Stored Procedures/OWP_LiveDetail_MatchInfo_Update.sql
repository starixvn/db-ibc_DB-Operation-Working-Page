
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchInfo_Update] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@Channel NVARCHAR(100) = ''
	,@WB NVARCHAR(100) = ''
	,@Phone NVARCHAR(50) = ''
	,@Remark NVARCHAR(2000) = ''
	,@NoOfHDP NVARCHAR(20) = ''
	,@IsSoloMatch BIT = 0
	,@KOTimeRemark NVARCHAR(50) = ''
	,@Round NVARCHAR(2000) = ''
	,@Division NVARCHAR(2000) = ''
	,@Venue NVARCHAR(100) = ''
	,@OtherTime DATETIME = NULL
	,@TVIds NVARCHAR(500) = ''
	,@OtherProviderIds NVARCHAR(100) = ''
	,@ProviderIds NVARCHAR(100) = ''
	,@AgentIds NVARCHAR(100) = ''
	,@MarketIds NVARCHAR(100) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161208@Razor.Nguyen
Task : update new Match Detail Info  
DB: bodb_OWP

Revisions:
    20170824@Tim.Trinh: send message when update Cancel status
	20180814@Raymond.Le: new design Live Detail
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181016@Raymond.Le: Notify assignee follow Notification Setting - [Redmine: #102867] 
	20181123@Kane.Le: DB - Separate Assignee Notification Setting (Provider Info LiveDetail) [Redmine: #105043]
	Change @Assignee to @AssigneeMatchInfoMatchInfo
	Add @AssigneeProviderInfo
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
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
		,@OldPhone NVARCHAR(50)
		,@OldRemark NVARCHAR(2000)
		,@OldNoOfHDP NVARCHAR(20)
		,@OldIsSoloMatch BIT
		,@OldKOTimeRemark NVARCHAR(50)
		,@OldRound NVARCHAR(2000)
		,@OldDivision NVARCHAR(2000)
		,@OldVenue NVARCHAR(100)
		,@OldOtherTime TIME
		,@OldTVIds NVARCHAR(500)
		,@OldOtherProviderIds NVARCHAR(100)
		,@OldProviderIds NVARCHAR(100)
		,@OldAgentIds NVARCHAR(100)
		,@OldMarketIds NVARCHAR(100)
		-- send message by condition date
		,@AssigneeMatchInfo TVP_INT
		,@AssigneeProviderInfo TVP_INT
		,@MessageTemplate NVARCHAR(2000) = ''
		,@MessageType INT
		,@ActorName NVARCHAR(30)
		,@OldValue NVARCHAR(500)
		,@NewValue NVARCHAR(500)
		,@HomeTeamName NVARCHAR(200)
		,@AwayTeamName NVARCHAR(200)
		,@EventDateTime DATETIME
		,@NewOtherTime TIME
		,@CurrentDateTimeGMTplus8 DATETIME = DATEADD(HOUR, 12, GETDATE())

		-- Notification Setting
		,@NotifyMatchInfoUpdatedId INT = 5
		,@NotifyProviderInfoUpdatedId INT = 11

	CREATE TABLE #tblOldItem (
		Id INT
		,[Text] NVARCHAR(100)
		)

	CREATE TABLE #tblNewItem (
		Id INT
		,[Text] NVARCHAR(100)
		)

	BEGIN TRY
		SELECT @OldMarketIds = COALESCE(@OldMarketIds + ', ', '') + CAST(MarketId AS NVARCHAR)
		FROM dbo.MatchMarket WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId

		-- save old value 
		SELECT @OldChannel = m.Channel
			,@OldWB = m.WB
			,@OldPhone = m.Phone
			,@OldRemark = m.Remark
			,@OldNoOfHDP = m.NoOfHDP
			,@OldIsSoloMatch = m.IsSoloMatch
			,@OldKOTimeRemark = m.KOTimeRemark
			,@OldRound = m.[Round]
			,@OldDivision = m.Division
			,@OldVenue = m.Venue
			,@OldOtherTime = om.OtherTime
			,@OldTVIds = m.TVCode
			,@OldOtherProviderIds = m.OtherProvider
			,@OldProviderIds = m.[Provider]
			,@OldAgentIds = m.Agent
		FROM dbo.MatchInfo m WITH (NOLOCK)
			LEFT JOIN dbo.OWPMatch om WITH (NOLOCK) ON om.OWPMatchId = m.OWPMatchId
		WHERE m.OWPMatchId = @OWPMatchId

		-- update new value
		UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
		SET Channel = @Channel
			,WB = @WB
			,Phone = @Phone
			,Remark = @Remark
			,NoOfHDP = @NoOfHDP
			,IsSoloMatch = @IsSoloMatch
			,KOTimeRemark = @KOTimeRemark
			,[Round] = @Round
			,Division = @Division
			,Venue = @Venue
			,OtherProvider = @OtherProviderIds
			,[Provider] = @ProviderIds
			,TVCode = @TVIds
			,Agent = @AgentIds
		WHERE OWPMatchId = @OWPMatchId

		UPDATE dbo.OWPMatch WITH (ROWLOCK, UPDLOCK)
		SET OtherTime = @OtherTime
		WHERE OWPMatchId = @OWPMatchId

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
			FROM dbo.OWPMatch AS om WITH (NOLOCK)
				LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
				LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
			WHERE om.OWPMatchId = @OWPMatchId

			SELECT @NewOtherTime = CAST(@OtherTime AS TIME)

			-- Assignee Match Info --
			INSERT INTO @AssigneeMatchInfo
			SELECT UserId
			FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, @NotifyMatchInfoUpdatedId)

			-- Assignee Provider Info --
			INSERT INTO @AssigneeProviderInfo
			SELECT UserId
			FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, @NotifyProviderInfoUpdatedId)
			
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
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditTV'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeProviderInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
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
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditOtherProvider'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeProviderInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
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
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditProvider' 

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeProviderInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
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
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditAgent'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeProviderInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

			-- Edit Phone
			IF @OldPhone <> @Phone
			  AND DATEDIFF(MINUTE, @CurrentDateTimeGMTplus8, @EventDateTime) <= 60
			BEGIN
				SELECT @OldValue = @OldPhone
					,@NewValue = @Phone

				SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditPhone'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeProviderInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

			-- Edit Channel
			IF @OldChannel <> @Channel
			BEGIN
				SELECT @OldValue = @OldChannel
					,@NewValue = @Channel

				SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditChannel'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeProviderInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

			-- Edit WB
			IF @OldWB <> @WB
			BEGIN
				SELECT @OldValue = @OldWB
					,@NewValue = @WB

				SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditWB'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeProviderInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

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
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditOtherTime'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeMatchInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

			-- Edit Match Offer
			IF @OldKOTimeRemark <> @KOTimeRemark
			BEGIN
				SELECT @OldValue = @OldKOTimeRemark
					,@NewValue = @KOTimeRemark

				SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditMatchOffer'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeMatchInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

			-- Edit Round
			IF @OldRound <> @Round
			BEGIN
				SELECT @OldValue = @OldRound
					,@NewValue = @Round

				SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditRound'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeMatchInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

			-- Edit Division
			IF @OldDivision <> @Division
			BEGIN
				SELECT @OldValue = @OldDivision
					,@NewValue = @Division

				SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditDivision'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeMatchInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

			-- Edit Remark
			IF @OldRemark <> @Remark
			BEGIN
				SELECT @OldValue = @OldRemark
					,@NewValue = @Remark

				SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditRemark'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeMatchInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

			-- Edit No Of HDP
			IF @OldNoOfHDP <> @NoOfHDP
			BEGIN
				SELECT @OldValue = @OldNoOfHDP
					,@NewValue = @NoOfHDP

				SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditNoOfHDP'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeMatchInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

			-- Edit Venue
			IF @OldVenue <> @Venue
			BEGIN
				SELECT @OldValue = @OldVenue
					,@NewValue = @Venue

				SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditVenue'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeMatchInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
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
					,@MessageType = mt.MsgTemplateId
				FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
				WHERE mt.MsgTemplateCode = 'EditMarket'

				SELECT @MessageTemplate = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@MessageTemplate, '<user>', @ActorName), '<home>', @HomeTeamName), '<away>', @AwayTeamName), '<bettype>', ''), '<oldvalue>', @OldValue), '<newvalue>', @NewValue)

				EXEC dbo.OWP_MessageInsert @UserId = @ActorId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @AssigneeMatchInfo
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
			END

		END
		 
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update Match Info failed. Please try again.'
			,@ErrCode = 5001 -- ActionId + 01

		RETURN
	END CATCH

	DROP TABLE #tblOldItem

	DROP TABLE #tblNewItem
END