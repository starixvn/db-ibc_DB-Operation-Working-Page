
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
   20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
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
		,@Assignee TVP_INT
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
		IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageType = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'MatchNoteDelete'

			SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldnote>', @OldNote)
			SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

			INSERT INTO @Assignee
			SELECT UserId
			FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, 3)

			EXEC dbo.OWP_MessageInsert @UserId = @UserId
				,@MessageContent = @MessageTemplate
				,@MessageTo = @Assignee
				,@IsImportant = 0
				,@MessageType = @MessageType
				,@SessionId = @SessionId
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT
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