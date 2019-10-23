/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_AddMainMatch] @EventDate DATE
	,@LeagueName NVARCHAR(500)
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@MatchStatus VARCHAR(10)
	,@MatchNo VARCHAR(50) = ''
	,@KickOffTime TIME(7)
	,@OtherTime TIME(7) = NULL
	,@InfoSiteMatchId INT = NULL
	,@Website1 NVARCHAR(1000) = ''
	,@Website2 NVARCHAR(1000) = ''
	,@Website3 NVARCHAR(1000) = ''
	,@Website4 NVARCHAR(1000) = ''
	,@Channel NVARCHAR(100) = ''
	,@WB NVARCHAR(100) = ''
	,@Phone NVARCHAR(200) = ''
	,@Remark NVARCHAR(2000) = ''
	,@NoOfHDPId INT = NULL
	,@IsSoloMatch BIT = 0
	,@MatchOfferIds NVARCHAR(100) = ''
	,@Round NVARCHAR(2000) = ''
	,@Division NVARCHAR(2000) = ''
	,@Venue NVARCHAR(100) = ''
	,@TVIds NVARCHAR(500) = ''
	,@OtherProviderIds NVARCHAR(100) = ''
	,@ProviderIds NVARCHAR(100) = ''
	,@AgentIds NVARCHAR(100) = ''
	,@MarketIds NVARCHAR(100) = ''
	,@ActorId INT
	,@SessionId VARCHAR(50)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
	,@OWPMatchId INT OUTPUT
