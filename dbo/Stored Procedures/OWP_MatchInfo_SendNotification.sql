/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MatchInfo_SendNotification] @ActorId INT
	,@OWPMatchId INT
	,@OldValue NVARCHAR(2000) = ''
	,@NewValue NVARCHAR(2000) = ''
	,@TemplateCode NVARCHAR(50)
	,@SessionId VARCHAR(50)
	,@AssigneeIds VARCHAR(MAX)
	,@WatcherIds VARCHAR(MAX)
AS
/*          
 Created: 20191106@Leo.Vo
 Task : Send notification
 DB: bodb_OWP          
          
 Revisions:
	20191106@Leo.Vo: Init SP - [Redmine: #116230]
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
		,@ActorName NVARCHAR(30)
		,@MatchNo VARCHAR(50)
		,@League VARCHAR(50)
		,@HomeTeamName NVARCHAR(200)
		,@AwayTeamName NVARCHAR(200)
	
	SELECT @MessageTemplate = mt.MsgTemplateContent
		,@MessageType = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = @TemplateCode
	
	SELECT @ActorName = dbo.[fnc_GetUsernameByUserId](@ActorId)
	
	SELECT @HomeTeamName = home.OWPTeamName
		,@AwayTeamName = away.OWPTeamName
		,@MatchNo = CASE 
			WHEN om.MatchNo = ''
				THEN ''
			ELSE '#' + om.MatchNo
			END
		,@League = ol.OWPLeagueName
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
	LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
	LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId
	LEFT JOIN dbo.OWPLeague AS ol WITH (NOLOCK) ON om.OWPLeagueId = ol.OWPLeagueId
	WHERE om.OWPMatchId = @OWPMatchId
	
	SELECT @MessageTemplate = 
	REPLACE(
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(@MessageTemplate,
						'<User>', @ActorName)
					,'<Match.No>', @MatchNo)
				,'<League>', @League)
			,'<Event>', @HomeTeamName + ' -vs- ' + @AwayTeamName)
		,'<Old>', @OldValue)
	,'<New>', @NewValue)
	
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