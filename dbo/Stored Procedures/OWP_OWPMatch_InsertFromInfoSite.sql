/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OWPMatch_InsertFromInfoSite] @UserId INT
	,@InfoSiteMatchKey NVARCHAR(400)
	,@MatchId INT
	,@EventDate DATETIME
	,@KickOffTime TIME
	,@LeagueName NVARCHAR(2000)
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@WatchBet NVARCHAR(100)
	,@Round NVARCHAR(2000)
	,@OutSide NVARCHAR(2000)
	,@Agent NVARCHAR(100)
	,@ExtraTimeRemark NVARCHAR(100)
	,@Venue NVARCHAR(100)
	,@LocalTV NVARCHAR(100)
	,@LiveTV NVARCHAR(100)
	,@Website NVARCHAR(100)
	,@Note NVARCHAR(MAX)
	,@Provider NVARCHAR(100)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/* 
Created: 20161209@Quinn.Vo
Task: Insert or update match from info site.
DB: bodb_OWP
Original: 

Revisions:  
    20180417@Jacob.Phan: Feature #92487 - Move Event Picking to test DB. 
    20180423@Jacob.Phan: Feature #93888 - Apply new API from InfoSite  
    Param's Explanation:
    • @ErrCode:
        = 0: Transaction recorded successfully.
        > 0: Specific Error.
    • @ErrMsg: Error description.
    20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)

*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OWPMatchId INT
		,@OWPLeagueId INT
		,@OWPHomeId INT
		,@OWPAwayId INT
		,@StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogMatchData NVARCHAR(MAX)
		,@Xml XML
		,@AgentIds NVARCHAR(200) = ''
		,@ProviderIds NVARCHAR(200) = ''

	SET @StartRun = GETDATE()

	-- Home          
	EXEC [dbo].[OWP_OWPTeamInsert] @UserId = @UserId
		,@OWPTeamName = @HomeName
		,@TeamId = @OWPHomeId OUTPUT

	IF @ErrCode = 702 -- Do not check 701            
	BEGIN
		RETURN
	END

	-- Away            
	EXEC [dbo].[OWP_OWPTeamInsert] @UserId = @UserId
		,@OWPTeamName = @AwayName
		,@TeamId = @OWPAwayId OUTPUT

	IF @ErrCode = 702 -- Do not check 701            
	BEGIN
		RETURN
	END

	---Insert OWPLeague            
	EXEC [dbo].[OWP_OWPLeagueInsert] @UserId = @UserId
		,@OWPLeagueName = @LeagueName
		,@LeagueId = @OWPLeagueId OUTPUT

	IF @ErrCode = 402 -- Do not check 401            
	BEGIN
		RETURN
	END

	BEGIN TRY
		INSERT INTO dbo.OWPMatch (
			EventDate
			,KickOffTime
			,OWPLeagueId
			,OWPHomeId
			,OWPAwayId
			,MatchId
			,InfoSiteMatchKey		
			)
		VALUES (
			@EventDate
			,@KickOffTime
			,@OWPLeagueId
			,@OWPHomeId
			,@OWPAwayId
			,@MatchId
			,@InfoSiteMatchKey
			)

		SELECT @OWPMatchId = SCOPE_IDENTITY()

		---Insert MatchNote
		EXEC [dbo].[OWP_MatchNoteInsert] @UserId = @UserId
			,@OWPMatchId = @OWPMatchId
			,@Note = @Note

		EXEC OWP_ResourceIdGetByName @ResourceType = 'Agent'
			,@ResourceValues = @Agent
			,@ResourceIds = @AgentIds OUTPUT

		EXEC OWP_ResourceIdGetByName @ResourceType = 'Provider'
			,@ResourceValues = @Provider
			,@ResourceIds = @ProviderIds OUTPUT

		INSERT INTO dbo.MatchInfo (
			[OWPMatchId]
			,[TVCode]
			,[Channel]
			,[WatchBet]
			,[Provider]
			,[Runner]
			,[Phone]
			,[KOTimeRemark]
			,[IsSelected]
			,[SelectedBy]
			,[IsCancelled]
			,[Round]
			,[IsSoloMatch]
			,[OutSide]
			,[ExtraTimeRemark]
			,[Venue]
			,[LocalTV]
			,[LiveTV]
			,[Website]
			,[Agent]
			,[MatchStatus]
			)
		VALUES (
			@OWPMatchId
			,''
			,''
			,@WatchBet
			,@ProviderIds
			,''
			,''
			,''
			,0
			,NULL
			,0
			,@Round
			,0
			,@OutSide
			,@ExtraTimeRemark
			,@Venue
			,@LocalTV
			,@LiveTV
			,@Website
			,@AgentIds
			,'Live'			
			)

		--- Write Log          
		SET @Xml = (
				SELECT @InfoSiteMatchKey AS '@iid'
					,'' AS '@miid'
					,@MatchId AS '@mid'
					,@EventDate AS '@ed'
					,@KickOffTime AS '@ko'
					,@LeagueName AS '@ln'
					,@HomeName AS '@hn'
					,@AwayName AS '@an'
					,@WatchBet AS '@wb'
					,@Round AS '@rd'
					,@OutSide AS '@os'
					,@AgentIds AS '@ag'
					,@ExtraTimeRemark AS '@et'
					,@Venue AS '@vn'
					,@LocalTV AS '@lo'
					,@LiveTV AS '@li'
					,@Website AS '@ws'
					,@Note AS '@nt'
					,@ProviderIds AS '@pv'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogMatchData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_OWPMatch_InsertFromInfoSite'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @LogMatchData
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		DELETE dbo.OWPMatch WITH (ROWLOCK)
		WHERE OWPMatchId = @OWPMatchId

		DELETE dbo.MatchInfo WITH (ROWLOCK)
		WHERE OWPMatchId = @OWPMatchId

		DELETE dbo.MatchNote WITH (ROWLOCK)
		WHERE OWPMatchId = @OWPMatchId

	SELECT @ErrMsg = 'Update match failed. Please try again.'
		+  '.ERROR_PROCEDURE:'+  CONVERT(VARCHAR(100), ERROR_PROCEDURE())
		+  '.ERROR_LINE:'+  CONVERT(VARCHAR(100), ERROR_LINE())
		+  '.ERROR_MESSAGE:'+ ERROR_MESSAGE()
			,@ErrCode = 101

		RETURN
	END CATCH
END