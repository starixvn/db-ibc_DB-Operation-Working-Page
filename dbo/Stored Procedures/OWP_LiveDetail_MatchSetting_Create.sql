
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchSetting_Create]
	@SessionId VARCHAR(50), 
    @UserId INT,
	@MinorBettypeId INT,
	@MatchId INT,
	@BettypeId INT,
	@Bettype VARCHAR(50),
	@Maxbet MONEY = NULL,
	@Spread SMALLMONEY = NULL,
	@MaxbetCN88 MONEY = NULL,
	@SpreadCN88 SMALLMONEY = NULL,
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 2019-13-08@Carlos
Task : Add new match setting
DB: bodb_OWP

Revisions:
	20190819@Carlos: Initial SP - [Feature: #118856]
*/

BEGIN
	DECLARE @minorMatchId INT
	
	IF(@BettypeId IN (1,3,5,7,8,15))
		BEGIN
			INSERT INTO MatchSetting(OWPMatchId,Bettype,Maxbet,Spread,MaxbetCN88, SpreadCN88)
			VALUES(@MatchId,@BettypeId,@Maxbet,@Spread,@MaxbetCN88,@SpreadCN88)
		END
	IF(@MinorBettypeId = 0 AND @BettypeId IN (-1,-88))
		BEGIN
			SELECT TOP 1 @minorMatchId = mm.MinorMatchId
			FROM MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.ParentMatchId = @MatchId AND mm.MinorBettypeId = @BettypeId
						
			INSERT INTO MatchSetting(OWPMatchId,Bettype,Maxbet,Spread,MaxbetCN88, SpreadCN88)
			VALUES(@minorMatchId,1,@Maxbet,@Spread,@MaxbetCN88,@SpreadCN88)
		END
	IF(@MinorBettypeId <> 0 AND @BettypeId =-1)
		BEGIN
			DECLARE @parentMatchId INT
			
			SELECT TOP 1 @parentMatchId = mm.ParentMatchId
			FROM MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.MinorMatchId=@MatchId
			
			SELECT TOP 1 @minorMatchId= mm.MinorMatchId
			FROM MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.ParentMatchId=@parentMatchId AND mm.MinorBettypeId IN (-5, -8)
			
			INSERT INTO MatchSetting(OWPMatchId,Bettype,Maxbet,Spread,MaxbetCN88, SpreadCN88)
			VALUES(@minorMatchId,1,@Maxbet,@Spread,@MaxbetCN88,@SpreadCN88)
		END
	
	-- send message
	--IF (dbo.[fnc_IsMatchInTimeRange](@MatchId) = 1)
		BEGIN
			DECLARE @UserReceivedAssigneeMessageMatchInfo TVP_INT,
				@UserReceivedWatcherMessageMatchInfo TVP_INT,
				@NotifyAssigneeMatchInfoUpdatedId INT = 5,
				@NotifyWatcherMatchInfoUpdatedId INT = 9,
				@MessageTemplate NVARCHAR(2000) = '',
				@MessageTypeId INT,
				@MessageTemplateCode NVARCHAR(200)=''
				
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
					FROM dbo.fnc_GetMessageTemplateByCode('EditMaxbet') AS mt
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', @Maxbet)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', '')
					
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
					FROM dbo.fnc_GetMessageTemplateByCode('EditMaxbetCN88') AS mt
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', @MaxbetCN88)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', '')
					
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
					FROM dbo.fnc_GetMessageTemplateByCode('EditSpread') AS mt
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', @Spread)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', '')
					
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
					FROM dbo.fnc_GetMessageTemplateByCode('EditSpreadCN88') AS mt
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', @SpreadCN88)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', '')
					
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
	
	-- log
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		
	SET @StartRun = GETDATE()
	--New data
	SET @Xml = (
				SELECT ISNULL(@BettypeId, '') AS '@bttype'
					,ISNULL(@Maxbet, '') AS '@mbet'
					,ISNULL(@Spread, '') AS '@spread'
					,ISNULL(@MaxbetCN88, 0) AS '@mbetCN88'
					,ISNULL(@SpreadCN88, '') AS '@sCN88'
				FOR XML PATH('z')
					,ROOT('r')
				)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)
	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_MatchSetting_Create'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @UserId
			,@Data = @LogData
			,@DataOld = ''
END