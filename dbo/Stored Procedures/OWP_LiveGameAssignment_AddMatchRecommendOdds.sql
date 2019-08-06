
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_AddMatchRecommendOdds] @OWPMatchId INT
	,@UserId INT
	,@SessionId NVARCHAR(50)
	,@DataXml NVARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
 Created: 20190802@Kane.Le
 Task : add new MatchRecommendOdds
 DB: bodb_OWP

 Revisions:
	20190802@Kane.Le: Initial SP - [Feature: #117461]	
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblMatchRecommendOdds (
		RowNumber INT IDENTITY
		,MatchRecommendOddsId INT
		,OWPMatchId INT
		,UserId INT
		,SessionId NVARCHAR(50)
		,Bettype INT
		,Handicap SMALLMONEY
		,TeamChoice INT
		,RecommendOdds NVARCHAR(MAX)
		)

	DECLARE @idoc INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@DataXml

	INSERT INTO #tblMatchRecommendOdds (
		MatchRecommendOddsId
		,OWPMatchId
		,UserId
		,SessionId
		,Bettype
		,Handicap
		,TeamChoice
		,RecommendOdds
		)
	SELECT NULL
		,@OWPMatchId
		,@UserId
		,@SessionId
		,data.Bettype
		,data.Handicap
		,data.TeamChoice
		,data.RecommendOddsXml
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
			Bettype INT
			,Handicap SMALLMONEY
			,TeamChoice INT
			,RecommendOddsXml NVARCHAR(MAX)
			) AS data

	EXEC sp_xml_removedocument @idoc

	DECLARE @InsertOutput1 TABLE (
		MatchRecommendOddsId INT
		,OWPMatchId INT
		,Bettype INT
		,Handicap SMALLMONEY
		,TeamChoice INT
		)

	INSERT INTO dbo.MatchRecommendOdds (
		OWPMatchId
		,Bettype
		,HDP
		,TeamChoice
		,CreatedBy
		,CreatedDate
		)
	OUTPUT inserted.MatchRecommendOddsId
		,@OWPMatchId
		,inserted.Bettype
		,inserted.HDP
		,inserted.TeamChoice
	INTO @InsertOutput1
	SELECT @OWPMatchId
		,Bettype
		,Handicap
		,TeamChoice
		,@UserId
		,GETDATE()
	FROM #tblMatchRecommendOdds

	UPDATE #tblMatchRecommendOdds
	SET MatchRecommendOddsId = t2.MatchRecommendOddsId
	FROM @InsertOutput1 AS t2
	WHERE @OWPMatchId = t2.OWPMatchId
		AND #tblMatchRecommendOdds.Bettype = t2.Bettype
		AND #tblMatchRecommendOdds.Handicap = t2.Handicap
		AND #tblMatchRecommendOdds.TeamChoice = t2.TeamChoice

	DECLARE @LoopCounter INT = 1
		,@MaxRowCount INT
		,@MatchRecommendOddsId INT
		,@RecommendOddsXml NVARCHAR(MAX)
		,@RowNumber INT

	SELECT @MaxRowCount = COUNT(*)
	FROM #tblMatchRecommendOdds

	WHILE (@LoopCounter <= @MaxRowCount)
	BEGIN
		SELECT @MatchRecommendOddsId = MatchRecommendOddsId
			,@RecommendOddsXml = RecommendOdds
		FROM #tblMatchRecommendOdds
		WHERE @LoopCounter = RowNumber

		EXEC dbo.OWP_LiveGameAssignment_AddMatchRecommendOddsDetail @MatchRecommendOddsId = @MatchRecommendOddsId
			,@DataXml = @RecommendOddsXml

		SET @LoopCounter = @LoopCounter + 1
	END

	DROP TABLE #tblMatchRecommendOdds

	SELECT @ErrCode = 0
		,@ErrMsg = ''
END