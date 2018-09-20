CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Update] @UserId INT
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

	CREATE TABLE #tblLogs (
		CreatorId INT
		,LoggedDate DATETIME
		,Duration INT
		,ObjectId INT
		,ActionId INT
		,Data NVARCHAR(MAX)
		,DataOld NVARCHAR(MAX)
		)

	SET @StartRun = GETDATE()

	IF @IsOdd = 0
	BEGIN
		IF @Value = @OldHandicap
		BEGIN
			SELECT @ErrMsg = 'No data change'
				,@ErrCode = 7301 -- ActionId + 01

			RETURN
		END
		ELSE
		BEGIN
			IF @Value IS NOT NULL
				AND @OldHandicap IS NOT NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM dbo.MatchRecommendOdds WITH (NOLOCK)
						WHERE OWPMatchId = @OWPMatchId
							AND Bettype = @Bettype
							AND HDP = @Value
							AND HDP <> @OldHandicap
						)
				BEGIN
					SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
						,@ErrCode = 7302 -- ActionId + 02

					RETURN
				END
			END
			ELSE
			BEGIN
				IF @OldHandicap IS NULL
				BEGIN
					IF EXISTS (
							SELECT 1
							FROM dbo.MatchRecommendOdds WITH (NOLOCK)
							WHERE OWPMatchId = @OWPMatchId
								AND Bettype = @Bettype
								AND HDP = @Value
								AND HDP IS NOT NULL
							)
					BEGIN
						SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
							,@ErrCode = 7201 -- ActionId + 02

						RETURN
					END
				END

				IF @Value IS NULL
				BEGIN
					IF EXISTS (
							SELECT 1
							FROM dbo.MatchRecommendOdds WITH (NOLOCK)
							WHERE OWPMatchId = @OWPMatchId
								AND Bettype = @Bettype
								AND HDP IS NULL
							)
						--AND HDP <> @OldHandicap
					BEGIN
						SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
							,@ErrCode = 7201 -- ActionId + 02

						RETURN
					END
				END
			END
		END

		IF @OldHandicap IS NULL
		BEGIN
			INSERT INTO #tblLogs (
				CreatorId
				,LoggedDate
				,ObjectId
				,ActionId
				,DataOld
				)
			SELECT @UserId
				,@StartRun
				,Id
				,73
				,REPLACE(CONVERT(NVARCHAR(MAX), (
							SELECT Id AS '@id'
								,OWPMatchId AS '@mt'
								,Bettype AS '@bt'
								,HDP AS '@hdp'
								,Choice AS '@c'
								,Odds AS '@o'
							FOR XML PATH('z')
								,ROOT('r')
							)), '" />', '"/"')
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP IS NULL

			UPDATE dbo.MatchRecommendOdds WITH (UPDLOCK, ROWLOCK)
			SET HDP = @Value
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP IS NULL
		END
		ELSE
		BEGIN
			INSERT INTO #tblLogs (
				CreatorId
				,LoggedDate
				,ObjectId
				,ActionId
				,DataOld
				)
			SELECT @UserId
				,@StartRun
				,Id
				,73
				,REPLACE(CONVERT(NVARCHAR(MAX), (
							SELECT Id AS '@id'
								,OWPMatchId AS '@mt'
								,Bettype AS '@bt'
								,HDP AS '@hdp'
								,Choice AS '@c'
								,Odds AS '@o'
							FOR XML PATH('z')
								,ROOT('r')
							)), '" />', '"/"')
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP = @OldHandicap

			UPDATE dbo.MatchRecommendOdds WITH (UPDLOCK, ROWLOCK)
			SET HDP = @Value
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP = @OldHandicap
		END

		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		UPDATE l
		SET l.Duration = @Duration
			,l.Data = REPLACE(CONVERT(NVARCHAR(MAX), (
						SELECT odd.Id AS '@id'
							,odd.OWPMatchId AS '@mt'
							,odd.Bettype AS '@bt'
							,odd.HDP AS '@hdp'
							,odd.Choice AS '@c'
							,odd.Odds AS '@o'
						FOR XML PATH('z')
							,ROOT('r')
						)), '" />', '"/"')
		FROM #tblLogs AS l
			INNER JOIN dbo.MatchRecommendOdds AS odd WITH (NOLOCK) ON l.ObjectId = odd.Id

		--write log
		INSERT INTO UserLog (
			CreatorId
			,LoggedDate
			,ActionId
			,ObjectId
			,Duration
			,Data
			,DataOld
			)
		SELECT CreatorId
			,LoggedDate
			,ActionId
			,ObjectId
			,@Duration
			,Data
			,DataOld
		FROM #tblLogs
	END
	ELSE
	BEGIN
		IF @OldHandicap IS NULL
		BEGIN
			SET @Xml = (
					SELECT OWPMatchId AS '@mt'
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
			SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

			--Update Odds
			UPDATE dbo.MatchRecommendOdds WITH (UPDLOCK, ROWLOCK)
			SET Odds = @Value
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP IS NULL
				AND Choice = @Choice

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
			SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		END
		ELSE
		BEGIN
			SET @Xml = (
					SELECT OWPMatchId AS '@mt'
						,Bettype AS '@bt'
						,HDP AS '@hdp'
						,Choice AS '@c'
						,Odds AS '@o'
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
						AND HDP = @OldHandicap
						AND Choice = @Choice
					FOR XML PATH('z')
						,ROOT('r')
					)
			SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

			--Update Odds
			UPDATE dbo.MatchRecommendOdds WITH (UPDLOCK, ROWLOCK)
			SET Odds = @Value
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP = @OldHandicap
				AND Choice = @Choice

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
						AND HDP = @OldHandicap
						AND Choice = @Choice
					FOR XML PATH('z')
						,ROOT('r')
					)
			SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		END

		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		--write log
		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_OddsCompiler_Update'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @LogData
			,@DataOld = @LogDataOld

		IF @Bettype = @1X2
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM dbo.MatchRecommendOdds WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @1X2
						AND Odds IS NOT NULL
					)
			BEGIN
				INSERT INTO #tblLogs (
					CreatorId
					,LoggedDate
					,ObjectId
					,ActionId
					,DataOld
					)
				SELECT @UserId
					,@StartRun
					,Id
					,71
					,REPLACE(CONVERT(NVARCHAR(MAX), (
								SELECT Id AS '@id'
									,OWPMatchId AS '@mt'
									,Bettype AS '@bt'
									,HDP AS '@hdp'
									,Choice AS '@c'
									,Odds AS '@o'
								FOR XML PATH('z')
									,ROOT('r')
								)), '" />', '"/"')
				FROM dbo.MatchRecommendOdds WITH (NOLOCK)
				WHERE OWPMatchId = @OWPMatchId
					AND Bettype = @1X2

				--delete odds
				DELETE dbo.MatchRecommendOdds
				WHERE OWPMatchId = @OWPMatchId
					AND Bettype = @1X2

				INSERT INTO UserLog (
					CreatorId
					,LoggedDate
					,ActionId
					,ObjectId
					,Duration
					,Data
					,DataOld
					)
				SELECT CreatorId
					,LoggedDate
					,ActionId
					,ObjectId
					,@Duration
					,Data
					,DataOld
				FROM #tblLogs
			END
		END
	END

	DROP TABLE #tblLogs
END