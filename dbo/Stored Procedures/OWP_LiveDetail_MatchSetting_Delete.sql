
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchSetting_Delete]
	@SessionId VARCHAR(50),
	@UserId INT,
	@MinorBettypeId INT,
	@MatchId INT,
	@BettypeId INT,
	@Bettype VARCHAR(50)
AS

DECLARE @MatchIdUseLog INT,
 @ParentmatchIdUseLog INT = NULL,
 @Maxbet MONEY = NULL,
 @Spread SMALLMONEY = NULL,
 @MaxbetCN88 MONEY = NULL,
 @SpreadCN88 SMALLMONEY = NULL
/*
Created: 2019-13-08@Carlos
Task : Delete match setting
DB: bodb_OWP

Revisions:
	20190819@Carlos: Initial SP - [Feature: #118856]
	20190927@Leo.Vo: Write log - [Feature: #120415]
*/

BEGIN
	CREATE TABLE #tblMinorMatch(MinorMatchId INT)
	IF(@BettypeId IN (1,3,5,7,8,15))
		BEGIN
			DELETE FROM dbo.MatchSetting
			WHERE OWPMatchId=@MatchId AND Bettype=@BettypeId
			
			SELECT TOP 1 @Maxbet=ms.Maxbet,
				@Spread=ms.Spread,
				@MaxbetCN88=ms.MaxbetCN88,
				@SpreadCN88=ms.SpreadCN88
			FROM MatchSetting AS ms WITH(NOLOCK)
			WHERE ms.OWPMatchId=@MatchId AND Bettype=@BettypeId
			
			SET @MatchIdUseLog=@MatchId
		END
	-- Xmin/FM of main match
	IF(@MinorBettypeId = 0 AND @BettypeId IN (-1,-88))
		BEGIN
			IF(@BettypeId=-1)
				BEGIN
					INSERT INTO #tblMinorMatch(MinorMatchId)
					SELECT mm.MinorMatchId
					FROM MinorMatch AS mm WITH (NOLOCK)
					WHERE mm.ParentMatchId = @MatchId AND mm.MinorBettypeId IN(-1, -2)
				END
			ELSE
				BEGIN
					INSERT INTO #tblMinorMatch(MinorMatchId)
					SELECT mm.MinorMatchId
					FROM MinorMatch AS mm WITH (NOLOCK)
					WHERE mm.ParentMatchId = @MatchId AND mm.MinorBettypeId =-88
				END
			
			SELECT TOP 1 @Maxbet=ms.Maxbet,
				@Spread=ms.Spread,
				@MaxbetCN88=ms.MaxbetCN88,
				@SpreadCN88=ms.SpreadCN88
			FROM MatchSetting AS ms WITH(NOLOCK)INNER JOIN #tblMinorMatch AS tblMm WITH(NOLOCK)
				ON tblMm.MinorMatchId = ms.OWPMatchId
			
			DELETE FROM dbo.MatchSetting
			FROM #tblMinorMatch AS tblMm WITH(NOLOCK) INNER JOIN MatchSetting AS mm WITH(NOLOCK)
				ON tblMm.MinorMatchId=mm.OWPMatchId
			
			SELECT TOP 1 @MatchIdUseLog = tblMm.MinorMatchId
			FROM #tblMinorMatch AS tblMm WITH(NOLOCK)
			SET @ParentmatchIdUseLog=@MatchId
		END
	-- Xmin number of coner/total booking
	IF(@MinorBettypeId <> 0 AND @BettypeId IN (-5, -8))
		BEGIN
			DECLARE @parentMatchId INT
			
			SELECT TOP 1 @parentMatchId = mm.ParentMatchId
			FROM MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.MinorMatchId=@MatchId
			
			INSERT INTO #tblMinorMatch(MinorMatchId)
			SELECT mm.MinorMatchId
			FROM MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.ParentMatchId=@parentMatchId AND mm.MinorBettypeId = @BettypeId
			
			SELECT TOP 1 @Maxbet=ms.Maxbet,
					@Spread=ms.Spread,
					@MaxbetCN88=ms.MaxbetCN88,
					@SpreadCN88=ms.SpreadCN88
			FROM MatchSetting AS ms WITH(NOLOCK) INNER JOIN #tblMinorMatch AS tblMm WITH (NOLOCK)
				ON ms.OWPMatchId=tblMm.MinorMatchId
			
			DELETE FROM dbo.MatchSetting
			FROM MatchSetting AS ms WITH(NOLOCK) INNER JOIN #tblMinorMatch AS tblMm WITH (NOLOCK)
				ON ms.OWPMatchId=tblMm.MinorMatchId
			
			SELECT @MatchIdUseLog= ms.OWPMatchId
			FROM MatchSetting AS ms WITH(NOLOCK) INNER JOIN #tblMinorMatch AS tblMm WITH (NOLOCK)
				ON ms.OWPMatchId=tblMm.MinorMatchId

			SET @ParentmatchIdUseLog=@MatchId
		END
	DROP TABLE #tblMinorMatch
	-- send message
	IF (dbo.[fnc_IsMatchInTimeRange](@MatchId) = 1)
		BEGIN
			DECLARE @UserReceivedAssigneeMessageMatchInfo TVP_INT,
				@UserReceivedWatcherMessageMatchInfo TVP_INT,
				@NotifyAssigneeMatchInfoUpdatedId INT = 5,
				@NotifyWatcherMatchInfoUpdatedId INT = 9,
				@MessageTemplate NVARCHAR(MAX) = '',
				@MessageTypeId INT,
				@MessageTemplateCode VARCHAR(200)=''
				
			CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

			CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
				MemberId INT
				,UserReceivedWatcherId INT
				,NotificationSettingId INT
				)

			-- get all assignee in match (include main + minor)
			INSERT INTO #tblAllAssigneeOfMatch (UserId)
			SELECT a.UserId
			FROM dbo.fnc_GetAllAssigneeOfMatch(@MatchId) AS a

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
					AND ns.NotificationSettingId IN (@NotifyWatcherMatchInfoUpdatedId)
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
			
			IF(@Maxbet<>NULL)
				BEGIN
					SELECT @MessageTemplate=mt.MsgTemplateContent,
						@MessageTypeId=mt.MsgTemplateId
					FROM MessageTemplate AS mt WITH (NOLOCK)
					WHERE mt.MsgTemplateCode = 'EditMaxbet'
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', '')
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', @Maxbet/1000 + 'K')
					
					EXEC dbo.OWP_MessageInsert @UserId = @UserId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedAssigneeMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 0
					,@SessionId = @SessionId

					EXEC dbo.OWP_MessageInsert @UserId = @UserId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedWatcherMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 1
					,@SessionId = @SessionId	
				END
			IF(@MaxbetCN88<>NULL)
				BEGIN
					SELECT @MessageTemplate=mt.MsgTemplateContent,
						@MessageTypeId=mt.MsgTemplateId
					FROM MessageTemplate AS mt WITH (NOLOCK)
					WHERE mt.MsgTemplateCode='EditMaxbetCN88'
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', '')
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', @MaxbetCN88/1000 + 'K')
					
					EXEC dbo.OWP_MessageInsert @UserId = @UserId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedAssigneeMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 0
					,@SessionId = @SessionId

					EXEC dbo.OWP_MessageInsert @UserId = @UserId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedWatcherMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 1
					,@SessionId = @SessionId														
				END
			IF(@Spread<>NULL)
				BEGIN
					SELECT @MessageTemplate=mt.MsgTemplateContent,
						@MessageTypeId=mt.MsgTemplateId
					FROM MessageTemplate AS mt WITH (NOLOCK)
					WHERE mt.MsgTemplateCode='EditSpread'
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', '')
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', @Spread*100 +'%')
					
					EXEC dbo.OWP_MessageInsert @UserId = @UserId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedAssigneeMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 0
					,@SessionId = @SessionId

					EXEC dbo.OWP_MessageInsert @UserId = @UserId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedWatcherMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 1
					,@SessionId = @SessionId	
				END
			IF(@SpreadCN88<>NULL)
				BEGIN
					SELECT @MessageTemplate=mt.MsgTemplateContent,
						@MessageTypeId=mt.MsgTemplateId
					FROM MessageTemplate AS mt WITH (NOLOCK)
					WHERE mt.MsgTemplateCode='EditSpreadCN88'
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', '')
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', @SpreadCN88*100 +'%')
					
					EXEC dbo.OWP_MessageInsert @UserId = @UserId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedAssigneeMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 0
					,@SessionId = @SessionId

					EXEC dbo.OWP_MessageInsert @UserId = @UserId
					,@MessageContent = @MessageTemplate
					,@MessageType = @MessageTypeId
					,@MessageTo = @UserReceivedWatcherMessageMatchInfo
					,@IsImportant = 0
					,@IsWatcher = 1
					,@SessionId = @SessionId	
				END
			END
	
	--log
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		
	SET @StartRun = GETDATE()
	
	--Old data
	SET @Xml = (
				SELECT ISNULL(@MatchIdUseLog, '') AS '@matchId',
					ISNULL(@ParentmatchIdUseLog,'') AS '@parentMatchId'
				FOR XML PATH('z')
					,ROOT('r')
				)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)
	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_MatchSetting_Delete'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @MatchId
			,@Data = @LogData
			,@DataOld = ''
END