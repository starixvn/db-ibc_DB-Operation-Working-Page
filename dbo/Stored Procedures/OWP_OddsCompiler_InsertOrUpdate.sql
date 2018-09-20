CREATE PROCEDURE [dbo].[OWP_OddsCompiler_InsertOrUpdate] @UserId INT
	,@IsInsert BIT = 0
	,@OWPMatchId INT
	,@Bettype INT
	,@IsOdd BIT
	,@OldHandicap SMALLMONEY = NULL
	,@Choice INT = NULL
	,@Value SMALLMONEY = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170320@Alvin.Nguyen
 Task : insert odds compiler
 DB: bodb_OWP          
          
 Revisions:      
         
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@Xml XML
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@1X2 TINYINT = 5

	SET @StartRun = GETDATE()

	IF @IsInsert = 1
	BEGIN
		EXEC dbo.OWP_OddsCompiler_Insert @UserId = @UserId
			,@OWPMatchId = @OWPMatchId
			,@Bettype = @Bettype
			,@IsOdd = @IsOdd
			,@Value = @Value
			,@Choice = @Choice
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		RETURN
	END

	--IS HDP
	IF @IsOdd = 0
	BEGIN
		IF @OldHandicap IS NULL
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP IS NULL
					)
				--INSERT HDP
			BEGIN
				EXEC dbo.OWP_OddsCompiler_Insert @UserId = @UserId
					,@OWPMatchId = @OWPMatchId
					,@Bettype = @Bettype
					,@IsOdd = @IsOdd
					,@Value = @Value
					,@Choice = @Choice
					,@ErrCode = @ErrCode OUTPUT
					,@ErrMsg = @ErrMsg OUTPUT

				IF @ErrCode <> 0 RETURN
			END
			ELSE
				--UPDATE HDP
			BEGIN
				EXEC dbo.OWP_OddsCompiler_Update @UserId = @UserId
					,@OWPMatchId = @OWPMatchId
					,@Bettype = @Bettype
					,@IsOdd = @IsOdd
					,@OldHandicap = @OldHandicap
					,@Choice = @Choice
					,@Value = @Value
					,@ErrCode = @ErrCode OUTPUT
					,@ErrMsg = @ErrMsg OUTPUT

				IF @ErrCode <> 0 RETURN
			END
		END
		ELSE
			--@OldHandicap not null
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP = @OldHandicap
					)
				--INSERT HDP
			BEGIN
				EXEC dbo.OWP_OddsCompiler_Insert @UserId = @UserId
					,@OWPMatchId = @OWPMatchId
					,@Bettype = @Bettype
					,@IsOdd = @IsOdd
					,@Value = @Value
					,@Choice = @Choice
					,@ErrCode = @ErrCode OUTPUT
					,@ErrMsg = @ErrMsg OUTPUT

				IF @ErrCode <> 0 RETURN
			END
			ELSE
				--UPDATE HDP
			BEGIN
				EXEC dbo.OWP_OddsCompiler_Update @UserId = @UserId
					,@OWPMatchId = @OWPMatchId
					,@Bettype = @Bettype
					,@IsOdd = @IsOdd
					,@OldHandicap = @OldHandicap
					,@Choice = @Choice
					,@Value = @Value
					,@ErrCode = @ErrCode OUTPUT
					,@ErrMsg = @ErrMsg OUTPUT

				IF @ErrCode <> 0 RETURN
			END
		END
	END
	ELSE
		--IsOdd
	BEGIN
		IF @Bettype = @1X2
		BEGIN
			SET @OldHandicap = 0
		END

		IF @OldHandicap IS NULL
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP IS NULL
						AND Choice = @Choice
					)
				--INSERT ODDS
			BEGIN
				EXEC dbo.OWP_OddsCompiler_Insert @UserId = @UserId
					,@OWPMatchId = @OWPMatchId
					,@Bettype = @Bettype
					,@IsOdd = @IsOdd
					,@Value = @Value
					,@Choice = @Choice
					,@ErrCode = @ErrCode OUTPUT
					,@ErrMsg = @ErrMsg OUTPUT

				IF @ErrCode <> 0 RETURN
			END
			ELSE
				--UPDATE ODDS
			BEGIN
				EXEC dbo.OWP_OddsCompiler_Update @UserId = @UserId
					,@OWPMatchId = @OWPMatchId
					,@Bettype = @Bettype
					,@IsOdd = @IsOdd
					,@OldHandicap = @OldHandicap
					,@Choice = @Choice
					,@Value = @Value
					,@ErrCode = @ErrCode OUTPUT
					,@ErrMsg = @ErrMsg OUTPUT

				IF @ErrCode <> 0 RETURN
			END
		END
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP = @OldHandicap
						AND Choice = @Choice
					)
				--INSERT ODDS
			BEGIN
				EXEC dbo.OWP_OddsCompiler_Insert @UserId = @UserId
					,@OWPMatchId = @OWPMatchId
					,@Bettype = @Bettype
					,@IsOdd = @IsOdd
					,@Value = @Value
					,@Choice = @Choice
					,@ErrCode = @ErrCode OUTPUT
					,@ErrMsg = @ErrMsg OUTPUT

				IF @ErrCode <> 0 RETURN
			END
			ELSE
				--UPDATE ODDS
			BEGIN
				EXEC dbo.OWP_OddsCompiler_Update @UserId = @UserId
					,@OWPMatchId = @OWPMatchId
					,@Bettype = @Bettype
					,@IsOdd = @IsOdd
					,@OldHandicap = @OldHandicap
					,@Choice = @Choice
					,@Value = @Value
					,@ErrCode = @ErrCode OUTPUT
					,@ErrMsg = @ErrMsg OUTPUT

				IF @ErrCode <> 0 RETURN
			END
		END
	END
END