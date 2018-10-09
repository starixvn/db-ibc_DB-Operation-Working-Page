/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_InsertRecommendOdds] @UserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@Handicap SMALLMONEY
	,@RecommendOdds NVARCHAR(MAX)
	,@TeamChoice INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
	,@Id INT OUTPUT
AS
/*
Created: 20161205@Tim.Trinh
Task : insert recommend odds
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure   
*/
BEGIN
	SET NOCOUNT ON

		IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId
				AND Bettype = @Bettype
				AND TeamChoice = @TeamChoice
				AND (
					(
						HDP IS NULL
						AND @Handicap IS NULL
						)
					OR HDP = @Handicap
					)
			)
	BEGIN
		SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
			,@ErrCode = 7201 -- ActionId + 01

		RETURN
	END
	
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
			,TeamChoice
			,CreatedBy
			,CreatedDate
			)
		VALUES (
			@OWPMatchId
			,@Bettype
			,@Handicap
			,@TeamChoice
			,@UserId
			,GETDATE()
			)

		SELECT @Id = @@IDENTITY

		INSERT INTO dbo.MatchRecommendOddsDetail (
			MatchRecommendOddsId
			,Choice
			,Odds
			)
		SELECT DISTINCT @Id
			,Choice
			,Odds
		FROM #RecommendOdds
		
		SELECT @ErrMsg = @Id
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Insert recommend odds failed. Please try again.'
			,@ErrCode = 4401 -- ActionId + 01

		RETURN
	END CATCH

	DROP TABLE #RecommendOdds
END