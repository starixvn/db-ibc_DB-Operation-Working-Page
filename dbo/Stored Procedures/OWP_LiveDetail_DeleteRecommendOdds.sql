CREATE PROCEDURE [dbo].[OWP_LiveDetail_DeleteRecommendOdds] @UserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@Handicap SMALLMONEY
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161206@Tim.Trinh
Task : delete recommend odds
DB: bodb_OWP

Revisions:
   
*/
BEGIN
	SET NOCOUNT ON

	-- Log
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	BEGIN TRY
		SET @Xml = (
				SELECT OWPMatchId AS '@mt'
					,Bettype AS '@bt'
					,HDP AS '@hdp'
					,Choice AS '@c'
					,Odds AS '@o'
				FROM dbo.MatchRecommendOdds WITH (NOLOCK)
				WHERE OWPMatchId = @OWPMatchId
					AND Bettype = @Bettype
					AND HDP = @Handicap
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		-- delete
		DELETE
		FROM dbo.MatchRecommendOdds WITH (ROWLOCK, UPDLOCK)
		WHERE OWPMatchId = @OWPMatchId
			AND Bettype = @Bettype
			AND HDP = @Handicap

		-- Write Log: Continue
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LiveDetail_DeleteRecommendOdds'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = NULL
			,@DataOld = @LogDataOld
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Delete recommend odds failed. Please try again.'
			,@ErrCode = 4601 -- ActionId + 01

		RETURN
	END CATCH
END