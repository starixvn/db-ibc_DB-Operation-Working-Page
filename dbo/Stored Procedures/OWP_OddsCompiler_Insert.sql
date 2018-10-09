/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Insert] @UserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@TeamChoice TINYINT = 0
	,@HDP SMALLMONEY = NULL
	,@Choice TINYINT = NULL
	,@Odds MONEY = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170320@Alvin.Nguyen
 Task : insert odds compiler
 DB: bodb_OWP          
          
 Revisions:      
     20181030@Leo: negative Handicap
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Detail TABLE (Choice TINYINT)
	DECLARE @1X2 TINYINT = 5

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND TeamChoice = @TeamChoice
				AND (
					(
						HDP IS NULL
						AND @HDP IS NULL
						)
					OR HDP = @HDP
					)
			)
	BEGIN
		SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
			,@ErrCode = 7201 -- ActionId + 01

		RETURN
	END

	INSERT INTO dbo.MatchRecommendOdds (
		OWPMatchId
		,Bettype
		,TeamChoice
		,HDP
		,CreatedBy
		)
	VALUES (
		@OWPMatchId
		,@Bettype
		,@TeamChoice
		,@HDP
		,@UserId
		)

	DECLARE @Id INT = @@IDENTITY

	INSERT INTO @Detail
	VALUES (1)
		,(2)

	IF @Bettype = @1X2
		INSERT @Detail
		VALUES (3)

	INSERT INTO dbo.MatchRecommendOddsDetail (
		MatchRecommendOddsId
		,Choice
		)
	SELECT @Id
		,Choice
	FROM @Detail

	IF @Choice > 0
	BEGIN
		UPDATE dbo.MatchRecommendOddsDetail WITH (ROWLOCK, UPDLOCK)
		SET Odds = @Odds
		WHERE MatchRecommendOddsId = @Id
			AND Choice = @Choice
	END

	SET @ErrMsg = @Id
END