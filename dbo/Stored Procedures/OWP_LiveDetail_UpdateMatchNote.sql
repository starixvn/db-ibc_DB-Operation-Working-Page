
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateMatchNote] @UserId INT
	,@MatchNoteId INT
	,@Note NVARCHAR(MAX)
	,@SessionId NVARCHAR(50) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161129@Tim.Trinh
Task : update MatchNote
DB: bodb_OWP

Revisions:
   20170420@Tim.Trinh: modify time to send message
   20170821@Tim.Trinh: update status match note user 
   20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
   20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@OWPMatchId INT
		,@OldNote NVARCHAR(2000)
		,@Assignee TVP_INT

	SELECT @OldNote = Note
		,@OWPMatchId = OWPMatchId
	FROM dbo.MatchNote WITH (NOLOCK)
	WHERE MatchNoteId = @MatchNoteId

	IF LEN(@Note) > 0
		AND BINARY_CHECKSUM(@OldNote) <> BINARY_CHECKSUM(@Note)
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
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		-- update
		UPDATE dbo.MatchNote WITH (UPDLOCK, ROWLOCK)
		SET Note = @Note
			,CreatedBy = @UserId
			,CreatedDate = GETDATE()
		WHERE MatchNoteId = @MatchNoteId

		UPDATE dbo.MatchNoteUser WITH (ROWLOCK, UPDLOCK)
		SET IsViewed = 0
		WHERE MatchNoteId = @MatchNoteId

		-- insert message  
		IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageType = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'MatchNoteUpdate'

			SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldnote>', @OldNote)
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<newnote>', @Note)
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

		-- For write log
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
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LiveDetail_UpdateMatchNote'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @MatchNoteId
			,@Data = @LogData
			,@DataOld = @LogDataOld
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update note failed. Please try again.'
			,@ErrCode = 4101 -- ActionId + 01

		RETURN
	END CATCH
END