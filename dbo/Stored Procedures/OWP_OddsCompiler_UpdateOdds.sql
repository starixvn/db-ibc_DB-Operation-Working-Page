
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_OddsCompiler_UpdateOdds] @ActorId INT
	,@MatchRecommendOddsId INT
	,@HDP SMALLMONEY = NULL
	,@TeamChoice TINYINT = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
	,@Odds1 MONEY = NULL
	,@Odds2 MONEY = NULL
	,@Odds3 MONEY = NULL
AS
/*          
 Created: 20191106@Leo.Vo
 Task : Update Odds
 DB: bodb_OWP          
          
 Revisions:
	20191106@Leo.Vo: Init SP - [Redmine: #116230]
	20230630@Mira: Change default team choice - [Redmine: #188032]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @OWPMatchId INT
		,@MaxHDP SMALLMONEY = 99999
		,@MaxOdds MONEY = 99999

	SELECT @OWPMatchId = OWPMatchId
	FROM dbo.MatchRecommendOdds WITH (NOLOCK)
	WHERE MatchRecommendOddsId = @MatchRecommendOddsId

	IF @OWPMatchId IS NULL RETURN

	DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@Xml XML
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)

	SET @StartRun = GETDATE()
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
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

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
		,(
		3
		,@Odds3
		)

	UPDATE dbo.MatchRecommendOdds WITH (ROWLOCK)
	SET HDP = @HDP
		,TeamChoice = @TeamChoice
		,CreatedBy = @ActorId
		,CreatedDate = GETDATE()
	WHERE MatchRecommendOddsId = @MatchRecommendOddsId

	MERGE INTO dbo.MatchRecommendOddsDetail WITH (ROWLOCK) AS t
	USING (
		SELECT Choice
			,Odds
		FROM @tblMatchRecommendOddsDetail
		WHERE Odds IS NOT NULL
		) AS s ON t.MatchRecommendOddsId = @MatchRecommendOddsId AND s.Choice = t.Choice
	WHEN MATCHED THEN
			UPDATE
			SET t.Odds = s.Odds
	WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				MatchRecommendOddsId
				,Choice
				,Odds
				)
			VALUES (
				@MatchRecommendOddsId
				,s.Choice
				,s.Odds
				);

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
		,@SPName = 'OWP_OddsCompiler_UpdateOdds'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @OWPMatchId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END