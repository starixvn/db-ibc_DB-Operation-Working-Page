
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

	DECLARE @MessageTemplate NVARCHAR(MAX) = ''
		,@MessageType INT
		,@StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@Assignee TVP_INT
		,@NotificationSettingId INT = 3
		,@NotificationSettingIdWatcher INT = 7

	SET @StartRun = GETDATE()

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

	-- insert message
	IF (dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1)
	BEGIN
		SELECT @MessageTemplate = mt.MsgTemplateContent
			,@MessageType = mt.MsgTemplateId
		FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
		WHERE mt.MsgTemplateCode = 'MatchNoteInsert'

		SET @MessageTemplate = REPLACE(@MessageTemplate, '<newnote>', @Note)
		SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @UserId)

		INSERT INTO @Assignee
		SELECT UserId
		FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, @NotificationSettingId)

		-- insert MatchNoteUser
		EXEC dbo.OWP_MatchNoteUser_Insert @MatchNoteId = @MatchNoteId
			,@CreatorId = @UserId
			,@UserIds = @Assignee
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		-- insert message
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
	SELECT @ErrMsg = @MatchNoteId
END