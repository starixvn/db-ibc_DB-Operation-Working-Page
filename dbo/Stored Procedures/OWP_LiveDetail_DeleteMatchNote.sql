
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
   20190308@Kane.Le: add Notification Watcher - [Redmine: #109560]
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
		,@NotificationSettingId INT = 3
		,@NotificationSettingIdWatcher INT = 7
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
		FROM dbo.MatchNote WITH (
				ROWLOCK
				,UPDLOCK
				)
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
			FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, @NotificationSettingId)

			EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
				,@MessageContent = @MessageTemplate
				,@MessageTo = @Assignee
				,@IsImportant = 0
				,@MessageType = @MessageType
				,@SessionId = @SessionId
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			-------------- WATCHER --------------------
			-- 20190304@Kane.Le send message to watcher
			CREATE TABLE #tblUserAssignees (
				UserId INT NOT NULL
				,SectionId INT
				)

			INSERT INTO #tblUserAssignees (
				UserId
				,SectionId
				)
			SELECT u.UserId
				,u.SectionId
			FROM dbo.[fnc_GetAllAssigneeOfMatch](@OWPMatchId) AS u
			WHERE NOT EXISTS (
					SELECT 1
					FROM #tblUserAssignees AS ass2
					WHERE u.UserId = ass2.UserId
					)

			CREATE TABLE #tblUserIdReciveWatchers (
				UserId INT NOT NULL
				,SectionId INT
				)

			INSERT INTO #tblUserIdReciveWatchers (
				UserId
				,SectionId
				)
			SELECT nsm.UserId
				,u.SectionId
			FROM dbo.NotificationSetting AS ns WITH (NOLOCK)
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON nsm.UserId = u.UserId
			WHERE ns.NotificationSettingId = @NotificationSettingIdWatcher
				AND ISNULL(nsm.Value, ns.DefaultValue) = 'True'
				AND u.SectionId IN (
					SELECT SectionId
					FROM #tblUserAssignees
					)
				AND u.UserId <> @UserId

			DECLARE @RowCount INT = 0
			DECLARE @MessageId INT

			SELECT @RowCount = COUNT(1)
			FROM #tblUserIdReciveWatchers

			IF @RowCount > 0
			BEGIN
				INSERT INTO dbo.[Message] (
					MessageContent
					,MessageType
					,CreatedBy
					,IsImportant
					,IsWatcher
					)
				VALUES (
					@MessageTemplate
					,@MessageType
					,@UserId
					,0
					,1
					)

				SET @MessageId = @@IDENTITY

				IF @MessageId IS NOT NULL
					INSERT INTO dbo.MessageUser (
						MessageId
						,UserId
						,IsViewed
						,SessionId
						)
					SELECT @MessageId
						,wc.UserId
						,0
						,@SessionId
					FROM #tblUserIdReciveWatchers AS wc
			END
		END

		DROP TABLE #tblUserAssignees

		DROP TABLE #tblUserIdReciveWatchers
		------------- END Watcher -----------------------
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Delete note failed. Please try again.'
			,@ErrCode = 4201

		RETURN
	END CATCH
END