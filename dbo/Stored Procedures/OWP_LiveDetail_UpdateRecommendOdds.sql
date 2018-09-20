CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateRecommendOdds] @UserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@OldHandicap SMALLMONEY
	,@Handicap SMALLMONEY
	,@RecommendOdds NVARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161205@Tim.Trinh
Task : update recommend odds
DB: bodb_OWP

Revisions:
   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@idoc INT
		,@CreatedBy INT
		,@CreatedDate DATETIME

	IF OBJECT_ID('tempdb..#MatchRecommendOdds') IS NOT NULL
	BEGIN
		DROP TABLE #MatchRecommendOdds
	END

	CREATE TABLE #MatchRecommendOdds (
		OWPMatchId INT NOT NULL
		,Bettype INT NOT NULL
		,HDP SMALLMONEY NULL
		,Choice INT NOT NULL
		,Odds MONEY NULL
		,CreatedBy INT NULL
		,CreatedDate DATETIME NULL
		)

	IF OBJECT_ID('tempdb..#RecommendOdds') IS NOT NULL
	BEGIN
		DROP TABLE #RecommendOdds
	END

	CREATE TABLE #RecommendOdds (
		Choice INT
		,Odds MONEY
		)

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP = @Handicap
				AND HDP <> @OldHandicap
			)
	BEGIN
		SELECT @ErrMsg = 'Duplicate recommend odds'
			,@ErrCode = 4502 -- ActionId + 02

		RETURN
	END

	-- copy data
	INSERT INTO #MatchRecommendOdds (
		OWPMatchId
		,Bettype
		,HDP
		,Choice
		,Odds
		,CreatedBy
		,CreatedDate
		)
	SELECT OWPMatchId
		,Bettype
		,HDP
		,Choice
		,Odds
		,CreatedBy
		,CreatedDate
	FROM dbo.MatchRecommendOdds WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId
		AND Bettype = @Bettype
		AND HDP = @OldHandicap

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@RecommendOdds

	INSERT INTO #RecommendOdds (
		Choice
		,Odds
		)
	SELECT DISTINCT data.Choice
		,data.Odds
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Choice INT, Odds MONEY) AS data

	EXEC sp_xml_removedocument @idoc

	-- Log
	SET @StartRun = GETDATE()
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
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	BEGIN TRY
		SELECT TOP 1 @CreatedBy = CreatedBy
			,@CreatedDate = CreatedDate
		FROM dbo.MatchRecommendOdds WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId
			AND Bettype = @Bettype
			AND HDP = @OldHandicap

		DELETE
		FROM dbo.MatchRecommendOdds WITH (ROWLOCK, UPDLOCK)
		WHERE OWPMatchId = @OWPMatchId
			AND Bettype = @Bettype
			AND HDP = @OldHandicap

		INSERT INTO dbo.MatchRecommendOdds (
			OWPMatchId
			,Bettype
			,HDP
			,Choice
			,Odds
			,CreatedBy
			,CreatedDate
			)
		SELECT DISTINCT @OWPMatchId
			,@Bettype
			,@Handicap
			,Choice
			,Odds
			,@CreatedBy
			,@CreatedDate
		FROM #RecommendOdds

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
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LiveDetail_InsertRecommendOdds'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @LogData
			,@DataOld = @LogDataOld
	END TRY

	BEGIN CATCH
		-- rolback
		DELETE
		FROM dbo.MatchRecommendOdds WITH (ROWLOCK, UPDLOCK)
		WHERE OWPMatchId = @OWPMatchId
			AND Bettype = @Bettype
			AND HDP = @OldHandicap

		INSERT INTO dbo.MatchRecommendOdds (
			OWPMatchId
			,Bettype
			,HDP
			,Choice
			,Odds
			,CreatedBy
			,CreatedDate
			)
		SELECT OWPMatchId
			,Bettype
			,HDP
			,Choice
			,Odds
			,CreatedBy
			,CreatedDate
		FROM #MatchRecommendOdds

		SELECT @ErrMsg = 'Update recommend odds failed. Please try again.'
			,@ErrCode = 4501 -- ActionId + 01

		RETURN
	END CATCH

	DROP TABLE #MatchRecommendOdds

	DROP TABLE #RecommendOdds
END