
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_AddMatchRecommendOddsDetail] @MatchRecommendOddsId INT
	,@DataXml NVARCHAR(MAX)
AS
/*
 Created: 20190802@Kane.Le
 Task : add new MatchRecommendOddsDetail
 DB: bodb_OWP

 Revisions:
	20190802@Kane.Le: Initial SP - [Feature: #117461]	
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #RecommendOdds (
		Choice INT
		,Odds MONEY
		)
		DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@DataXml

	INSERT INTO #RecommendOdds (
		Choice
		,Odds
		)
	SELECT DISTINCT data.Choice
		,data.Odds
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
			Choice VARCHAR(20)
			,Odds MONEY
			) AS data

	EXEC sp_xml_removedocument @idoc

	INSERT INTO dbo.MatchRecommendOddsDetail (
		MatchRecommendOddsId
		,Choice
		,Odds
		)
	SELECT @MatchRecommendOddsId
		,Choice
		,Odds
	FROM #RecommendOdds
	 
	DROP TABLE #RecommendOdds
END