AS
/*
 Created: 20190725@Kane.Le
 Task : add new event
 DB: bodb_OWP

 Revisions:
	20190905@Kane.Le: Initial SP - [Feature: #117960]	 
	20190905@Kane.Le: Change temp table - [Feature: #117960]	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OWPLeagueId INT
		,@OWPHomeTeamId INT
		,@OWPAwayTeamId INT
		,@EventDateTime DATETIME

	IF (@KickOffTime < '12:00')
		SELECT @EventDate = DATEADD(DAY, -1, @EventDate)

	SELECT @EventDateTime = CAST(@EventDate AS DATETIME) + CAST(@KickOffTime AS DATETIME)

	SELECT @OWPLeagueId = OWPLeagueId
	FROM dbo.OWPLeague AS l WITH (NOLOCK)
	WHERE OWPLeagueName = @LeagueName

	IF @OWPLeagueId IS NULL
	BEGIN
		INSERT INTO dbo.OWPLeague (OWPLeagueName)
		VALUES (@LeagueName)

		SELECT @OWPLeagueId = SCOPE_IDENTITY()
	END

	SELECT @OWPHomeTeamId = OWPTeamId
	FROM dbo.OWPTeam AS t WITH (NOLOCK)
	WHERE OWPTeamName = @HomeName

	IF @OWPHomeTeamId IS NULL
	BEGIN
		INSERT INTO dbo.OWPTeam (OWPTeamName)
		VALUES (@HomeName)

		SELECT @OWPHomeTeamId = SCOPE_IDENTITY()
	END

	SELECT @OWPAwayTeamId = OWPTeamId
	FROM dbo.OWPTeam AS t WITH (NOLOCK)
	WHERE OWPTeamName = @AwayName

	IF @OWPAwayTeamId IS NULL
	BEGIN
		INSERT INTO dbo.OWPTeam (OWPTeamName)
		VALUES (@AwayName)

		SELECT @OWPAwayTeamId = SCOPE_IDENTITY()
	END

	INSERT INTO dbo.OWPMatch (
		MatchNo
		,EventDate
		,KickOffTime
		,OWPLeagueId
		,OWPHomeId
		,OWPAwayId
		,OtherTime
		,EventDateTime
		,InfoSiteMatchId
		)
	VALUES (
		@MatchNo
		,@EventDate
		,@KickOffTime
		,@OWPLeagueId
		,@OWPHomeTeamId
		,@OWPAwayTeamId
		,@OtherTime
		,@EventDateTime
		,@InfoSiteMatchId
		)

	SELECT @OWPMatchId = SCOPE_IDENTITY()

	INSERT INTO dbo.MatchInfo (
		OWPMatchId
		,Website1
		,Website2
		,Website3
		,Website4
		,MatchStatus
		,IsSelected
		)
	VALUES (
		@OWPMatchId
		,@Website1
		,@Website2
		,@Website3
		,@Website4
		,@MatchStatus
		,1
		)

	EXEC dbo.OWP_LiveDetail_MatchInfo_Update @ActorId
		,@SessionId
		,@OWPMatchId
		,@Channel
		,@WB
		,@Phone
		,@Remark
		,@NoOfHDPId
		,@IsSoloMatch
		,@MatchOfferIds
		,@Round
		,@Division
		,@Venue
		,@OtherTime
		,@TVIds
		,@OtherProviderIds
		,@ProviderIds
		,@AgentIds
		,@MarketIds
		,@ErrCode
		,@ErrMsg

	-- Update Main (minor template) to become Minor match
	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59');
		
		CREATE TABLE #tblOWPMatchByEventDate (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,OWPMatchId INT
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,MatchNo NVARCHAR(50)
		,MinorBettypeId INT
		,ParentMatchId INT
		);

	INSERT INTO #tblOWPMatchByEventDate (
		OWPMatchId
		,LeagueName
		,HomeName
		,AwayName
		,MatchNo
		,MinorBettypeId
		,ParentMatchId
		)
	SELECT m.OWPMatchId
		,l.OWPLeagueName
		,h.OWPTeamName
		,a.OWPTeamName
		,m.MatchNo
		,0
		,0
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
	--INNER JOIN dbo.MinorMatch AS mn WITH (NOLOCK) ON mn.ParentMatchId = m.OWPMatchId
	WHERE m.OWPMatchId <> @OWPMatchId
		AND m.EventDateTime BETWEEN @FromDate
			AND @ToDate;

	CREATE TABLE #tblSpecialEventTemplate (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,ParentMatchId INT
		,MinorBettypeId INT
		,MinorMatchId INT
		,MatchNo NVARCHAR(50)
		)
	CREATE TABLE #tblSpecialEventTemplateMain (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,ParentMatchId INT
		,MinorBettypeId INT
		,MinorMatchId INT
		,MatchNo NVARCHAR(50)
		)
	DECLARE @tblSpecialEventTemplateMain2Minor TABLE (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,ParentMatchId INT
		,MinorBettypeId INT
		,MinorMatchId INT
		,MatchNo NVARCHAR(50)
		)
	DECLARE @tblMinorBettypeId TABLE (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,MinorMatchId INT
		,MinorBettypeId INT
		,ParentMatchId INT
		)

	INSERT INTO @tblMinorBettypeId
	SELECT mm.MinorMatchId
		,mm.MinorBettypeId
		,mm.ParentMatchId
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
	WHERE ParentMatchId = @OWPMatchId

	DECLARE @LoopCounter INT = 1
		,@MaxRowCount INT
		,@MinorBettypeId INT
		,@ParentMatchId INT
		,@MinorMatchId INT
		,@RowNumber INT

	SET @LoopCounter = 1;

	SELECT @MaxRowCount = COUNT(RowNumber)
	FROM @tblMinorBettypeId

	WHILE (@LoopCounter <= @MaxRowCount)
	BEGIN
		SELECT @MinorBettypeId = MinorBettypeId
			,@ParentMatchId = ParentMatchId
			,@MinorMatchId = MinorMatchId
		FROM @tblMinorBettypeId
		WHERE @LoopCounter = RowNumber

		INSERT INTO #tblSpecialEventTemplate (
			LeagueName
			,HomeName
			,AwayName
			)
		EXEC [dbo].[OWP_LiveGameAssignment_GetSpecialEventTemplate] @ParentMatchId = @OWPMatchId
			,@MinorBettypeId = @MinorBettypeId

		UPDATE #tblSpecialEventTemplate
		SET ParentMatchId = @ParentMatchId
			,MinorBettypeId = @MinorBettypeId
			,MinorMatchId = @MinorMatchId
			,MatchNo = (
				SELECT TOP 1 o.MatchNo
				FROM dbo.OWPMatch AS o WITH (NOLOCK)
				WHERE o.OWPMatchId = @MinorMatchId
				)
		WHERE @LoopCounter = RowNumber

		SET @LoopCounter = @LoopCounter + 1
	END

	INSERT INTO #tblSpecialEventTemplateMain (
		LeagueName
		,HomeName
		,AwayName
		)
	EXEC [dbo].[OWP_LiveGameAssignment_GetSpecialEventTemplate] @ParentMatchId = @OWPMatchId

	INSERT INTO @tblSpecialEventTemplateMain2Minor (
		LeagueName
		,HomeName
		,AwayName
		,MinorMatchId
		,ParentMatchId
		)
	SELECT m.LeagueName
		,m.HomeName
		,m.AwayName
		,m.OWPMatchId
		,@OWPMatchId
	FROM #tblOWPMatchByEventDate AS m
	JOIN #tblSpecialEventTemplateMain AS t ON m.LeagueName = t.LeagueName
		AND m.HomeName = t.HomeName
		AND m.AwayName = t.AwayName
	WHERE NOT EXISTS (
			SELECT 1
			FROM #tblSpecialEventTemplate AS aa
			WHERE m.OWPMatchId = aa.MinorMatchId
			)

	SET @LoopCounter = 1;

	SELECT @MaxRowCount = COUNT(RowNumber)
	FROM @tblSpecialEventTemplateMain2Minor

	DECLARE @DetectMinorBettypeId INT
		,@MatchNoMinor NVARCHAR(50)

	WHILE (@LoopCounter <= @MaxRowCount)
	BEGIN
		SELECT @LeagueName = LeagueName
			,@HomeName = HomeName
			,@AwayName = AwayName
			,@MinorMatchId = MinorMatchId
		FROM @tblSpecialEventTemplateMain2Minor
		WHERE @LoopCounter = RowNumber

		EXEC [OWP_LiveGameAssignment_DetectMinorMatch] @LeagueName = @LeagueName
			,@HomeName = @HomeName
			,@AwayName = @AwayName
			,@MinorBettypeId = @DetectMinorBettypeId OUTPUT

		SELECT @MatchNoMinor = MatchNo
		FROM dbo.OWPMatch AS m WITH (NOLOCK)
		WHERE m.OWPMatchId = @MinorMatchId

		EXEC dbo.OWP_LiveGameAssignment_EditMainMatchToMinorMatch @OWPMatchId = @MinorMatchId
			,@MinorBettypeId = @DetectMinorBettypeId
			,@ParentMatchId = @OWPMatchId
			,@LeagueName = @LeagueName
			,@HomeName = @HomeName
			,@AwayName = @AwayName
			,@MatchNo = @MatchNoMinor
			,@SessionId = @SessionId
			,@ActorId = @ActorId
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		SET @LoopCounter = @LoopCounter + 1
	END

	DROP TABLE #tblSpecialEventTemplate
	DROP TABLE #tblSpecialEventTemplateMain
	DROP TABLE #tblOWPMatchByEventDate

	SELECT @ErrCode = 0
		,@ErrMsg = 'The event has been added successfully!'
END