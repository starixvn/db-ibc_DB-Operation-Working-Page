
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_AddMinorMatch] @ParentMatchId INT
	,@MinorBettypeId INT
	,@EventDate DATE
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
	,@OtherProvider VARCHAR(900) = ''
	,@Provider VARCHAR(900) = ''
	,@AgentIds NVARCHAR(100) = ''
	,@Market NVARCHAR(250) = ''
	,@ActorId INT
	,@SessionId VARCHAR(50)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
	,@MinorMatchId INT = NULL OUTPUT
AS
/*
 Created: 20190725@Kane.Le
 Task : add new event
 DB: bodb_OWP

 Revisions:
	20190724@Kane.Le: Initial SP - [Feature: #117461]
	20191021@Kane.Le: Fix MinorBettypeId IS NULL - [Feature: #120415]
	20191022@Kane.Le: Change Provider, OtherProvider - [Feature: #122194]
	20191217@Leo.Vo: Change Market column - [Redmine: #124448]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @LeagueName NVARCHAR(500)
		,@HomeName NVARCHAR(200)
		,@AwayName NVARCHAR(200)
	DECLARE @tblSpecialEventTemplate TABLE (
		LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		)

	INSERT INTO @tblSpecialEventTemplate
	EXEC [dbo].[OWP_LiveGameAssignment_GetSpecialEventTemplate] @ParentMatchId = @ParentMatchId
		,@MinorBettypeId = @MinorBettypeId

	SELECT @LeagueName = LeagueName
		,@HomeName = HomeName
		,@AwayName = AwayName
	FROM @tblSpecialEventTemplate

	EXEC OWP_LiveGameAssignment_AddMainMatch @EventDate = @EventDate
		,@MatchStatus = @MatchStatus
		,@LeagueName = @LeagueName
		,@HomeName = @HomeName
		,@AwayName = @AwayName
		,@MatchNo = @MatchNo
		,@KickOffTime = @KickOffTime
		,@OtherTime = @OtherTime
		,@InfoSiteMatchId = @InfoSiteMatchId
		,@Website1 = @Website1
		,@Website2 = @Website2
		,@Website3 = @Website3
		,@Website4 = @Website4
		,@Channel = @Channel
		,@WB = @WB
		,@Phone = @Phone
		,@Remark = @Remark
		,@NoOfHDPId = @NoOfHDPId
		,@IsSoloMatch = @IsSoloMatch
		,@MatchOfferIds = @MatchOfferIds
		,@Round = @Round
		,@Division = @Division
		,@Venue = @Venue
		,@TVIds = @TVIds
		,@OtherProvider = @OtherProvider
		,@Provider = @Provider
		,@AgentIds = @AgentIds
		,@Market = @Market
		,@ActorId = @ActorId
		,@SessionId = @SessionId
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@OWPMatchId = @MinorMatchId OUTPUT

	IF @ErrCode = 0
		AND @MinorBettypeId IS NOT NULL
	BEGIN
		INSERT INTO dbo.MinorMatch (
			MinorMatchId
			,ParentMatchId
			,MinorBettypeId
			,IsRepresented
			)
		VALUES (
			@MinorMatchId
			,@ParentMatchId
			,@MinorBettypeId
			,1
			)

		SELECT @ErrCode = 0
			,@ErrMsg = 'The event has been added successfully!'
	END
END