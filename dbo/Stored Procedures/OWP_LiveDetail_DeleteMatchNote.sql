
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
		,@MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@NotifyAssigneeNoteUpdatedId INT = 3
		,@NotifyWatcherNoteUpdatedId INT = 7
		,@UserReceivedAssigneeMessageNote TVP_INT
		,@UserReceivedWatcherMessageNote TVP_INT

	CREATE TABLE #tblAllAssigneeOfMatch (UserId INT NOT NULL)

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
		)

	BEGIN TRY --
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

			-------------- ASSIGNEE --------------------
			-- get all assignee in match (include main + minor)
			INSERT INTO #tblAllAssigneeOfMatch (UserId)
			SELECT a.UserId
			FROM dbo.fnc_GetAllAssigneeOfMatch(@OWPMatchId) AS a

			-- get list users received ASSIGNEE message update match Note
			INSERT INTO @UserReceivedAssigneeMessageNote (Id)
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
		SELECT @ErrMsg = 'Delete note failed. Please try again.'
			,@ErrCode = 4201
	END CATCH

	DROP TABLE #tblAllAssigneeOfMatch

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END