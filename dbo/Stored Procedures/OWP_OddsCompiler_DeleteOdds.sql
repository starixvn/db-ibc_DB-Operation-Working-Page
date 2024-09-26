
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_DeleteOdds] @ActorId INT
	,@MatchOddsIds VARCHAR(1000)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20191111@Tyler.Dang
 Task : DELETE Odds
 DB: bodb_OWP          
          
 Revisions:
	20191111@Tyler.Dang: Init SP - [Redmine: #116230]
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

	DECLARE @tblOddsId TABLE (
		OddsId INT
	)
	
	INSERT INTO @tblOddsId ( OddsId	)
	SELECT [Value]
	FROM dbo.fnc_SplitString(@MatchOddsIds, ',')
		
	DECLARE @tblMatchRecommendOdds TABLE (
		MatchRecommendOddsId INT
		,OWPMatchId INT
		,Bettype INT
		,HDP SMALLMONEY
		,TeamChoice TINYINT
		,CreatedBy INT
		,CreatedDate DATETIME
	)
	
	DECLARE @tblMatchRecommendOddsDetail TABLE (
		MatchRecommendOddsId INT
		,Choice TINYINT
		,Odds MONEY
	)
	
	DELETE o
	OUTPUT deleted.MatchRecommendOddsId
		,deleted.OWPMatchId
		,deleted.Bettype
		,deleted.HDP
		,deleted.TeamChoice
		,deleted.CreatedBy
		,deleted.CreatedDate
	INTO @tblMatchRecommendOdds (
		MatchRecommendOddsId
		,OWPMatchId
		,Bettype
		,HDP
		,TeamChoice
		,CreatedBy
		,CreatedDate
	)
	FROM dbo.MatchRecommendOdds AS o WITH (ROWLOCK)
	INNER JOIN @tblOddsId AS i ON o.MatchRecommendOddsId = i.OddsId
	
	DECLARE @OWPMatchId INT
	
	SELECT TOP 1 @OWPMatchId = OWPMatchId
	FROM @tblMatchRecommendOdds
	
	DELETE d
	OUTPUT deleted.MatchRecommendOddsId
		,deleted.Choice
		,deleted.Odds
	INTO @tblMatchRecommendOddsDetail (MatchRecommendOddsId, Choice, Odds)
	FROM dbo.MatchRecommendOddsDetail AS d WITH (ROWLOCK)
	INNER JOIN @tblMatchRecommendOdds AS o ON d.MatchRecommendOddsId = o.MatchRecommendOddsId

	SET @Xml = (
		SELECT m.MatchRecommendOddsId AS '@id'
			,m.Bettype AS '@bt'
			,m.HDP AS '@hdp'
			,m.TeamChoice AS '@tc'
			,m.CreatedBy AS '@cb'
			,m.CreatedDate AS '@cd'
			,d.Choice AS '@ch'
			,d.Odds AS '@odd'
		FROM @tblMatchRecommendOdds AS m
		INNER JOIN @tblMatchRecommendOddsDetail AS d ON m.MatchRecommendOddsId = d.MatchRecommendOddsId
		FOR XML PATH('z')
			,ROOT('r')
		)

	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_OddsCompiler_DeleteOdds'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@DataOld = @LogDataOld
		
	SELECT MatchRecommendOddsId AS Id
		,Bettype
		,TeamChoice
		,HDP AS Handicap
	FROM @tblMatchRecommendOdds
END