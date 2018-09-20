CREATE PROCEDURE [dbo].[OWP_LiveDetail_AddMessageWhenUpdateAssignment] @UserId INT
	,@OldUserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@ModifiedBy INT
	,@SessionId NVARCHAR(50) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161228@Quinn.Vo
Task: Add Message when Update Assignments at Live Detail.
DB: bodb_OWP
Original: 

Revisions:
	20170403@Alvin.Nguyen: get NotifyMsg  
Param's Explanation:
• @ErrCode:
	= 0: Transaction recorded successfully.
	> 0: Specific Error.
• @ErrMsg: Error description.

*/
BEGIN
	SET NOCOUNT ON

	DECLARE @MessageSendTo VARCHAR(20)
		,@AddAssignmentMessageTemplate NVARCHAR(500)
		,@RemoveAssignmentMessageTemplate NVARCHAR(500)
		,@AddAssignmentMessageTemplateId INT
		,@RemoveAssignmentMessageTemplateId INT
		,@EventDetails NVARCHAR(500)
		,@BettypeName NVARCHAR(50)

	SELECT @AddAssignmentMessageTemplate = mt.MsgTemplateContent
			,@AddAssignmentMessageTemplateId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'AssignmentInsert'

	SELECT @RemoveAssignmentMessageTemplate = mt.MsgTemplateContent
			,@RemoveAssignmentMessageTemplateId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'AssignmentDelete'

	SELECT @BettypeName = typenamee
	FROM bodb02.dbo.Bettype WITH (NOLOCK)
	WHERE typeid = @Bettype

	SELECT @EventDetails = HomeTeam + ' vs ' + AwayTeam
	FROM dbo.fnc_GetMatchInfo(@OWPMatchId)

	SELECT @AddAssignmentMessageTemplate = REPLACE(@AddAssignmentMessageTemplate, '<event>', @EventDetails)
		,@RemoveAssignmentMessageTemplate = REPLACE(@RemoveAssignmentMessageTemplate, '<event>', @EventDetails)

	IF @Bettype = - 1001 -- 1H LA
	BEGIN
		SELECT @AddAssignmentMessageTemplate = REPLACE(@AddAssignmentMessageTemplate, '<bettype>', '1H LA')
			,@RemoveAssignmentMessageTemplate = REPLACE(@RemoveAssignmentMessageTemplate, '<bettype>', '1H LA')
	END
	ELSE IF @Bettype = - 1002 -- 2H LA
	BEGIN
		SELECT @AddAssignmentMessageTemplate = REPLACE(@AddAssignmentMessageTemplate, '<bettype>', '2H LA')
			,@RemoveAssignmentMessageTemplate = REPLACE(@RemoveAssignmentMessageTemplate, '<bettype>', '2H LA')
	END
	ELSE
	BEGIN
		SELECT @AddAssignmentMessageTemplate = REPLACE(@AddAssignmentMessageTemplate, '<bettype>', @BettypeName)
			,@RemoveAssignmentMessageTemplate = REPLACE(@RemoveAssignmentMessageTemplate, '<bettype>', @BettypeName)
	END

	IF (@UserId IS NOT NULL)
	BEGIN
		SET @MessageSendTo = CAST(@UserId AS VARCHAR(20))

		EXEC [dbo].[OWP_MessageInsert] @UserId = @ModifiedBy
			,@MessageContent = @AddAssignmentMessageTemplate
			,@MessageTo = @MessageSendTo
			,@IsImportant = 1
			,@IsPermanent = 0
			,@MessageType = @AddAssignmentMessageTemplateId
			,@SessionId = @SessionId
	END

	IF (@OldUserId IS NOT NULL)
	BEGIN
		SET @MessageSendTo = CAST(@OldUserId AS VARCHAR(20))

		EXEC [dbo].[OWP_MessageInsert] @UserId = @ModifiedBy
			,@MessageContent = @RemoveAssignmentMessageTemplate
			,@MessageTo = @MessageSendTo
			,@IsImportant = 1
			,@IsPermanent = 0
			,@MessageType = @RemoveAssignmentMessageTemplateId
			,@SessionId = @SessionId
	END
END