/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_UpdateHDP] @UserId INT
	,@Id INT
	,@TeamChoice TINYINT = 0
	,@HDP SMALLMONEY = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170320@Alvin.Nguyen
 Task : insert odds compiler
 DB: bodb_OWP          
          
 Revisions:      
        20181030@Leo: negative Handicap
*/
BEGIN
	SET NOCOUNT ON
	
		IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE MatchRecommendOddsId <> @Id
				AND TeamChoice = @TeamChoice
				AND (
					(
						HDP IS NULL
						AND @HDP IS NULL
						)
					OR HDP = @HDP
					)
			)
	BEGIN
		SELECT @ErrMsg = 'The recommend odds is already existed. Please add another one'
			,@ErrCode = 7201 -- ActionId + 01

		RETURN
	END

	UPDATE dbo.MatchRecommendOdds WITH (ROWLOCK, UPDLOCK)
	SET TeamChoice = @TeamChoice
		,HDP = @HDP
	WHERE MatchRecommendOddsId = @Id
END