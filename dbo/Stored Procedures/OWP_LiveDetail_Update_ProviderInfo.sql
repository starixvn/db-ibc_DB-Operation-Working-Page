
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_ProviderInfo] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@Channel NVARCHAR(100) = ''
	,@IsUpdateChannel BIT = 0
	,@WB NVARCHAR(100) = ''
	,@IsUpdateWB BIT = 0
	,@Phone NVARCHAR(200) = ''
	,@IsUpdatePhone BIT = 0
	,@TVIds NVARCHAR(500) = ''
	,@IsUpdateTVs BIT = 0
	,@OtherProvider VARCHAR(900) = ''
	,@IsUpdateOtherProviders BIT = 0
	,@Provider VARCHAR(900) = ''
	,@IsUpdateProviders BIT = 0
	,@AgentIds NVARCHAR(100) = ''
	,@IsUpdateAgents BIT = 0
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20190820@Kane.Le
Task : update new Provider Info  
DB: bodb_OWP

Revisions:    
	20190820@Kane.Le: init SP - [Redmine: #117960]
	20190823@Carlos.Nguyen: Prevent send notification - [Redmine: #120415]
	20191017@Kane.Le: Change Provider, OtherProvider - [Feature: #122194]
	20200713@Mira.Nguyen: Apply new time range - [Redmine: #137410]
*/
BEGIN
	SET NOCOUNT ON
	
 

	DECLARE @EventDateTime DATETIME
		,@StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT		 
		,@Xml XML
		,@OldChannel NVARCHAR(100)
		,@OldWB NVARCHAR(100)
		,@OldPhone NVARCHAR(200)
		,@OldTVIds NVARCHAR(500)
		,@OldOtherProviderIds NVARCHAR(100)
		,@OldProviderIds NVARCHAR(100)
		,@OldAgentIds NVARCHAR(100)
		,@OldData NVARCHAR(MAX)
		,@NewData NVARCHAR(MAX)

	SELECT @EventDateTime = EventDateTime
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	WHERE m.OWPMatchId = @OWPMatchId
	
	-- save old value
	SELECT @OldChannel = m.Channel
		,@OldWB = m.WB
		,@OldPhone = m.Phone
	FROM dbo.MatchInfo AS m WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = m.OWPMatchId
	WHERE m.OWPMatchId = @OWPMatchId

	SELECT @OldTVIds = ISNULL(STUFF((
					SELECT ', ' + CAST(TVId AS NVARCHAR)
					FROM dbo.MatchTelevision WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	SELECT @OldOtherProviderIds = ISNULL(STUFF((
					SELECT ', ' + CAST(OtherProviderId AS NVARCHAR)
					FROM dbo.MatchOtherProvider WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	SELECT @OldProviderIds = ISNULL(STUFF((
					SELECT ', ' + CAST(ProviderId AS NVARCHAR)
					FROM dbo.MatchProvider WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	SELECT @OldAgentIds = ISNULL(STUFF((
					SELECT ', ' + CAST(AgentId AS NVARCHAR)
					FROM dbo.MatchAgent WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')
	
	SET @Xml = (
			SELECT @OldTVIds AS '@tv'
				,@OldChannel AS '@ch'
				,@OldWB AS '@wb'
				,@OldProviderIds AS '@pv'
				,@OldOtherProviderIds AS '@opv'
				,@OldPhone AS '@ph'
				,@OldAgentIds AS '@ag'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @OldData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	
	DECLARE @FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@ParentMatchId INT
		,@MinorBettypeId INT
		
	SELECT @ParentMatchId = ParentMatchId
		,@MinorBettypeId = MinorBettypeId
	FROM dbo.MinorMatch WITH (NOLOCK)
	WHERE MinorMatchId = @OWPMatchId
	
	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
	FROM dbo.fnc_GetDateTimeForTraderViewTime()
	
	DECLARE @tblRelevantMatches TABLE (
		Id INT IDENTITY(1,1)
		,OWPMatchId INT PRIMARY KEY CLUSTERED
		,MinorBettypeId INT)
	
	DECLARE @MinorBettype_FastMarket INT = - 88
		,@MinorBettype_AllInOne INT = - 89
		,@MinorBettype_Specific15Mins INT = - 1
		,@MinorBettype_Specific10Mins INT = - 2
		,@MinorBettype_Specific15MinsNoOfCorners INT = - 5
		,@MinorBettype_Specific15MinsTotalBooking INT = - 8
		
	INSERT INTO @tblRelevantMatches (
		OWPMatchId
		,MinorBettypeId
	)
	VALUES (@OWPMatchId, @MinorBettypeId)
	
	-- add relevant matches
	IF @ParentMatchId IS NULL
	BEGIN
		INSERT INTO @tblRelevantMatches (
			OWPMatchId
			,MinorBettypeId
		)
		SELECT MinorMatchId
			,MinorBettypeId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId AND MinorBettypeId NOT IN (
			@MinorBettype_FastMarket
			,@MinorBettype_AllInOne
			,@MinorBettype_Specific10Mins
			,@MinorBettype_Specific15Mins
			,@MinorBettype_Specific15MinsNoOfCorners
			,@MinorBettype_Specific15MinsTotalBooking)
	END
	ELSE
	BEGIN
		INSERT INTO @tblRelevantMatches (
			OWPMatchId
			,MinorBettypeId
		)
		SELECT @ParentMatchId
			,NULL
		UNION
		SELECT MinorMatchId
			,MinorBettypeId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @ParentMatchId AND MinorMatchId <> @OWPMatchId AND MinorBettypeId NOT IN (
			@MinorBettype_FastMarket
			,@MinorBettype_AllInOne
			,@MinorBettype_Specific10Mins
			,@MinorBettype_Specific15Mins
			,@MinorBettype_Specific15MinsNoOfCorners
			,@MinorBettype_Specific15MinsTotalBooking)
	END
	
	DECLARE @Id INT
		,@RelevantMatchId INT
		,@RelevantMinorBettypeId INT
		,@MaxRowCount INT
			
	DECLARE @tblTVIds TVP_INT
	INSERT INTO @tblTVIds (
		Id
		)
	SELECT Value
	FROM dbo.fnc_SplitString(@TVIds, ',')
	
	DECLARE @tblAgentIds TVP_INT
	INSERT INTO @tblAgentIds (
		Id
		)
	SELECT Value
	FROM dbo.fnc_SplitString(@AgentIds, ',')
		
	SET @Id = 1


	 
	SELECT @MaxRowCount = COUNT(Id)
	FROM @tblRelevantMatches

	WHILE (@Id <= @MaxRowCount)
	 
	BEGIN
				 
		SELECT @RelevantMatchId = OWPMatchId
			,@RelevantMinorBettypeId = MinorBettypeId
		FROM @tblRelevantMatches
		WHERE Id = @Id
		
		IF @RelevantMatchId IS NULL BREAK
		
		DECLARE @IsMatchInTimeRange BIT = CASE 
			WHEN (@EventDateTime >= @FromTimeSendMessage AND @EventDateTime <= @ToTimeSendMessage)
				THEN 1 
			ELSE 0 END
			
		DECLARE @RelevantIsUpdateTVs BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateTVs END)
			,@RelevantIsUpdateChannel BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateChannel END)
			,@RelevantIsUpdateWB BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateWB END)
			,@RelevantIsUpdateProviders BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateProviders END)
			,@RelevantIsUpdateOtherProviders BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateOtherProviders END)
			,@RelevantIsUpdateAgents BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdateAgents END)
			,@RelevantIsUpdatePhone BIT = (CASE WHEN @RelevantMatchId = @OWPMatchId THEN 1 ELSE @IsUpdatePhone END)
	 
		EXEC dbo.OWP_LiveDetail_Update_ProviderInfo_Single @ActorId = @ActorId
			,@SessionId = @SessionId
			,@OWPMatchId = @RelevantMatchId
			,@ParentMatchId = @ParentMatchId
			,@MinorBettypeId = @RelevantMinorBettypeId
			,@IsMatchInTimeRange = @IsMatchInTimeRange
			,@TVIds = @tblTVIds
			,@IsUpdateTVs = @RelevantIsUpdateTVs
			,@Channel = @Channel
			,@IsUpdateChannel = @RelevantIsUpdateChannel
			,@WB = @WB
			,@IsUpdateWB = @RelevantIsUpdateWB
			,@Phone = @Phone
			,@IsUpdatePhone = @RelevantIsUpdatePhone
			,@Provider = @Provider
			,@IsUpdateProviders = @RelevantIsUpdateProviders
			,@OtherProvider = @OtherProvider
			,@IsUpdateOtherProviders = @RelevantIsUpdateOtherProviders
			,@AgentIds = @tblAgentIds
			,@IsUpdateAgents = @RelevantIsUpdateAgents
		 
		SET @Id = @Id + 1
	END

	SET @Xml = (
			SELECT @TVIds AS '@tv'
				,@IsUpdateTVs AS '@iutv'
				,@Channel AS '@ch'
				,@IsUpdateChannel AS '@iuch'
				,@WB AS '@wb'
				,@IsUpdateWB AS '@iuwb'
				,@Provider AS '@pv'
				,@IsUpdateProviders AS '@iupv'
				,@OtherProvider AS '@opv'
				,@IsUpdateOtherProviders AS '@iuopv'
				,@Phone AS '@ph'
				,@IsUpdatePhone AS '@iuph'
				,@AgentIds AS '@ag'
				,@IsUpdateAgents AS '@iuag'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @NewData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_LiveDetail_Update_ProviderInfo'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@Data = @NewData
		,@DataOld = @OldData

	SELECT @ErrMsg = 'The event has been edited successfully!'
		,@ErrCode = 0
END