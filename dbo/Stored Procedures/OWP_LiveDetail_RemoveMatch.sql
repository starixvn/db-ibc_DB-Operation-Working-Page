
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_RemoveMatch] @ActorId INT
	,@OWPMatchId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20190920@Leo.Vo
Task : Remove match
DB: bodb_OWP

Revisions:
	20190920@Leo.Vo: InitialSP - [Redmine: #120496]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @ParentMatchId INT
		,@MinorBettypeId INT
		,@NoOfCorners INT = - 3
		,@TotalBooking INT = - 6
		,@Specific15MinsNoOfCorners INT = - 5
		,@Specific15MinsTotalBooking INT = - 8

	CREATE TABLE #tblMatchRecommendOdds (MatchRecommendOddsId INT)

	CREATE TABLE #tblRelevantMatch (OWPMatchId INT)

	SELECT @ParentMatchId = ParentMatchId
		,@MinorBettypeId = MinorBettypeId
	FROM dbo.MinorMatch WITH (NOLOCK)
	WHERE MinorMatchId = @OWPMatchId

	IF @ParentMatchId IS NULL
	BEGIN
		INSERT INTO #tblRelevantMatch (OWPMatchId)
		SELECT MinorMatchId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId
	END
	ELSE
	BEGIN
		IF @MinorBettypeId = @NoOfCorners
		BEGIN
			INSERT INTO #tblRelevantMatch (OWPMatchId)
			SELECT MinorMatchId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId
				AND MinorBettypeId = @Specific15MinsNoOfCorners
		END
		ELSE IF @MinorBettypeId = @TotalBooking
		BEGIN
			INSERT INTO #tblRelevantMatch (OWPMatchId)
			SELECT MinorMatchId
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @ParentMatchId
				AND MinorBettypeId = @Specific15MinsTotalBooking
		END
	END

	SELECT @ErrMsg = 'The event has been edited successfully!'
		,@ErrCode = 0

	-- remove match market
	DELETE dbo.MatchMarket WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match offers
	DELETE dbo.MatchOfferDetail WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match agent
	DELETE dbo.MatchAgent WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match tv
	DELETE dbo.MatchTelevision WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match provider
	DELETE dbo.MatchProvider WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match other provider
	DELETE dbo.MatchOtherProvider WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match setting
	DELETE dbo.MatchSetting WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remote match odds
	DELETE dbo.MatchRecommendOdds WITH (ROWLOCK)
	OUTPUT deleted.MatchRecommendOddsId
	INTO #tblMatchRecommendOdds(MatchRecommendOddsId)
	WHERE OWPMatchId = @OWPMatchId

	DELETE t
	FROM dbo.MatchRecommendOddsDetail AS t WITH (ROWLOCK)
		INNER JOIN #tblMatchRecommendOdds AS s ON t.MatchRecommendOddsId = s.MatchRecommendOddsId

	-- remove match note
	DELETE dbo.MatchNote WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match info
	DELETE dbo.MatchInfo WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-- remove match
	DELETE dbo.OWPMatch WITH (ROWLOCK)
	WHERE OWPMatchId = @OWPMatchId

	DROP TABLE #tblMatchRecommendOdds

	DROP TABLE #tblRelevantMatch
END