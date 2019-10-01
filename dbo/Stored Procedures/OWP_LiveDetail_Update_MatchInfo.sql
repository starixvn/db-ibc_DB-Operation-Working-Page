
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_MatchInfo] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@Remark NVARCHAR(2000) = ''
	,@InfoSiteMatchId INT = NULL
	,@Round NVARCHAR(2000) = ''
	,@IsUpdateRound BIT = 0
	,@Division NVARCHAR(2000) = ''
	,@IsUpdateDivision BIT = 0
	,@Venue NVARCHAR(100) = ''
	,@IsUpdateVenue BIT = 0
	,@OtherTime DATETIME = NULL
	,@IsUpdateOtherTime BIT = 0
	,@MarketIds NVARCHAR(100) = ''
	,@IsUpdateMarkets BIT = 0
	,@Website1 NVARCHAR(1000) = ''
	,@IsUpdateWebsite1 BIT = 0
	,@Website2 NVARCHAR(1000) = ''
	,@IsUpdateWebsite2 BIT = 0
	,@Website3 NVARCHAR(1000) = ''
	,@IsUpdateWebsite3 BIT = 0
	,@Website4 NVARCHAR(1000) = ''
	,@IsUpdateWebsite4 BIT = 0
	,@MatchStatus NVARCHAR(15)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20190820@Tyler.Dang
Task : Update MatchInfo section Edit Event  
DB: bodb_OWP

