
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
   20190308@Kane.Le: add Notification Watcher - [Redmine: #109560]
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
		,@NotificationSettingId INT = 3
		,@NotificationSettingIdWatcher INT = 7

	SELECT @OldNote = Note
		,@OWPMatchId = OWPMatchId
	FROM dbo.MatchNote WITH (NOLOCK)
	WHERE MatchNoteId = @MatchNoteId

	IF LEN(@Note) > 0
		AND BINARY_CHECKSUM(@OldNote) <> BINARY_CHECKSUM(@Note)
	BEGIN TRY
		-- update
		UPDATE dbo.MatchNote
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET Note = @Note
			,CreatedBy = @UserId
			,CreatedDate = GETDATE()
		WHERE MatchNoteId = @MatchNoteId

		UPDATE dbo.MatchNoteUser
		WITH (
				ROWLOCK
				,UPDLOCK
				)

		SET IsViewed = 0
		WHERE MatchNoteId = @MatchNoteId

		-- insert message  
		IF dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1
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

			DROP TABLE #tblUserAssignees

			DROP TABLE #tblUserIdReciveWatchers
				------------- END Watcher -----------------------
		END
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update note failed. Please try again.'
			,@ErrCode = 4101 -- ActionId + 01

		RETURN
	END CATCH
END