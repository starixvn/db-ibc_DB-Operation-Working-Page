/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateRecommendOdds] @Id INT
	,@UserId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@OldHandicap SMALLMONEY
	,@Handicap SMALLMONEY
	,@RecommendOdds NVARCHAR(MAX)
	,@TeamChoice INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161205@Tim.Trinh
Task : update recommend odds
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure 
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

	IF OBJECT_ID('tempdb..#RecommendOdds') IS NOT NULL
	BEGIN
		DROP TABLE #RecommendOdds
	END

	CREATE TABLE #RecommendOdds (
		MatchRecommendOddsId INT
		,Choice INT
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

	BEGIN TRY
		UPDATE dbo.MatchRecommendOdds
		SET HDP = @Handicap
			,TeamChoice = @TeamChoice
		WHERE MatchRecommendOddsId = @Id

		DELETE
		FROM MatchRecommendOddsDetail
		WHERE MatchRecommendOddsId = @Id
			AND Choice IN (
				SELECT Choice
				FROM #RecommendOdds
				)

		INSERT INTO dbo.MatchRecommendOddsDetail (
			MatchRecommendOddsId
			,Choice
			,Odds
			)
		SELECT DISTINCT @Id
			,Choice
			,Odds
		FROM #RecommendOdds
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update recommend odds failed. Please try again.'
			,@ErrCode = 4501 -- ActionId + 01

		RETURN
	END CATCH

	DROP TABLE #RecommendOdds
END