Revisions:
	20190820@Tyler.Dang: InitialSP - [Redmine: #118566]
	20190919@Tyler.Dang: Update relevant matchs - [Redmine: #120496]
*/
BEGIN
	SET NOCOUNT ON

	SELECT @ErrMsg = 'The event has been edited successfully!'
		,@ErrCode = 0

	DECLARE @EventDateTime DATETIME
		
	SELECT @EventDateTime = EventDateTime
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	WHERE m.OWPMatchId = @OWPMatchId
		
	-- checking InfoSiteId duplicated
	IF @InfoSiteMatchId IS NOT NULL
	BEGIN
		DECLARE @FromDateTime DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDateTime), '12:00:00')
			,@ToDateTime DATETIME = DATEADD(DAY, DATEDIFF(DAY, 1, @EventDateTime), '11:59:59')
			
		IF EXISTS (
			SELECT 1
			FROM dbo.OWPMatch AS m WITH (NOLOCK)
			WHERE m.InfoSiteMatchId = @InfoSiteMatchId
				AND m.EventDateTime BETWEEN @FromDateTime AND @ToDateTime
				AND m.OWPMatchId <> @OWPMatchId
			)
		BEGIN
			SELECT @ErrCode = 2
				,@ErrMsg = 'InfoSiteID is duplicating.'

			RETURN
		END
	END
	
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML
		,@OldRemark NVARCHAR(2000)
		,@OldIsSoloMatch BIT
		,@OldRound NVARCHAR(2000)
		,@OldDivision NVARCHAR(2000)
		,@OldVenue NVARCHAR(100)
		,@OldOtherTime TIME
		,@OldInfoSiteMatchId INT
		,@OldMarketIds NVARCHAR(100)
		,@OldWebsite1 NVARCHAR(1000)
		,@OldWebsite2 NVARCHAR(1000)
		,@OldWebsite3 NVARCHAR(1000)
		,@OldWebsite4 NVARCHAR(1000)
		,@OldMatchStatus NVARCHAR(15)
		
	-- Log 
	-- save old value
	SELECT @OldMarketIds = ISNULL(STUFF((
			SELECT ', ' + CAST(MarketId AS NVARCHAR)
			FROM dbo.MatchMarket WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
			FOR XML PATH('')
			), 1, 2, ''), '')

	SELECT @OldRemark = m.Remark
		,@OldIsSoloMatch = m.IsSoloMatch
		,@OldRound = m.[Round]
		,@OldDivision = m.Division
		,@OldVenue = m.Venue
		,@OldOtherTime = om.OtherTime
		,@OldWebsite1 = m.Website1
		,@OldWebsite2 = m.Website2
		,@OldWebsite3 = m.Website3
		,@OldWebsite4 = m.Website4
		,@OldInfoSiteMatchId = om.InfoSiteMatchId
		,@OldMatchStatus = m.MatchStatus
	FROM dbo.MatchInfo m WITH (NOLOCK)
	LEFT JOIN dbo.OWPMatch om WITH (NOLOCK) ON om.OWPMatchId = m.OWPMatchId
	WHERE m.OWPMatchId = @OWPMatchId

	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT @OldRemark AS '@rm'
				,@OldIsSoloMatch AS '@sl'
				,@OldRound AS '@rd'
				,@OldDivision AS '@ds'
				,@OldVenue AS '@vn'
				,@OldOtherTime AS '@ot'
				,@OldWebsite1 AS '@ws1'
				,@OldWebsite2 AS '@ws2'
				,@OldWebsite3 AS '@ws3'
				,@OldWebsite4 AS '@ws4'
				,@OldInfoSiteMatchId AS '@ifi'
				,@OldMarketIds AS '@mk'
				,@OldMatchStatus AS '@ms'
			FROM dbo.MatchInfo AS info
			WHERE info.OWPMatchId = @OWPMatchId
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	
	DECLARE @FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@ParentMatchId INT
		,@MinorBettypeId INT
		
	SELECT @ParentMatchId = ParentMatchId
		,@MinorBettypeId = MinorBettypeId
	FROM dbo.MinorMatch WITH (NOLOCK)
	WHERE MinorMatchId = @OWPMatchId
	
	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
		,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()
	
	CREATE TABLE #tblRelevantMatches(
		Id INT IDENTITY(1,1)
		,OWPMatchId INT
		,MinorBettypeId INT
		,IsMatchInTimeRange BIT)
	
	DECLARE @MinorBettype_FastMarket INT = - 88
		,@MinorBettype_AllInOne INT = - 89
		,@MinorBettype_Specific15Mins INT = - 1
		,@MinorBettype_Specific10Mins INT = - 2
		,@MinorBettype_Specific15MinsNoOfCorners INT = - 5
		,@MinorBettype_Specific15MinsTotalBooking INT = - 8
		
	-- add relevant matches to update status
	IF @ParentMatchId IS NULL
	BEGIN
		INSERT INTO #tblRelevantMatches (
			OWPMatchId
			,MinorBettypeId
		)
		SELECT MinorMatchId
			,MinorBettypeId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId AND MinorBettypeId NOT IN (@MinorBettype_FastMarket
			,@MinorBettype_AllInOne
			,@MinorBettype_Specific10Mins
			,@MinorBettype_Specific15Mins
			,@MinorBettype_Specific15MinsNoOfCorners
			,@MinorBettype_Specific15MinsTotalBooking)
			
		INSERT INTO #tblRelevantMatches (OWPMatchId)
		VALUES (@OWPMatchId)
	END
	ELSE
	BEGIN
		INSERT INTO #tblRelevantMatches (
			OWPMatchId
			,MinorBettypeId
		)
		VALUES (@OWPMatchId, @MinorBettypeId)
	END
	
	-- list of minor bettypes Corner & Booking but not 15 mins
	CREATE TABLE #tblCornerBookingBetTypes (MinorBettypeId INT NOT NULL)

	INSERT INTO #tblCornerBookingBetTypes
	SELECT MinorBettypeId
	FROM dbo.MinorBettype WITH (NOLOCK)
	WHERE ParentBetTypeId IS NULL
		AND IsActive = 1
		AND MinorBettypeName NOT LIKE '%15 mins%'
		AND (
			MinorBettypeName LIKE '%corner%'
			OR MinorBettypeName LIKE '%booking%'
			)
	
	DECLARE @Id INT
		,@RelevantMatchId INT
		,@RelevantMinorBettypeId INT
		,@IsMatchInTimeRange BIT
	SET @Id = 1
	WHILE 1=1
	BEGIN
		SELECT @RelevantMatchId = NULL
			,@RelevantMinorBettypeId = NULL
			
		SELECT @RelevantMatchId = OWPMatchId
			,@RelevantMinorBettypeId = MinorBettypeId
		FROM #tblRelevantMatches
		WHERE Id = @Id
		
		IF @RelevantMatchId IS NULL BREAK
		
		SET @IsMatchInTimeRange = CASE WHEN (@EventDateTime >= @FromTimeSendMessage AND @EventDateTime <= @ToTimeSendMessage)
			OR ( @RelevantMinorBettypeId IS NOT NULL AND EXISTS (
				SELECT 1
				FROM #tblCornerBookingBetTypes
				WHERE MinorBettypeId = @RelevantMinorBettypeId
					AND @EventDateTime >= @FromTimeSendMessageSpecialBettype
					AND @EventDateTime <= @ToTimeSendMessageSpecialBettype
				)
			) THEN 1 ELSE 0 END
			
		UPDATE #tblRelevantMatches
		SET IsMatchInTimeRange = @IsMatchInTimeRange
		WHERE Id = @Id
		
		IF @OWPMatchId = @RelevantMatchId OR @MatchStatus <> 'Live'
		BEGIN
			EXEC dbo.OWP_LiveDetail_Update_MatchInfo_MatchStatus @ActorId = @ActorId
				,@SessionId = @SessionId
				,@OWPMatchId = @RelevantMatchId
				,@ParentMatchId = @ParentMatchId
				,@MinorBettypeId = @RelevantMinorBettypeId
				,@MatchStatus = @MatchStatus
				,@IsMatchInTimeRange = @IsMatchInTimeRange
		END
		
		SET @Id = @Id + 1
	END
	
	-- add more relevant matches
	IF @ParentMatchId IS NOT NULL
	BEGIN
		INSERT INTO #tblRelevantMatches (
			OWPMatchId
			,MinorBettypeId
		)
		SELECT MinorMatchId
			,MinorBettypeId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @ParentMatchId AND MinorMatchId <> @OWPMatchId AND MinorBettypeId NOT IN (@MinorBettype_FastMarket
			,@MinorBettype_AllInOne
			,@MinorBettype_Specific10Mins
			,@MinorBettype_Specific15Mins
			,@MinorBettype_Specific15MinsNoOfCorners
			,@MinorBettype_Specific15MinsTotalBooking)
	END
	
	SET @Id = 1
	WHILE 1=1
	BEGIN
		SELECT @RelevantMatchId = NULL
			,@RelevantMinorBettypeId = NULL
			,@IsMatchInTimeRange = NULL
			
		SELECT @RelevantMatchId = OWPMatchId
			,@RelevantMinorBettypeId = MinorBettypeId
			,@IsMatchInTimeRange = IsMatchInTimeRange
		FROM #tblRelevantMatches
		WHERE Id = @Id
		
		IF @RelevantMatchId IS NULL BREAK
		
		IF @IsMatchInTimeRange IS NULL
		BEGIN
			SET @IsMatchInTimeRange = CASE WHEN (@EventDateTime >= @FromTimeSendMessage AND @EventDateTime <= @ToTimeSendMessage)
				OR ( @RelevantMinorBettypeId IS NOT NULL AND EXISTS (
					SELECT 1
					FROM #tblCornerBookingBetTypes
					WHERE MinorBettypeId = @RelevantMinorBettypeId
						AND @EventDateTime >= @FromTimeSendMessageSpecialBettype
						AND @EventDateTime <= @ToTimeSendMessageSpecialBettype
					)
				) THEN 1 ELSE 0 END
		END
		
		DECLARE @RelevantIsUpdateRemark BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE 0 END)
			,@RelevantIsUpdateInfoSiteMatchId BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE 0 END)
			,@RelevantIsUpdateRound BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateRound END)
			,@RelevantIsUpdateDivision BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateDivision END)
			,@RelevantIsUpdateVenue BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateVenue END)
			,@RelevantIsUpdateOtherTime BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateOtherTime END)
			,@RelevantIsUpdateMarkets BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateMarkets END)
			,@RelevantIsUpdateWebsite1 BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateWebsite1 END)
			,@RelevantIsUpdateWebsite2 BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateWebsite2 END)
			,@RelevantIsUpdateWebsite3 BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateWebsite3 END)
			,@RelevantIsUpdateWebsite4 BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateWebsite4 END)
		
		EXEC dbo.OWP_LiveDetail_Update_MatchInfo_OtherInfo @ActorId = @ActorId
			,@SessionId = @SessionId
			,@OWPMatchId = @RelevantMatchId
			,@ParentMatchId = @ParentMatchId
			,@MinorBettypeId = @RelevantMinorBettypeId
			,@IsMatchInTimeRange = @IsMatchInTimeRange
			,@Remark = @Remark
			,@IsUpdateRemark = @RelevantIsUpdateRemark
			,@InfoSiteMatchId = @InfoSiteMatchId
			,@IsUpdateInfoSiteMatchId = @RelevantIsUpdateInfoSiteMatchId
			,@Round = @Round
			,@IsUpdateRound = @RelevantIsUpdateRound
			,@Division = @Division
			,@IsUpdateDivision = @RelevantIsUpdateDivision
			,@Venue = @Venue
			,@IsUpdateVenue = @RelevantIsUpdateVenue
			,@OtherTime = @OtherTime
			,@IsUpdateOtherTime = @RelevantIsUpdateOtherTime
			,@MarketIds = @MarketIds
			,@IsUpdateMarkets = @RelevantIsUpdateMarkets
			,@Website1 = @Website1
			,@IsUpdateWebsite1 = @RelevantIsUpdateWebsite1
			,@Website2 = @Website2
			,@IsUpdateWebsite2 = @RelevantIsUpdateWebsite2
			,@Website3 = @Website3
			,@IsUpdateWebsite3 = @RelevantIsUpdateWebsite3
			,@Website4 = @Website4
			,@IsUpdateWebsite4 = @RelevantIsUpdateWebsite4
		
		SET @Id = @Id + 1
	END
	
	-- For write log
	DECLARE @LoggedNewMarketIds NVARCHAR(100) = ISNULL(STUFF((
			SELECT ', ' + CAST(MarketId AS NVARCHAR)
			FROM dbo.MatchMarket WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
			FOR XML PATH('')
			), 1, 2, ''), '')

	SET @Xml = (
			SELECT info.Remark AS '@rm'
				,info.IsSoloMatch AS '@sl'
				,info.[Round] AS '@rd'
				,info.Division AS '@ds'
				,info.Venue AS '@vn'
				,om.OtherTime AS '@ot'
				,info.Website1 AS '@ws1'
				,info.Website2 AS '@ws2'
				,info.Website3 AS '@ws3'
				,info.Website4 AS '@ws4'
				,om.InfoSiteMatchId AS '@ifi'
				,@LoggedNewMarketIds AS '@mk'
				,info.MatchStatus AS '@ms'
				,@IsUpdateDivision AS '@iuds'
				,@IsUpdateMarkets AS '@iumk'
				,@IsUpdateOtherTime AS '@iuot'
				,@IsUpdateRound AS '@iurd'
				,@IsUpdateVenue AS '@iuvn'
				,@IsUpdateWebsite1 AS '@iuws1'
				,@IsUpdateWebsite2 AS '@iuws2'
				,@IsUpdateWebsite3 AS '@iuws3'
				,@IsUpdateWebsite4 AS '@iuws4'
			FROM dbo.MatchInfo AS info WITH (NOLOCK)
			LEFT JOIN OWPMatch AS om WITH (NOLOCK) ON info.OWPMatchId = om.OWPMatchId
			WHERE @OWPMatchId = info.OWPMatchId
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_LiveDetail_Update_MatchInfo'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END