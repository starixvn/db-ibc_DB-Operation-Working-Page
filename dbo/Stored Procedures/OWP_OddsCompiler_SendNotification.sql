
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_SendNotification] @ActorId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@SessionId VARCHAR(50)
	,@AssigneeIds VARCHAR(MAX)
	,@WatcherIds VARCHAR(MAX)
AS
/*          
 Created: 20191106@Tyler.Dang
 Task : Send notification
 DB: bodb_OWP          
          
 Revisions:
	20191106@Tyler.Dang: Init SP - [Redmine: #116230]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tblAssignee TVP_INT
	DECLARE @tblWatcher TVP_INT
	
	INSERT INTO @tblAssignee(Id)
	SELECT val FROM dbo.fnc_SplitStrings(@AssigneeIds, ',')
	OPTION (MAXRECURSION 0)
	
	INSERT INTO @tblWatcher(Id)
	SELECT val FROM dbo.fnc_SplitStrings(@WatcherIds, ',')
	OPTION (MAXRECURSION 0)
	
	DECLARE @MessageTemplate NVARCHAR(2000) = ''
		,@MessageType INT
		,@BettypeName NVARCHAR(50) = '' 
	
	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageType = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'EditMatchRecommendOdds'
	
	SELECT @BettypeName = ShortName
		FROM dbo.MajorBettype WITH (NOLOCK)
		WHERE BettypeId = @Bettype

	SET @MessageTemplate = dbo.[fnc_ReplaceMessageTemplate](@MessageTemplate, @OWPMatchId, @ActorId)
	SET @MessageTemplate = REPLACE(@MessageTemplate, '<Bettype>', @BettypeName)
	
	EXECUTE dbo.OWP_MessageInsert @UserId = @ActorId
		,@MessageContent = @MessageTemplate
		,@MessageType = @MessageType
		,@MessageTo = @tblAssignee
		,@IsImportant = 0
		,@IsWatcher = 0
		,@SessionId = @SessionId

	EXECUTE dbo.OWP_MessageInsert @UserId = @ActorId
		,@MessageContent = @MessageTemplate
		,@MessageType = @MessageType
		,@MessageTo = @tblWatcher
		,@IsImportant = 0
		,@IsWatcher = 1
		,@SessionId = @SessionId
END