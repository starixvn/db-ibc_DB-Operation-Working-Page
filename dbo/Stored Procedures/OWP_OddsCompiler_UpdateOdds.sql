/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_UpdateOdds] @UserId INT
	,@Id INT
	,@Choice TINYINT
	,@Odds MONEY = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20181030@Leo: negative Handicap
 Task : negative HDP
 DB: bodb_OWP          
          
 Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]      
*/
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.MatchRecommendOddsDetail WITH (ROWLOCK, UPDLOCK)
	SET Odds = @Odds
	WHERE MatchRecommendOddsId = @Id
		AND Choice = @Choice
END