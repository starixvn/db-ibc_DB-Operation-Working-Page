CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Insert] @UserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@Value SMALLMONEY = NULL
	,@Choice INT = NULL
	,@IsOdd BIT
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
		,@LogData NVARCHAR(MAX)
		,@Home TINYINT = 1
		,@Away TINYINT = 2
		,@Draw TINYINT = 3
		,@1X2 TINYINT = 5

	SET @StartRun = GETDATE()

	--Insert HDP
	IF @IsOdd = 0
	BEGIN
		IF @Value IS NULL
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP IS NULL
					)
			BEGIN
				SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
					,@ErrCode = 7201 -- ActionId + 01

				RETURN
			END
		END
		ELSE
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP = @Value
					)
			BEGIN
				SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
					,@ErrCode = 7201 -- ActionId + 01

				RETURN
			END
		END

		INSERT INTO dbo.MatchRecommendOdds (
			OWPMatchId
			,Bettype
			,HDP
			,Choice
			,Odds
			,CreatedBy
			,CreatedDate
			)
		VALUES (
			@OWPMatchId
			,@Bettype
			,@Value
			,@Home
			,NULL
			,@UserId
			,GETDATE()
			)

		IF @Value IS NULL
		BEGIN
			SET @Xml = (
					SELECT Id AS '@id'
						,OWPMatchId AS '@mt'
						,Bettype AS '@bt'
						,HDP AS '@hdp'
						,Choice AS '@c'
						,Odds AS '@o'
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP IS NULL
						AND Choice = @Home
					FOR XML PATH('z')
						,ROOT('r')
					)
		END
		ELSE
		BEGIN
			SET @Xml = (
					SELECT Id AS '@id'
						,OWPMatchId AS '@mt'
						,Bettype AS '@bt'
						,HDP AS '@hdp'
						,Choice AS '@c'
						,Odds AS '@o'
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP = @Value
						AND Choice = @Home
					FOR XML PATH('z')
						,ROOT('r')
					)
		END

		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_OddsCompiler_Insert'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @LogData
			,@DataOld = NULL

		INSERT INTO dbo.MatchRecommendOdds (
			OWPMatchId
			,Bettype
			,HDP
			,Choice
			,Odds
			,CreatedBy
			,CreatedDate
			)
		VALUES (
			@OWPMatchId
			,@Bettype
			,@Value
			,@Away
			,NULL
			,@UserId
			,GETDATE()
			)

		IF @Value IS NULL
		BEGIN
			SET @Xml = (
					SELECT Id AS '@id'
						,OWPMatchId AS '@mt'
						,Bettype AS '@bt'
						,HDP AS '@hdp'
						,Choice AS '@c'
						,Odds AS '@o'
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP IS NULL
						AND Choice = @Away
					FOR XML PATH('z')
						,ROOT('r')
					)
		END
		ELSE
		BEGIN
			SET @Xml = (
					SELECT Id AS '@id'
						,OWPMatchId AS '@mt'
						,Bettype AS '@bt'
						,HDP AS '@hdp'
						,Choice AS '@c'
						,Odds AS '@o'
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP = @Value
						AND Choice = @Away
					FOR XML PATH('z')
						,ROOT('r')
					)
		END

		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_OddsCompiler_Insert'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @LogData
			,@DataOld = NULL
	END
	ELSE
		--Insert Odds
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM dbo.MatchRecommendOdds WITH (NOLOCK)
				WHERE OWPMatchId = @OWPMatchId
					AND Bettype = @Bettype
					AND HDP IS NULL
				)
		BEGIN
			SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
				,@ErrCode = 7201 -- ActionId + 01

			RETURN
		END

		DECLARE @Length INT = 0
		DECLARE @DefaultHDP SMALLMONEY = NULL

		IF @Bettype = @1X2
		BEGIN
			SET @Length = 3
			SET @DefaultHDP = 0
		END
		ELSE
		BEGIN
			SET @Length = 2
		END

		BEGIN
			DECLARE @Iterator INT

			SET @Iterator = 1

			WHILE (@Iterator <= @Length)
			BEGIN
				IF @Iterator = @Choice
				BEGIN
					INSERT INTO MatchRecommendOdds (
						OWPMatchId
						,Bettype
						,HDP
						,Choice
						,Odds
						,CreatedBy
						,CreatedDate
						)
					VALUES (
						@OWPMatchId
						,@Bettype
						,@DefaultHDP
						,@Choice
						,@Value
						,@UserId
						,GETDATE()
						)

					IF @DefaultHDP IS NULL
					BEGIN
						SET @Xml = (
								SELECT Id AS '@id'
									,OWPMatchId AS '@mt'
									,Bettype AS '@bt'
									,HDP AS '@hdp'
									,Choice AS '@c'
									,Odds AS '@o'
								FROM dbo.MatchRecommendOdds WITH (NOLOCK)
								WHERE OWPMatchId = @OWPMatchId
									AND Bettype = @Bettype
									AND HDP IS NULL
									AND Choice = @Choice
								FOR XML PATH('z')
									,ROOT('r')
								)
					END
					ELSE
					BEGIN
						SET @Xml = (
								SELECT Id AS '@id'
									,OWPMatchId AS '@mt'
									,Bettype AS '@bt'
									,HDP AS '@hdp'
									,Choice AS '@c'
									,Odds AS '@o'
								FROM dbo.MatchRecommendOdds WITH (NOLOCK)
								WHERE OWPMatchId = @OWPMatchId
									AND Bettype = @Bettype
									AND HDP = @DefaultHDP
									AND Choice = @Choice
								FOR XML PATH('z')
									,ROOT('r')
								)
					END

					SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
					SET @EndRun = GETDATE()
					SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

					EXEC dbo.OWP_WriteLog @CreatorId = @UserId
						,@SPName = 'OWP_OddsCompiler_Insert'
						,@LoggedDate = @StartRun
						,@Duration = @Duration
						,@ObjectId = @OWPMatchId
						,@Data = @LogData
						,@DataOld = NULL
				END
				ELSE
				BEGIN
					INSERT INTO MatchRecommendOdds (
						OWPMatchId
						,Bettype
						,HDP
						,Choice
						,Odds
						,CreatedBy
						,CreatedDate
						)
					VALUES (
						@OWPMatchId
						,@Bettype
						,@DefaultHDP
						,@Iterator
						,NULL
						,@UserId
						,GETDATE()
						)

					IF @DefaultHDP IS NULL
					BEGIN
						SET @Xml = (
								SELECT Id AS '@id'
									,OWPMatchId AS '@mt'
									,Bettype AS '@bt'
									,HDP AS '@hdp'
									,Choice AS '@c'
									,Odds AS '@o'
								FROM dbo.MatchRecommendOdds WITH (NOLOCK)
								WHERE OWPMatchId = @OWPMatchId
									AND Bettype = @Bettype
									AND HDP IS NULL
									AND Choice = @Iterator
								FOR XML PATH('z')
									,ROOT('r')
								)
					END
					ELSE
					BEGIN
						SET @Xml = (
								SELECT Id AS '@id'
									,OWPMatchId AS '@mt'
									,Bettype AS '@bt'
									,HDP AS '@hdp'
									,Choice AS '@c'
									,Odds AS '@o'
								FROM dbo.MatchRecommendOdds WITH (NOLOCK)
								WHERE OWPMatchId = @OWPMatchId
									AND Bettype = @Bettype
									AND HDP = @DefaultHDP
									AND Choice = @Iterator
								FOR XML PATH('z')
									,ROOT('r')
								)
					END

					SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
					SET @EndRun = GETDATE()
					SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

					EXEC dbo.OWP_WriteLog @CreatorId = @UserId
						,@SPName = 'OWP_OddsCompiler_Insert'
						,@LoggedDate = @StartRun
						,@Duration = @Duration
						,@ObjectId = @OWPMatchId
						,@Data = @LogData
						,@DataOld = NULL
				END

				SET @Iterator = @Iterator + 1
			END
		END
	END
END