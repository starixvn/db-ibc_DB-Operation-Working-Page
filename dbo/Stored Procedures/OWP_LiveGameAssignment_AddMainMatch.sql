
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
	20190724@Kane.Le: Initial SP - [Feature: #117461]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OWPLeagueId INT
		,@OWPHomeTeamId INT
		,@OWPAwayTeamId INT
		,@EventDateTime DATETIME

	SELECT @EventDateTime = CAST(@EventDate AS DATETIME) + CAST(@KickOffTime AS DATETIME)

	IF (@KickOffTime < '12:00')
		SELECT @EventDateTime = DATEADD(DAY, 1, @EventDateTime)

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

	SELECT @ErrCode = 0
		,@ErrMsg = 'The event has been added successfully!'
END