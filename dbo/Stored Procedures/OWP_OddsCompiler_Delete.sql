/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Delete] @MatchRecommendOddsIds NVARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170317@Alvin.Nguyen
 Task : delete odds compiler
 DB: bodb_OWP          
          
 Revisions:      
	20181004@Kane.Le: delete odds compiler
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #MatchRecommendOddsIds (Id INT)

	INSERT INTO #MatchRecommendOddsIds
	SELECT val
	FROM dbo.strSplit(@MatchRecommendOddsIds, ',')

	DELETE
	FROM dbo.MatchRecommendOddsDetail
	WHERE MatchRecommendOddsId IN (
			SELECT Id
			FROM #MatchRecommendOddsIds
			)

	DELETE
	FROM dbo.MatchRecommendOdds
	WHERE MatchRecommendOddsId IN (
			SELECT Id
			FROM #MatchRecommendOddsIds
			)

	DROP TABLE #MatchRecommendOddsIds
END