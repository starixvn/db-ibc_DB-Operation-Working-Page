/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_DeleteRecommendOdds] @Id INT
AS
/*
Created: 20161206@Tim.Trinh
Task : delete recommend odds
DB: bodb_OWP

Revisions:
	20181004@Kane.Le: delete recommend odds
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.MatchRecommendOddsDetail WITH (ROWLOCK, UPDLOCK)
	WHERE MatchRecommendOddsId = @Id

	DELETE
	FROM dbo.MatchRecommendOdds WITH (ROWLOCK, UPDLOCK)
	WHERE MatchRecommendOddsId = @Id
END