/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OWPMatch_UpdateFromInfoSite] @UserId INT
	,@InfoSiteMatchKey NVARCHAR(400)
	,@InfoSiteMergeMatchKey NVARCHAR(400)
	,@MatchId INT
	,@EventDate DATETIME
	,@KickOffTime TIME
	,@LeagueName NVARCHAR(2000)
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@WatchBet NVARCHAR(100)
	,@Round NVARCHAR(100)
	,@OutSide NVARCHAR(100)
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
Task: Update or update match from info site.
DB: bodb_OWP
Original: 

Revisions: 
20180417@Jacob.Phan: Feature #92487 - Move Event Picking to test DB.  
20180423@Jacob.Phan: Feature #93888 - Apply new API from InfoSite   
20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
20180927@Leo: New structure of event assignment - [Redmine: #92868]

Param's Explanation:
â€¢ @ErrCode:
	= 0: Transaction recorded successfully.
	> 0: Specific Error.
â€¢ @ErrMsg: Error description.

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
		,@LogMatchDataOld NVARCHAR(MAX)
		,@Xml XML
		,@OldInfoSiteMatchKey NVARCHAR(400)
		,@OldMatchId INT
		,@OldEventDate DATETIME
		,@OldKickOffTime TIME
		,@OldLeagueName NVARCHAR(2000)
		,@OldHomeName NVARCHAR(200)
		,@OldAwayName NVARCHAR(200)
		,@OldWatchBet NVARCHAR(100)
		,@OldRound NVARCHAR(2000)
		,@OldOutSide NVARCHAR(2000)
		,@OldAgent NVARCHAR(100)
		,@OldExtraTimeRemark NVARCHAR(100)
		,@OldVenue NVARCHAR(100)
		,@OldLocalTV NVARCHAR(100)
		,@OldLiveTV NVARCHAR(100)
		,@OldWebsite NVARCHAR(100)
		,@OldProvider NVARCHAR(100)
		,@OldOWPLeagueId INT
		,@OldOWPHomeId INT
		,@OldOWPAwayId INT
		,@IsChangeOWPMatch BIT
		,@IsChangeMatchInfo BIT
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

	SELECT @OWPMatchId = 0
		,@IsChangeOWPMatch = 0
		,@IsChangeMatchInfo = 0

	SELECT @OWPMatchId = OWPMatchId
		,@OldEventDate = @EventDate
		,@OldKickOffTime = KickOffTime
		,@OldLeagueName = lg.OWPLeagueName
		,@OldHomeName = ht.OWPTeamName
		,@OldAwayName = at.OWPTeamName
		,@OldMatchId = MatchId
		,@OldInfoSiteMatchKey = ma.InfoSiteMatchKey
		,@OldOWPLeagueId = lg.OWPLeagueId
		,@OldOWPHomeId = ht.OWPTeamId
		,@OldOWPAwayId = at.OWPTeamId
	FROM dbo.OWPMatch AS ma WITH (NOLOCK)
		INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ma.OWPHomeId = ht.OWPTeamId
		INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ma.OWPAwayId = at.OWPTeamId
		INNER JOIN dbo.OWPLeague AS lg WITH (NOLOCK) ON ma.OWPLeagueId = lg.OWPLeagueId
	WHERE InfoSiteMatchKey = @InfoSiteMatchKey OR CHARINDEX(InfoSiteMatchKey, @InfoSiteMergeMatchKey) > 0

	IF (ISNULL(@OWPMatchId,0) = 0)
	BEGIN
		SELECT @OWPMatchId = OWPMatchId
			,@OldEventDate = @EventDate
			,@OldKickOffTime = KickOffTime
			,@OldLeagueName = lg.OWPLeagueName
			,@OldHomeName = ht.OWPTeamName
			,@OldAwayName = at.OWPTeamName
			,@OldMatchId = MatchId
			,@OldInfoSiteMatchKey = ma.InfoSiteMatchKey
			,@OldOWPLeagueId = lg.OWPLeagueId
			,@OldOWPHomeId = ht.OWPTeamId
			,@OldOWPAwayId = at.OWPTeamId
		FROM dbo.OWPMatch AS ma WITH (NOLOCK)
			INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ma.OWPHomeId = ht.OWPTeamId
			INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ma.OWPAwayId = at.OWPTeamId
			INNER JOIN dbo.OWPLeague AS lg WITH (NOLOCK) ON ma.OWPLeagueId = lg.OWPLeagueId
		WHERE EventDate = @EventDate
			AND ma.OWPLeagueId = @OWPLeagueId
			AND OWPHomeId = @OWPHomeId
			AND OWPAwayId = @OWPAwayId
	END

	SELECT @OldWatchBet = ISNULL(WB, '')
		,@OldRound = ISNULL(Round, '')
		,@OldOutSide = ISNULL(Division, '')
		,@OldAgent = ISNULL(Agent, '')
		,@OldExtraTimeRemark = ISNULL(ExtraTimeRemark, '')
		,@OldVenue = ISNULL(Venue, '')
		,@OldLocalTV = ISNULL(LocalTV, '')
		,@OldLiveTV = ISNULL(LiveTV, '')
		,@OldWebsite = ISNULL(Website1, '')
		,@OldProvider = ISNULL(Provider, '')
	FROM dbo.MatchInfo WITH (NOLOCK)
	WHERE [OWPMatchId] = @OWPMatchId

	BEGIN TRY
		-- Update OWPMatch 
		IF (
				@OldEventDate <> @EventDate
				OR @OldKickOffTime <> @KickOffTime
				OR @OldLeagueName <> @LeagueName
				OR @OldHomeName <> @HomeName
				OR @OldAwayName <> @AwayName
				OR ISNULL(@OldMatchId, 0) <> ISNULL(@MatchId, 0)
				OR @OldInfoSiteMatchKey <> @InfoSiteMatchKey
				)
		BEGIN
			UPDATE dbo.OWPMatch WITH (UPDLOCK, ROWLOCK)
			SET EventDate = @EventDate
				,KickOffTime = @KickOffTime
				,OWPLeagueId = @OWPLeagueId
				,OWPHomeId = @OWPHomeId
				,OWPAwayId = @OWPAwayId
				,MatchId = @MatchId
				,InfoSiteMatchKey = @InfoSiteMatchKey
			WHERE [OWPMatchId] = @OWPMatchId

			SET @IsChangeOWPMatch = 1
		END

		EXEC OWP_ResourceIdGetByName @ResourceType = 'Agent'
			,@ResourceValues = @Agent
			,@ResourceIds = @AgentIds OUTPUT

		EXEC OWP_ResourceIdGetByName @ResourceType = 'Provider'
			,@ResourceValues = @Provider
			,@ResourceIds = @ProviderIds OUTPUT

		--- Update MatchInfo          
		IF @OldWatchBet <> @WatchBet
			OR @OldRound <> @Round
			OR @OldOutSide <> @OutSide
			OR @OldAgent <> @AgentIds
			OR @OldExtraTimeRemark <> @ExtraTimeRemark
			OR @OldVenue <> @Venue
			OR @OldLocalTV <> @LocalTV
			OR @OldLiveTV <> @LiveTV
			OR @OldWebsite <> @Website
			OR @OldProvider <> @ProviderIds
		BEGIN
			UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
			SET [WB] = @WatchBet
				,[Provider] = @ProviderIds
				,[Round] = @Round
				,[Division] = @OutSide
				,[ExtraTimeRemark] = @ExtraTimeRemark
				,[Venue] = @Venue
				,[LocalTV] = @LocalTV
				,[LiveTV] = @LiveTV
				,[Website1] = @Website
				,[Agent] = @AgentIds
			WHERE [OWPMatchId] = @OWPMatchId

			SET @IsChangeMatchInfo = 1
		END

		-- Note          
		INSERT INTO dbo.MatchNote (
			OWPMatchId
			,CreatedDate
			,CreatedBy
			,Note
			)
		SELECT @OWPMatchId
			,GETDATE()
			,@UserId
			,ISNULL(val,'')
		FROM dbo.strSplit(@Note, '@#')
		WHERE NOT EXISTS (
				SELECT 1
				FROM dbo.MatchNote WITH (NOLOCK)
				WHERE val = Note
					AND OWPMatchId = @OWPMatchId
					AND CreatedBy = @UserId
				)

		--- Write Log
		IF (
				@IsChangeOWPMatch = 1
				OR @IsChangeMatchInfo = 1
				)
		BEGIN
			SET @Xml = (
					SELECT @OldInfoSiteMatchKey AS '@iid'
						,'' AS '@miid'
						,@OldMatchId AS '@mid'						
						,@OldEventDate AS '@ed'
						,@OldKickOffTime AS '@ko'
						,@OldLeagueName AS '@ln'
						,@OldHomeName AS '@hn'
						,@OldAwayName AS '@an'
						,@OldWatchBet AS '@wb'
						,@OldRound AS '@rd'
						,@OldOutSide AS '@os'
						,@OldAgent AS '@ag'
						,@OldExtraTimeRemark AS '@et'
						,@OldVenue AS '@vn'
						,@OldLocalTV AS '@lo'
						,@OldLiveTV AS '@li'
						,@OldWebsite AS '@ws'
						,'' AS '@nt'
						,@OldProvider AS '@pv'
					FOR XML PATH('z')
						,ROOT('r')
					)
			SET @LogMatchDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
			SET @Xml = (
					SELECT @InfoSiteMatchKey AS '@iid'
					    ,@InfoSiteMergeMatchKey AS '@miid'
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
				,@SPName = 'OWP_OWPMatch_UpdateFromInfoSite'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = @OWPMatchId
				,@Data = @LogMatchData
				,@DataOld = @LogMatchDataOld
		END
	END TRY

	BEGIN CATCH
		IF (@IsChangeOWPMatch = 1)
		BEGIN
			UPDATE dbo.OWPMatch WITH (UPDLOCK, ROWLOCK)
			SET EventDate = @OldEventDate
				,KickOffTime = @OldKickOffTime
				,OWPLeagueId = @OldOWPLeagueId
				,OWPHomeId = @OldOWPHomeId
				,OWPAwayId = @OldOWPAwayId
				,MatchId = @OldMatchId
				,InfoSiteMatchKey = @OldInfoSiteMatchKey
			WHERE [OWPMatchId] = @OWPMatchId
		END

		IF (@IsChangeMatchInfo = 1)
		BEGIN
			UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
			SET [WB] = @OldWatchBet
				,[Provider] = @OldProvider
				,[Round] = @OldRound
				,[Division] = @OldOutSide
				,[ExtraTimeRemark] = @OldExtraTimeRemark
				,[Venue] = @OldVenue
				,[LocalTV] = @OldLocalTV
				,[LiveTV] = @OldLiveTV
				,[Website1] = @OldWebsite
				,[Agent] = @OldAgent
			WHERE [OWPMatchId] = @OWPMatchId
		END



		SELECT @ErrMsg = 'Update match failed. Please try again.'
		+  '.ERROR_PROCEDURE:'+  CONVERT(VARCHAR(100), ERROR_PROCEDURE())
		+  '.ERROR_LINE:'+  CONVERT(VARCHAR(100), ERROR_LINE())
		+  '.ERROR_MESSAGE:'+ ERROR_MESSAGE()
			,@ErrCode = 201

		RETURN
	END CATCH
END