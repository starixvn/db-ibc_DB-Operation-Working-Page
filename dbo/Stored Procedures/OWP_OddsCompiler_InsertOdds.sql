
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_InsertOdds] @ActorId INT
	,@OWPMatchId INT
	,@Bettype INT
	,@HDP SMALLMONEY = NULL
	,@TeamChoice TINYINT = 1
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
	,@Odds1 MONEY = NULL
	,@Odds2 MONEY = NULL
	,@Odds3 MONEY = NULL
AS
/*          
 Created: 20191106@Leo.Vo
 Task : Insert Odds
 DB: bodb_OWP          
          
 Revisions:
	20191106@Leo.Vo: Init SP - [Redmine: #116230]
*/
BEGIN
	SET NOCOUNT ON

	IF EXISTS (
			SELECT 1
			FROM dbo.MatchRecommendOdds WITH (NOLOCK)
			WHERE OWPMatchId = @OWPMatchId AND Bettype = @Bettype
			)
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Duplicate bet type'

		RETURN
	END

	DECLARE @FT1x2 TINYINT = 5
		,@1H1X2 TINYINT = 15
	DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@Xml XML
		,@LogData NVARCHAR(MAX)

	INSERT INTO dbo.MatchRecommendOdds (
		OWPMatchId
		,Bettype
		,HDP
		,TeamChoice
		,CreatedBy
		)
	VALUES (
		@OWPMatchId
		,@Bettype
		,@HDP
		,@TeamChoice
		,@ActorId
		)

	DECLARE @MatchRecommendOddsId INT = SCOPE_IDENTITY()
	DECLARE @tblMatchRecommendOddsDetail TABLE (
		Choice TINYINT
		,Odds MONEY
		)

	INSERT INTO @tblMatchRecommendOddsDetail (
		Choice
		,Odds
		)
	VALUES (
		1
		,@Odds1
		)
		,(
		2
		,@Odds2
		)

	IF @Bettype IN (@FT1x2, @1H1X2)
	BEGIN
		INSERT INTO @tblMatchRecommendOddsDetail (
			Choice
			,Odds
			)
		VALUES (
			3
			,@Odds3
			)
	END

	INSERT INTO dbo.MatchRecommendOddsDetail (
		MatchRecommendOddsId
		,Choice
		,Odds
		)
	SELECT @MatchRecommendOddsId
		,Choice
		,Odds
	FROM @tblMatchRecommendOddsDetail

	SELECT @ErrMsg = CAST(@MatchRecommendOddsId AS VARCHAR)

	SET @Xml = (
			SELECT mo.MatchRecommendOddsId AS '@id'
				,mo.Bettype AS '@bt'
				,mo.HDP AS '@hdp'
				,mo.TeamChoice AS '@tc'
				,mo.CreatedBy AS '@cb'
				,mo.CreatedDate AS '@cd'
				,d.Choice AS '@ch'
				,d.Odds AS '@odd'
			FROM dbo.MatchRecommendOdds AS mo WITH (NOLOCK)
				INNER JOIN dbo.MatchRecommendOddsDetail AS d WITH (NOLOCK) ON mo.MatchRecommendOddsId = d.MatchRecommendOddsId
			WHERE mo.MatchRecommendOddsId = @MatchRecommendOddsId
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_OddsCompiler_InsertOdds'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@Data = @LogData

	SELECT @MatchRecommendOddsId AS Id
END