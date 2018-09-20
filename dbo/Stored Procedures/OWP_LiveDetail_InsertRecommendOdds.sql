CREATE PROCEDURE [dbo].[OWP_LiveDetail_InsertRecommendOdds] @UserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@Handicap SMALLMONEY
	,@RecommendOdds NVARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161205@Tim.Trinh
Task : insert recommend odds
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

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND HDP = @Handicap
			)
	BEGIN
		SELECT @ErrMsg = 'Duplicate recommend odds'
			,@ErrCode = 4402 -- ActionId + 02

		RETURN
	END

	IF OBJECT_ID('tempdb..#RecommendOdds') IS NOT NULL
	BEGIN
		DROP TABLE #RecommendOdds
	END

	CREATE TABLE #RecommendOdds (
		Choice INT
		,Odds MONEY
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@RecommendOdds

	INSERT INTO #RecommendOdds (
		Choice
		,Odds
		)
	SELECT DISTINCT data.Choice
		,data.Odds
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Choice VARCHAR(20), Odds MONEY) AS data

	EXEC sp_xml_removedocument @idoc

	SET @StartRun = GETDATE()

	BEGIN TRY
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
			,@UserId
			,GETDATE()
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
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Insert recommend odds failed. Please try again.'
			,@ErrCode = 4401 -- ActionId + 01

		RETURN
	END CATCH

	DROP TABLE #RecommendOdds
END