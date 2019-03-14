
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

	DECLARE @MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@OWPMatchId INT
		,@OldNote NVARCHAR(2000)
		,@NotifyAssigneeNoteUpdatedId INT = 3
		,@NotifyWatcherNoteUpdatedId INT = 7
		,@UserReceivedAssigneeMessageNote TVP_INT
		,@UserReceivedWatcherMessageNote TVP_INT

	CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
		)

	SELECT @OldNote = Note
		,@OWPMatchId = OWPMatchId
	FROM dbo.MatchNote WITH (NOLOCK)
	WHERE MatchNoteId = @MatchNoteId

	IF LEN(@Note) > 0
		AND BINARY_CHECKSUM(@OldNote) <> BINARY_CHECKSUM(@Note)
	BEGIN TRY
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
		IF dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1
		BEGIN
			SELECT @MessageTemplate = mt.MsgTemplateContent
				,@MessageType = mt.MsgTemplateId
			FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
			WHERE mt.MsgTemplateCode = 'MatchNoteUpdate'

			SET @MessageTemplate = REPLACE(@MessageTemplate, '<oldnote>', @OldNote)
			SET @MessageTemplate = REPLACE(@MessageTemplate, '<newnote>', @Note)
			SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

			-------------- ASSIGNEE --------------------
			-- get all assignee in match (include main + minor)
			INSERT INTO #tblAllAssigneeOfMatch (UserId)
			SELECT a.UserId
			FROM dbo.fnc_GetAllAssigneeOfMatch(@OWPMatchId) AS a

			-- get list users received ASSIGNEE message update match Note
			INSERT INTO @UserReceivedAssigneeMessageNote
			SELECT a.UserId
			FROM #tblAllAssigneeOfMatch AS a
				LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyAssigneeNoteUpdatedId
				LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
				AND nsm.UserId = a.UserId
			WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'

			EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageType
				,@MessageTo = @UserReceivedAssigneeMessageNote
				,@IsImportant = 0
				,@IsWatcher = 0
				,@SessionId = @SessionId
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			-------------- WATCHER --------------------
			-- get all SectionMemberOfUserReceivedWatcher
			INSERT INTO #tblSectionMemberOfUserReceivedWatcher (
				MemberId
				,UserReceivedWatcherId
				)
			SELECT ISNULL(mem.UserId, r.UserId)
				,r.UserId
			FROM (
				SELECT w.UserId
					,u.SectionId
				FROM dbo.fnc_GetWatcherToSendMessage(@NotifyWatcherNoteUpdatedId) AS w
					LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
				) AS r
				LEFT JOIN dbo.[User] AS mem WITH (NOLOCK) ON r.SectionId = mem.SectionId
				AND mem.SectionId IS NOT NULL

			-- get list users received Watcher message update Note
			INSERT INTO @UserReceivedWatcherMessageNote (Id)
			SELECT DISTINCT sm.UserReceivedWatcherId
			FROM #tblAllAssigneeOfMatch AS a
				INNER JOIN #tblSectionMemberOfUserReceivedWatcher AS sm ON sm.MemberId = a.UserId
			WHERE NOT EXISTS (
					-- ignore user received Assignee message
					SELECT 1
					FROM @UserReceivedAssigneeMessageNote AS ur
					WHERE ur.Id = sm.UserReceivedWatcherId
					)

			EXECUTE dbo.OWP_MessageInsert @UserId = @UserId
				,@MessageContent = @MessageTemplate
				,@MessageType = @MessageType
				,@MessageTo = @UserReceivedWatcherMessageNote
				,@IsImportant = 0
				,@IsWatcher = 1
				,@SessionId = @SessionId
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT
		END
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update note failed. Please try again.'
			,@ErrCode = 4101 -- ActionId + 01
	END CATCH

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END