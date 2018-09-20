/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EventInsertFromInfoSite] @UserId INT = 0
	,@EventInfo NVARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
	,@DuplicateMatch NVARCHAR(MAX) = '' OUTPUT
AS
/*
 Created: 20161208@Quinn.Vo
 Task : Insert events from info site
 DB: bodb_OWP

 Revisions: 
    20180423@Jacob.Phan: Feature #93888 - Apply new API from InfoSite  
    -- @Note:    
    EXEC OWP_EventInsertFromInfoSite @UserId=8,@EventInfo=N'<Root>  
    <Row RowNum="1" EventDate="10/2/2016" .... Note="Away no Website" />  
    </Root>'
    20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RowNum INT
		,@InfoSiteMatchKey NVARCHAR(400)
		,@InfoSiteMergeMatchKey NVARCHAR(400)
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
		,@UpdatedTime DATETIME

	IF OBJECT_ID('tempdb..#tblEvents') IS NOT NULL 
	BEGIN 
		DROP TABLE #tblEvents
	END


	CREATE TABLE #tblEvents (
		RowIndex INT IDENTITY(1, 1)
		,RowNum INT
		,InfoSiteMatchKey NVARCHAR(400)
		,InfoSiteMergeMatchKey NVARCHAR(400)
		,MatchId INT
		,EventDate DATETIME
		,KickOffTime TIME
		,LeagueName NVARCHAR(2000)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,WatchBet NVARCHAR(100)
		,[Round] NVARCHAR(2000)
		,OutSide NVARCHAR(2000)
		,Agent NVARCHAR(100)
		,ExtraTimeRemark NVARCHAR(100)
		,Venue NVARCHAR(100)
		,LocalTV NVARCHAR(100)
		,LiveTV NVARCHAR(100)
		,Website NVARCHAR(100)
		,Note NVARCHAR(MAX)
		,Provider NVARCHAR(100)
		,UpdatedTime DATETIME
		)

	DECLARE @DocHandler INT

	EXEC sp_xml_preparedocument @DocHandler OUTPUT
		,@EventInfo

	INSERT INTO #tblEvents (
		RowNum
		,InfoSiteMatchKey
		,InfoSiteMergeMatchKey
		,MatchId
		,EventDate
		,KickOffTime
		,LeagueName
		,HomeName
		,AwayName
		,WatchBet
		,[Round]
		,OutSide
		,Agent
		,ExtraTimeRemark
		,Venue
		,LocalTV
		,LiveTV
		,Website
		,Note
		,Provider
		,UpdatedTime
		)
	SELECT Data.RowNum
		,Data.InfoSiteMatchKey
		,Data.InfoSiteMergeMatchKey
		,Data.MatchId
		,Data.EventDate
		,Data.KickOffTime
		,Data.LeagueName
		,Data.HomeName
		,Data.AwayName
		,Data.WatchBet
		,Data.[Round]
		,Data.OutSide
		,Data.Agent
		,Data.ExtraTimeRemark
		,Data.Venue
		,Data.LocalTV
		,Data.LiveTV
		,Data.Website
		,Data.Note
		,Data.Provider
		,Data.UpdatedTime
	FROM OPENXML(@DocHandler, '/Root/Row', 1) WITH (RowNum INT, InfoSiteMatchKey NVARCHAR(400), InfoSiteMergeMatchKey NVARCHAR(400), MatchId INT, EventDate DATETIME, KickOffTime TIME, LeagueName NVARCHAR(2000), HomeName NVARCHAR(200), AwayName NVARCHAR(200), WatchBet NVARCHAR(100), [Round] NVARCHAR(2000), OutSide NVARCHAR(2000), Agent NVARCHAR(100), ExtraTimeRemark NVARCHAR(100), Venue NVARCHAR(100), LocalTV NVARCHAR(100), LiveTV NVARCHAR(100), Website NVARCHAR(100), Note NVARCHAR(MAX), Provider NVARCHAR(100), UpdatedTime DATETIME) AS Data

	EXEC sp_xml_removedocument @DocHandler

	DECLARE @TotalRow INT
		,@rowIndex INT
		,@DuplicateCount INT

	SELECT @TotalRow = COUNT(1)
	FROM #tblEvents

	SET @rowIndex = 1

	WHILE @rowIndex <= @TotalRow
	BEGIN
		SELECT @RowNum = RowNum
			,@InfoSiteMatchKey = InfoSiteMatchKey
			,@InfoSiteMergeMatchKey = InfoSiteMergeMatchKey
			,@MatchId = CASE 
				WHEN MatchId = 0 THEN NULL
				ELSE MatchId
				END
			,@EventDate = EventDate
			,@KickOffTime = KickOffTime
			,@LeagueName = LeagueName
			,@HomeName = HomeName
			,@AwayName = AwayName
			,@WatchBet = WatchBet
			,@Round = [Round]
			,@OutSide = OutSide
			,@Agent = Agent
			,@ExtraTimeRemark = ExtraTimeRemark
			,@Venue = Venue
			,@LocalTV = LocalTV
			,@LiveTV = LiveTV
			,@Website = Website
			,@Note = Note
			,@Provider = Provider
			,@ErrCode = 0
			,@ErrMsg = ''
		FROM #tblEvents
		WHERE RowIndex = @rowIndex

		SELECT @DuplicateCount = COUNT(1) 
		FROM dbo.OWPMatch WITH (NOLOCK)
		WHERE InfoSiteMatchKey = @InfoSiteMatchKey OR CHARINDEX(InfoSiteMatchKey, @InfoSiteMergeMatchKey) > 0

		IF @DuplicateCount > 1
		BEGIN
			SET @DuplicateMatch = @DuplicateMatch + '-' + @InfoSiteMatchKey + ';' + @InfoSiteMergeMatchKey + ':' + CONVERT(NVARCHAR(20), @DuplicateCount)  
		END;

		IF (
				EXISTS (
					SELECT 1
					FROM dbo.OWPMatch WITH (NOLOCK)
					WHERE InfoSiteMatchKey = @InfoSiteMatchKey OR CHARINDEX(InfoSiteMatchKey, @InfoSiteMergeMatchKey) > 0
					)
				OR EXISTS (
					SELECT 1
					FROM dbo.OWPMatch AS ma WITH (NOLOCK)
						INNER JOIN dbo.OWPTeam AS ht WITH (NOLOCK) ON ma.OWPHomeId = ht.OWPTeamId
						INNER JOIN dbo.OWPTeam AS at WITH (NOLOCK) ON ma.OWPAwayId = at.OWPTeamId
						INNER JOIN dbo.OWPLeague AS lg WITH (NOLOCK) ON ma.OWPLeagueId = lg.OWPLeagueId
					WHERE ma.EventDate = @EventDate
						AND lg.OWPLeagueName = @LeagueName
						AND ht.OWPTeamName = @HomeName
						AND at.OWPTeamName = @AwayName
					)
				)
		BEGIN
			EXEC [dbo].[OWP_OWPMatch_UpdateFromInfoSite] @UserId = @UserId
				,@InfoSiteMatchKey = @InfoSiteMatchKey
				,@InfoSiteMergeMatchKey = @InfoSiteMergeMatchKey
				,@MatchId = @MatchId
				,@EventDate = @EventDate
				,@KickOffTime = @KickOffTime
				,@LeagueName = @LeagueName
				,@HomeName = @HomeName
				,@AwayName = @AwayName
				,@WatchBet = @WatchBet
				,@Round = @Round
				,@OutSide = @OutSide
				,@Agent = @Agent
				,@ExtraTimeRemark = @ExtraTimeRemark
				,@Venue = @Venue
				,@LocalTV = @LocalTV
				,@LiveTV = @LiveTV
				,@Website = @Website
				,@Note = @Note
				,@Provider = @Provider
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT
		END
		ELSE
		BEGIN
			EXEC [dbo].[OWP_OWPMatch_InsertFromInfoSite] @UserId = @UserId
				,@InfoSiteMatchKey = @InfoSiteMatchKey
				,@MatchId = @MatchId
				,@EventDate = @EventDate
				,@KickOffTime = @KickOffTime
				,@LeagueName = @LeagueName
				,@HomeName = @HomeName
				,@AwayName = @AwayName
				,@WatchBet = @WatchBet
				,@Round = @Round
				,@OutSide = @OutSide
				,@Agent = @Agent
				,@ExtraTimeRemark = @ExtraTimeRemark
				,@Venue = @Venue
				,@LocalTV = @LocalTV
				,@LiveTV = @LiveTV
				,@Website = @Website
				,@Note = @Note
				,@Provider = @Provider
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT
		END

		IF @ErrCode <> 0 
		BEGIN
			BREAK
		END
		SET @rowIndex = @rowIndex + 1
	END

	SELECT @UpdatedTime = MAX(UpdatedTime)
	FROM #tblEvents

	IF(@UpdatedTime IS NOT NULL AND @ErrCode = 0)
	BEGIN
		UPDATE dbo.RefResource WITH (ROWLOCK, UPDLOCK)
		SET [Value] = CONVERT(NVARCHAR(30), @UpdatedTime, 9)
		WHERE [RefName] = 'LastModifiedDateEvents'
	END

	IF OBJECT_ID('tempdb..#tblEvents') IS NOT NULL 
	BEGIN 
		DROP TABLE #tblEvents
	END
END