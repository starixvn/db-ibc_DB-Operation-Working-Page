CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateNoOfHDP] @UserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@Handicap INT = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161202@Tim.Trinh
Task : update no. of handicap
DB: bodb_OWP

Revisions:
    20170411@Tim.Trinh: fix bug   
*/
BEGIN
	SET NOCOUNT ON

	-- Log
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	BEGIN TRY
		IF EXISTS (
				SELECT 1
				FROM dbo.MatchBettypeHDP WITH (NOLOCK)
				WHERE OWPMatchId = @OWPMatchId
					AND Bettype = @Bettype
				)
		BEGIN
			SET @Xml = (
					SELECT OWPMatchId AS '@mt'
						,Bettype AS '@bt'
						,Handicap AS '@hdp'
						,ModifiedBy AS '@mb'
						,ModifiedDate AS '@md'
					FROM dbo.MatchBettypeHDP WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
						AND Bettype = @Bettype
					FOR XML PATH('z')
						,ROOT('r')
					)
			SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

			IF @Handicap IS NOT NULL -- update
			BEGIN
				UPDATE dbo.MatchBettypeHDP WITH (UPDLOCK, ROWLOCK)
				SET Handicap = @Handicap
					,ModifiedBy = @UserId
					,ModifiedDate = GETDATE()
				WHERE OWPMatchId = @OWPMatchId
					AND Bettype = @Bettype

				SET @Xml = (
						SELECT OWPMatchId AS '@mt'
							,Bettype AS '@bt'
							,Handicap AS '@hdp'
							,ModifiedBy AS '@mb'
							,ModifiedDate AS '@md'
						FROM dbo.MatchBettypeHDP WITH (NOLOCK)
						WHERE OWPMatchId = @OWPMatchId
							AND Bettype = @Bettype
						FOR XML PATH('z')
							,ROOT('r')
						)
				SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
			END
			ELSE -- delete
			BEGIN
				SET @LogData = NULL

				DELETE
				FROM dbo.MatchBettypeHDP WITH (ROWLOCK, UPDLOCK)
				WHERE OWPMatchId = @OWPMatchId
					AND Bettype = @Bettype
			END

			SET @EndRun = GETDATE()
			SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

			EXEC dbo.OWP_WriteLog @CreatorId = @UserId
				,@SPName = 'OWP_LiveDetail_UpdateNoOfHDP'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = @OWPMatchId
				,@Data = @LogData
				,@DataOld = @LogDataOld
		END
		ELSE
		BEGIN
			IF @Handicap IS NOT NULL
			BEGIN
				SET @LogDataOld = NULL

				-- insert
				INSERT INTO dbo.MatchBettypeHDP (
					OWPMatchId
					,Bettype
					,Handicap
					,ModifiedBy
					,ModifiedDate
					)
				VALUES (
					@OWPMatchId
					,@Bettype
					,@Handicap
					,@UserId
					,GETDATE()
					)

				SET @Xml = (
						SELECT OWPMatchId AS '@mt'
							,Bettype AS '@bt'
							,Handicap AS '@hdp'
							,ModifiedBy AS '@mb'
							,ModifiedDate AS '@md'
						FROM dbo.MatchBettypeHDP WITH (NOLOCK)
						WHERE OWPMatchId = @OWPMatchId
							AND Bettype = @Bettype
						FOR XML PATH('z')
							,ROOT('r')
						)
				SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
				SET @EndRun = GETDATE()
				SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

				EXEC dbo.OWP_WriteLog @CreatorId = @UserId
					,@SPName = 'OWP_LiveDetail_UpdateNoOfHDP'
					,@LoggedDate = @StartRun
					,@Duration = @Duration
					,@ObjectId = @OWPMatchId
					,@Data = @LogData
					,@DataOld = @LogDataOld
			END
		END
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update no. of handicap failed. Please try again.'
			,@ErrCode = 4301 -- ActionId + 01

		RETURN
	END CATCH
END