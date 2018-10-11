/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_DeleteMatchNote] @UserId INT
	,@MatchNoteId INT
	,@SessionId NVARCHAR(50) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161130@Tim.Trinh
Task : delete MatchNote
DB: bodb_OWP

Revisions:
   20170420@Tim.Trinh: modify time to send message
   20180927@Leo.Vo: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OldNote NVARCHAR(MAX)
		,@OWPMatchId INT
		,@StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@MessageTemplateData NVARCHAR(MAX)
		,@Xml XML
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@Username NVARCHAR(100)
		,@Traders NVARCHAR(MAX)
		,@EventDateTime DATETIME
		,@IsSelected BIT = 0
		,@FromTime DATETIME
		,@ToTime DATETIME
		,@FromTimeForSpecialBettype DATETIME
		,@ToTimeViewDetailForSpecialBettype DATETIME
		,@ToTimeForSpecialBettype DATETIME
	DECLARE @HomeVsAway TABLE (
		Home NVARCHAR(200)
		,Away NVARCHAR(200)
		)

	BEGIN TRY
		-- Log
		SET @StartRun = GETDATE()
		SET @Xml = (
				SELECT OWPMatchId AS '@mt'
					,Note AS '@nt'
					,CreatedBy AS '@cb'
					,CreatedDate AS '@cd'
				FROM dbo.MatchNote WITH (NOLOCK)
				WHERE MatchNoteId = @MatchNoteId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @MessageTemplateData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		--
		SELECT @OWPMatchId = OWPMatchId
			,@OldNote = Note
		FROM dbo.MatchNote WITH (NOLOCK)
		WHERE MatchNoteId = @MatchNoteId

		-- delete
		DELETE
		FROM dbo.MatchNote WITH (ROWLOCK, UPDLOCK)
		WHERE MatchNoteId = @MatchNoteId

		-- insert message
		SELECT @FromTime = FromTime
			,@ToTime = ToTime
			,@FromTimeForSpecialBettype = FromTimeForSpecialBettype
			,@ToTimeForSpecialBettype = ToTimeForSpecialBettype
			,@ToTimeViewDetailForSpecialBettype = ToTimeViewDetailForSpecialBettype
		FROM dbo.fnc_GetDateTimeForTraderViewTime()

		SELECT @EventDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME))
			,@IsSelected = info.IsSelected
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
		WHERE om.OWPMatchId = @OWPMatchId

		IF (
				@IsSelected = 1
				AND @EventDateTime BETWEEN @FromTime
					AND @ToTimeForSpecialBettype
				)
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
					,@MessageType = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'MatchNoteDelete'

			SELECT @Username = dbo.[OWP_GetUsernameByUserId](@UserId)

			INSERT INTO @HomeVsAway (
				Home
				,Away
				)
			EXEC dbo.OWP_LiveDetail_GetHomeAwayToSendMessage @OWPMatchId

			SELECT @Traders = COALESCE(@Traders + ',', '') + CAST(data.UserId AS NVARCHAR(10))
			FROM (
				SELECT DISTINCT a.UserId
				FROM dbo.Assignment AS a WITH (NOLOCK)
				WHERE a.OWPMatchId = @OWPMatchId
					AND a.Bettype > 0
				
				UNION
				SELECT DISTINCT a.UserId
				FROM dbo.MinorMatch AS mm WITH (NOLOCK)
					INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
					INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON mm.MinorMatchId = a.OWPMatchId
					AND mb.InheritedBettypeId = a.Bettype
				WHERE mm.IsRepresented = 1
					AND mm.ParentMatchId = @OWPMatchId
				) AS data

			IF LEN(@MessageTemplate) > 0
			BEGIN
				SET @MessageTemplate = REPLACE(@MessageTemplate, '<user>', @Username)
				SET @MessageTemplate = REPLACE(@MessageTemplate, '<home>', (
							SELECT Home
							FROM @HomeVsAway
							))
				SET @MessageTemplate = REPLACE(@MessageTemplate, '<away>', (
							SELECT Away
							FROM @HomeVsAway
							))
				SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldnote>', @OldNote)
			END

			IF LEN(@Traders) > 0
				AND LEN(@MessageTemplate) > 0
			BEGIN
				EXEC dbo.OWP_MessageInsert @UserId = @UserId
					,@MessageContent = @MessageTemplate
					,@MessageTo = @Traders
					,@IsImportant = 0
					,@MessageType = @MessageType
					,@SessionId = @SessionId
					,@ErrCode = @ErrCode OUTPUT
					,@ErrMsg = @ErrMsg OUTPUT
			END
		END

		-- Write Log: Continue		
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LiveDetail_DeleteMatchNote'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @MatchNoteId
			,@Data = NULL
			,@DataOld = @MessageTemplateData
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Delete note failed. Please try again.'
			,@ErrCode = 4201

		RETURN
	END CATCH
END