
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
		FROM dbo.[fnc_GetAssigneeToSendMessage](@OWPMatchId, 3)

		-- insert MatchNoteUser
		EXEC dbo.OWP_MatchNoteUser_Insert @MatchNoteId = @MatchNoteId
			,@CreatorId = @UserId
			,@UserIds = @Assignee
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		-- insert message
		EXEC dbo.OWP_MessageInsert @UserId = @UserId
			,@MessageContent = @MessageTemplate
			,@MessageTo = @Assignee
			,@IsImportant = 0
			,@MessageType = @MessageType
			,@SessionId = @SessionId
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT
	END

	SELECT @ErrMsg = @MatchNoteId

	-- For write log
	SET @Xml = (
			SELECT @OWPMatchId AS '@mt'
				,@Note AS '@nt'
				,@UserId AS '@cb'
				,GETDATE() AS '@cd'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
		,@SPName = 'OWP_LiveDetail_InsertMatchNote'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @MatchNoteId
		,@Data = @LogData
		,@DataOld = NULL
END