
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchSetting_Update]
	@UserId INT,
	@SessionId VARCHAR(50) = NULL, 
	@MinorBettypeId INT,
	@BettypeId INT,
	@Bettype VARCHAR(255),
	@MatchId INT,
	@Maxbet MONEY = NULL,
	@Spread SMALLMONEY = NULL,
	@MaxbetCN88 MONEY = NULL,
	@SpreadCN88 SMALLMONEY = NULL,
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 2019-13-08@Carlos
Task : Update match setting
DB: bodb_OWP

Revisions:
	20190819@Carlos: Initial SP - [Feature: #118856]
*/

BEGIN
	DECLARE @minorMatchId INT,
		@parentMatchId INT,
		@OldMaxbet MONEY = NULL,
		@OldSpread SMALLMONEY = NULL,
		@OldMaxbetCN88 MONEY = NULL,
		@OldSpreadCN88 SMALLMONEY = NULL
	
	IF(@BettypeId IN (1,3,5,7,8,15))
		BEGIN
			SELECT TOP 1 @OldMaxbet= mm.Maxbet,
				@OldSpread=mm.Spread,
				@OldMaxbetCN88=mm.MaxbetCN88,
				@OldSpreadCN88=mm.SpreadCN88
			FROM MatchSetting AS mm WITH(NOLOCK)
			WHERE mm.OWPMatchId=@MatchId AND mm.Bettype=@BettypeId
		
			DELETE FROM dbo.MatchSetting
			WHERE OWPMatchId=@MatchId AND Bettype=@BettypeId
			
			INSERT INTO dbo.MatchSetting(OWPMatchId,Bettype,Maxbet,MaxbetCN88,Spread,SpreadCN88)
			VALUES(@MatchId,@BettypeId,@Maxbet,@MaxbetCN88,@Spread,@SpreadCN88)
		END
	-- Main match
	IF(@MinorBettypeId = 0 AND @BettypeId IN (-1,-88))
		BEGIN
			CREATE TABLE #tblMinorMatch(MinorMatchId INT)
			IF(@BettypeId = -1)
				BEGIN
					INSERT INTO #tblMinorMatch(MinorMatchId)
					SELECT mm.MinorMatchId
					FROM MinorMatch AS mm WITH (NOLOCK)
					WHERE mm.ParentMatchId = @MatchId AND mm.MinorBettypeId IN (-1, -2)
				END
			ELSE
				BEGIN
					INSERT INTO #tblMinorMatch(MinorMatchId)
					SELECT mm.MinorMatchId
					FROM MinorMatch AS mm WITH (NOLOCK)
					WHERE mm.ParentMatchId = @MatchId AND mm.MinorBettypeId =-88
				END
			
			SELECT TOP 1 @OldMaxbet= mm.Maxbet,
				@OldSpread=mm.Spread,
				@OldMaxbetCN88=mm.MaxbetCN88,
				@OldSpreadCN88=mm.SpreadCN88
			FROM MatchSetting AS mm WITH(NOLOCK)INNER JOIN #tblMinorMatch AS tblMm WITH(NOLOCK)
				ON mm.OWPMatchId=tblMm.MinorMatchId
			
			DELETE FROM dbo.MatchSetting
			FROM MatchSetting AS mm WITH(NOLOCK)INNER JOIN #tblMinorMatch AS tblMm WITH(NOLOCK)
				ON mm.OWPMatchId=tblMm.MinorMatchId
			
			INSERT INTO dbo.MatchSetting(OWPMatchId,Bettype,Maxbet,MaxbetCN88,Spread,SpreadCN88)
			SELECT tblMm.MinorMatchId,
				1,
				@Maxbet,
				@MaxbetCN88,
				@Spread,
				@SpreadCN88
			FROM #tblMinorMatch AS tblMm WITH(NOLOCK)
			DROP TABLE #tblMinorMatch
		END
		
		
		-- TotalBooking & Number Of Conner
	IF(@MinorBettypeId <> 0 AND @BettypeId IN (-5, -8))
		BEGIN	
			SELECT TOP 1 @parentMatchId = mm.ParentMatchId
			FROM MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.MinorMatchId=@MatchId
				
			SELECT TOP 1 @minorMatchId= mm.MinorMatchId
			FROM MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.ParentMatchId=@parentMatchId AND mm.MinorBettypeId = @BettypeId
			
			SELECT TOP 1 @OldMaxbet= mm.Maxbet,
				@OldSpread=mm.Spread,
				@OldMaxbetCN88=mm.MaxbetCN88,
				@OldSpreadCN88=mm.SpreadCN88
			FROM MatchSetting AS mm WITH(NOLOCK)
			WHERE mm.OWPMatchId=@minorMatchId
			
			DELETE FROM dbo.MatchSetting
			WHERE OWPMatchId=@minorMatchId
			
			INSERT INTO dbo.MatchSetting(OWPMatchId,Bettype,Maxbet,MaxbetCN88,Spread,SpreadCN88)
			VALUES(@minorMatchId,1,@Maxbet,@MaxbetCN88,@Spread,@SpreadCN88)
		END
	
	-- send message
	IF (dbo.[fnc_IsMatchInTimeRange](@MatchId) = 1 AND 
		(@OldMaxbet<>@Maxbet
		OR @OldSpread<>@Spread
		OR @OldMaxbetCN88<>@MaxbetCN88
		OR @OldSpreadCN88<>@SpreadCN88))
		BEGIN
			DECLARE @UserReceivedAssigneeMessageMatchInfo TVP_INT,
				@UserReceivedWatcherMessageMatchInfo TVP_INT,
				@NotifyAssigneeMatchInfoUpdatedId INT = 5,
				@NotifyWatcherMatchInfoUpdatedId INT = 9,
				@MessageTemplate NVARCHAR(2000) = '',
				@MessageTypeId INT,
				@MessageTemplateCode NVARCHAR(200)='',
				@New MONEY,
				@Old MONEY
				
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
			
			IF(@OldMaxbet<>@Maxbet)
				BEGIN
					DECLARE @MaxbetFormatK VARCHAR(20)=NULL,
						@OldMaxbetFormatK VARCHAR(20)=NULL
						
					SELECT @MessageTemplate=mt.MsgTemplateContent,
						@MessageTypeId=mt.MsgTemplateId
					FROM MessageTemplate AS mt WITH (NOLOCK)
					WHERE mt.MsgTemplateCode='EditMaxbet'
					
					IF(@Maxbet<>NULL)
						BEGIN
							SET @MaxbetFormatK=@Maxbet/1000 + 'K'
						END
					IF(@OldMaxbet<>NULL)
						BEGIN
							SET @OldMaxbetFormatK=@OldMaxbet/1000 + 'K'
						END
					
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', ISNULL(@MaxbetFormatK,''))
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', ISNULL(@OldMaxbetFormatK,''))
					
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
			IF(@OldMaxbetCN88<>@MaxbetCN88)
				BEGIN
					DECLARE @MaxbetCN88FormatK VARCHAR(20)=NULL,
						@OldMaxbetCN88FormatK VARCHAR(20)=NULL
						
					SELECT @MessageTemplate=mt.MsgTemplateContent,
						@MessageTypeId=mt.MsgTemplateId
					FROM MessageTemplate AS mt WITH (NOLOCK)
					WHERE mt.MsgTemplateCode='EditMaxbetCN88'
			
					IF(@MaxbetCN88<>NULL)
						BEGIN
							SET @MaxbetCN88FormatK=@MaxbetCN88/1000 + 'K'
						END
					IF(@OldMaxbetCN88<>NULL)
						BEGIN
							SET @OldMaxbetCN88FormatK=@OldMaxbetCN88/1000 + 'K'
						END
						
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', ISNULL(@MaxbetCN88FormatK,''))
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', ISNULL(@OldMaxbetCN88FormatK,''))
					
					
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
			IF(@OldSpread<>@Spread)
				BEGIN
					DECLARE @SpreadFormatK VARCHAR(20)=NULL,
						@OldSpreadFormatK VARCHAR(20)=NULL
						
					SELECT @MessageTemplate=mt.MsgTemplateContent,
						@MessageTypeId=mt.MsgTemplateId
					FROM MessageTemplate AS mt WITH (NOLOCK)
					WHERE mt.MsgTemplateCode='EditSpread'
					
					IF(@Spread<>NULL)
						BEGIN
							SET @SpreadFormatK=@Spread*100 + '%'
						END
					IF(@OldSpread<>NULL)
						BEGIN
							SET @OldSpreadFormatK=@OldSpread*100 + '%'
						END
					
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', ISNULL(@SpreadFormatK,''))
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', ISNULL(@OldSpreadFormatK,''))
					
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
			IF(@OldSpreadCN88<>@SpreadCN88)
				BEGIN
					DECLARE @SpreadCN88FormatK VARCHAR(20)=NULL,
						@OldSpreadCN88FormatK VARCHAR(20)=NULL
						
					SELECT @MessageTemplate=mt.MsgTemplateContent,
						@MessageTypeId=mt.MsgTemplateId
					FROM MessageTemplate AS mt WITH (NOLOCK)
					WHERE mt.MsgTemplateCode='EditSpreadCN88'
					
					IF(@SpreadCN88<>NULL)
						BEGIN
							SET @SpreadCN88FormatK=@SpreadCN88*100 + '%'
						END
					IF(@OldSpreadCN88<>NULL)
						BEGIN
							SET @OldSpreadCN88FormatK=@OldSpreadCN88*100 + '%'
						END
						
					SET @MessageTemplate = dbo.fnc_ReplaceMessageTemplate(@MessageTemplate,@MatchId,@UserId)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Bettype>', @Bettype)
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<New>', ISNULL(@SpreadCN88FormatK,''))
					SET @MessageTemplate = REPLACE(@MessageTemplate,'<Old>', ISNULL(@OldSpreadCN88FormatK,''))
					
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
			
	--- Log
	DECLARE @StartRun DATETIME
			,@EndRun DATETIME
			,@Duration INT
			,@LogDataOld NVARCHAR(MAX)
			,@LogData NVARCHAR(MAX)
			,@Xml XML
		
	SET @StartRun = GETDATE()
			
	-- Old data
	SET @Xml=(
			SELECT ISNULL(@OldMaxbet, '') AS '@oldmbet'
				,ISNULL(@OldSpread, '') AS '@oldspread'
				,ISNULL(@OldMaxbetCN88, 0) AS '@oldmbetCN88'
				,ISNULL(@OldSpreadCN88, '') AS '@oldsCN88'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
			
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
		,@SPName = 'OWP_MatchSetting_Update'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @UserId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END