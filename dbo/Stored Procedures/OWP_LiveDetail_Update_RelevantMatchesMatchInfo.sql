/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_RelevantMatchesMatchInfo]  @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@RelevantUpdateProps NVARCHAR(500)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20190820@Tyler.Dang
Task : Update MatchInfo section for relevant matches
DB: bodb_OWP

Revisions:
	20190919@Tyler.Dang: InitialSP - [Redmine: #120496]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		-- Old Values
		@relevantRound NVARCHAR(2000) = ''
		,@relevantDivision NVARCHAR(2000) = ''
		,@relevantVenue NVARCHAR(100) = ''
		,@relevantOtherTime DATETIME = NULL
		,@relevantMarketIds NVARCHAR(100) = ''
		,@relevantWebsite1 NVARCHAR(1000) = ''
		,@relevantWebsite2 NVARCHAR(1000) = ''
		,@relevantWebsite3 NVARCHAR(1000) = ''
		,@relevantWebsite4 NVARCHAR(1000) = ''
		,@relevantIsSelected BIT = 0
		,@relevantInfoSiteMatchId INT = NULL
		,@relevantRemark NVARCHAR(2000) = ''
		,@relevantIsSoloMatch BIT = 0
		,@relevantMatchStatus NVARCHAR(15)

		-- New values
		,@newRound NVARCHAR(2000) = ''
		,@newDivision NVARCHAR(2000) = ''
		,@newVenue NVARCHAR(100) = ''
		,@newOtherTime DATETIME = NULL
		,@newMarketIds NVARCHAR(100) = ''
		,@newWebsite1 NVARCHAR(1000) = ''
		,@newWebsite2 NVARCHAR(1000) = ''
		,@newWebsite3 NVARCHAR(1000) = ''
		,@newWebsite4 NVARCHAR(1000) = ''

	CREATE TABLE #tblRelevantMatches (
		OWPMatchId INT,
		Id INT IDENTITY(1,1) PRIMARY KEY
		)

	-- Get New Values
	SELECT @newRound =[Round]
		,@newDivision = Division
		,@newVenue = Venue
		,@newWebsite1 = Website1
		,@newWebsite2 = Website2
		,@newWebsite3 = Website3
		,@newWebsite4 = Website4
	FROM DBO.MatchInfo WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId

	SELECT @newOtherTime = OtherTime
	FROM DBO.OWPMatch WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId

	SELECT @newMarketIds = ISNULL(STUFF((
			SELECT ', ' + CAST(MarketId AS NVARCHAR)
			FROM dbo.MatchMarket WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
			FOR XML PATH('')
			), 1, 2, ''), '')

	-- Find relevant matches
	INSERT INTO #tblRelevantMatches (OWPMatchId) EXEC [dbo].[OWP_Find_RelevantMatches] @OWPMatchId

	DECLARE @rowStart INT = 1

	WHILE (@rowStart <= (SELECT COUNT(OWPMatchId) FROM #tblRelevantMatches))
	BEGIN
		DECLARE @matchToUpdate INT = (SELECT OWPMatchId FROM #tblRelevantMatches WITH (NOLOCK) WHERE @rowStart = Id)

		-- Save Old Values
		SELECT @relevantRound =[Round]
			,@relevantDivision = Division
			,@relevantVenue = Venue
			,@relevantWebsite1 = Website1
			,@relevantWebsite2 = Website2
			,@relevantWebsite3 = Website3
			,@relevantWebsite4 = Website4
			,@relevantIsSelected = IsSelected
			,@relevantMatchStatus = MatchStatus
			,@relevantIsSoloMatch = IsSoloMatch
			,@relevantRemark = Remark
		FROM DBO.MatchInfo WITH (NOLOCK)
		WHERE OWPMatchId = @matchToUpdate

		SELECT @relevantOtherTime = OtherTime
			,@relevantInfoSiteMatchId = InfoSiteMatchId
		FROM DBO.OWPMatch WITH (NOLOCK)
		WHERE OWPMatchId = @matchToUpdate

		SELECT @relevantMarketIds = ISNULL(STUFF((
				SELECT ', ' + CAST(MarketId AS NVARCHAR)
				FROM dbo.MatchMarket WITH (NOLOCK)
				WHERE OWPMatchId = @matchToUpdate
				FOR XML PATH('')
				), 1, 2, ''), '')

		IF CHARINDEX('Round', @RelevantUpdateProps) > 0
			SET @relevantRound = @newRound
		IF CHARINDEX('Division', @RelevantUpdateProps) > 0
			SET @relevantDivision = @newDivision
		IF CHARINDEX('Venue', @RelevantUpdateProps) > 0
			SET @relevantVenue = @newVenue
		IF CHARINDEX('Website1', @RelevantUpdateProps) > 0
			SET @relevantWebsite1 = @newWebsite1
		IF CHARINDEX('Website2', @RelevantUpdateProps) > 0
			SET @relevantWebsite2 = @newWebsite2
		IF CHARINDEX('Website3', @RelevantUpdateProps) > 0
			SET @relevantWebsite3 = @newWebsite3
		IF CHARINDEX('Website4', @RelevantUpdateProps) > 0
			SET @relevantWebsite4 = @newWebsite4
		IF CHARINDEX('OtherTime', @RelevantUpdateProps) > 0
			SET @relevantOtherTime = @newOtherTime
		IF CHARINDEX('Markets', @RelevantUpdateProps) > 0
			SET @relevantMarketIds = @newMarketIds

		EXEC [dbo].[OWP_LiveDetail_Update_MatchInfo] @ActorId = @ActorId
				,@SessionId = @SessionId
				,@OWPMatchId = @matchToUpdate
				,@Round = @relevantRound
				,@Division = @relevantDivision
				,@Venue = @relevantVenue
				,@OtherTime = @relevantOtherTime
				,@MarketIds = @relevantMarketIds
				,@Website1 = @relevantWebsite1
				,@Website2 = @relevantWebsite2
				,@Website3 = @relevantWebsite3
				,@Website4 = @relevantWebsite4
				,@IsSelected = @relevantIsSelected
				,@MatchStatus = @relevantMatchStatus
				,@InfoSiteMatchId = @relevantInfoSiteMatchId
				,@IsSoloMatch = @relevantIsSoloMatch
				,@Remark = @relevantRemark
		SET @rowStart = @rowStart + 1
	END
END