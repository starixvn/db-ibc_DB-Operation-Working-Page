
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_InsertMatchNote] @MatchNoteId INT OUTPUT
	,@UserId INT
	,@OWPMatchId INT
	,@Note NVARCHAR(MAX)
	,@SessionId NVARCHAR(50)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161129@Tim.Trinh
Task : Insert new MatchNote
DB: bodb_OWP

Revisions:
   20170901@Tim.Trinh: insert MatchNoteUser
   20170420@Tim.Trinh: modify time to send message
   20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
   20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
   20190307@Kane.Le: add Notification Watcher - [Redmine: #109560]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @MessageTemplate NVARCHAR(2000) = ''
		,@MessageType INT
		,@NotifyAssigneeNoteUpdatedId INT = 3
		,@NotifyWatcherNoteUpdatedId INT = 7
		,@UserReceivedAssigneeMessageNote TVP_INT
		,@UserReceivedWatcherMessageNote TVP_INT
		,@AllAssigneeOfMatch TVP_INT

	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
		)

	-- insert
	INSERT INTO dbo.MatchNote (
		OWPMatchId
		,CreatedBy
		,Note
		)
	VALUES (
		@OWPMatchId
		,@UserId
		,@Note
		)

	SELECT @MatchNoteId = SCOPE_IDENTITY()

	-- get all assignee in match (include main + minor)
	INSERT INTO @AllAssigneeOfMatch (Id)
	SELECT a.UserId
	FROM dbo.fnc_GetAllAssigneeOfMatch(@OWPMatchId) AS a

	-- insert MatchNoteUser
	EXEC dbo.OWP_MatchNoteUser_Insert @MatchNoteId = @MatchNoteId
		,@CreatorId = @UserId
		,@UserIds = @AllAssigneeOfMatch
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT

	-- insert message
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		SELECT @MessageTemplate = mt.MsgTemplateContent
			,@MessageType = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'MatchNoteInsert'

		SET @MessageTemplate = REPLACE(@MessageTemplate, '<newnote>', @Note)
		SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

		-------------- ASSIGNEE --------------------
		-- get list users received ASSIGNEE message update match Note
		INSERT INTO @UserReceivedAssigneeMessageNote (Id)
		SELECT a.Id
		FROM @AllAssigneeOfMatch AS a
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @NotifyAssigneeNoteUpdatedId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = a.Id
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
		FROM @AllAssigneeOfMatch AS a
			INNER JOIN #tblSectionMemberOfUserReceivedWatcher AS sm ON sm.MemberId = a.Id
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

	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END