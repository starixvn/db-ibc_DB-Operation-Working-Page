USE [bodb_OWP]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetOddByOwpMatchId] @OwpMatchId INT
AS
/*    
 Created: 20220907@Carlos.nguyen
 Task : GetOddByOwpMatchId
 DB: bodb_OWP    
    
 Revisions:
	20220907@Carlos.nguyen: Initial SP - [Redmine: #177318]
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblResult(
		[Key] VARCHAR(50),
		[Value] MONEY
	)

	CREATE TABLE #tblOddHdpOu(
		Bettype INT NOT NULL,
		Odd MONEY
	)

	CREATE TABLE #tblTeamChoice(
		TeamChoice INT
	)

	DECLARE @hdp MONEY;
	DECLARE @ou MONEY;
	DECLARE @odd_hdp_Hdp1 MONEY;
	DECLARE @odd_hdp_Hdp2 MONEY;

	INSERT INTO #tblOddHdpOu(Bettype, Odd)
	SELECT odd.Bettype, odd.HDP FROM MatchRecommendOdds AS odd
	WHERE odd.OWPMatchId=@OwpMatchId AND odd.Bettype IN (1,3)

	SET @hdp= (SELECT odd.Odd FROM #tblOddHdpOu AS odd
	WHERE odd.Bettype=1)

	SET @ou= (SELECT odd.Odd FROM #tblOddHdpOu AS odd
	WHERE odd.Bettype=3)

	INSERT INTO #tblTeamChoice(TeamChoice)
	SELECT DISTINCT odd.TeamChoice
	FROM MatchRecommendOdds AS odd
	WHERE odd.OWPMatchId=@OwpMatchId AND odd.Bettype IN (1,3)

	INSERT INTO #tblResult([Key], [Value])
	SELECT CASE
		WHEN oddd.Choice=1 AND odd.Bettype=1 THEN 'ODDS_HOME'
		WHEN oddd.Choice=2 AND odd.Bettype=1 THEN 'ODDS_AWAY'
		WHEN oddd.Choice=1 AND odd.Bettype=3 THEN 'ODDS_OVER'
		WHEN oddd.Choice=2 AND odd.Bettype=3 THEN 'ODDS_UNDER'
		END,
		oddd.Odds
	FROM MatchRecommendOdds AS odd
	INNER JOIN MatchRecommendOddsDetail AS oddd
	ON odd.MatchRecommendOddsId=oddd.MatchRecommendOddsId
	WHERE OWPMatchId=@OwpMatchId AND Bettype IN (1,3)

	IF EXISTS
		 (
			 SELECT 1
			 FROM #tblTeamChoice AS tc
			 WHERE tc.TeamChoice = 2
		 )
	BEGIN -- CASE AWAY
		IF @hdp<0
		BEGIN
			SET @odd_hdp_Hdp1=0;
			SET @odd_hdp_Hdp2=ABS(@hdp)
		END
		IF @hdp=0
		BEGIN
			SET @odd_hdp_Hdp1=0;
			SET @odd_hdp_Hdp2=0;
		END
		IF @hdp>0
		BEGIN
			SET @odd_hdp_Hdp1=@hdp;
			SET @odd_hdp_Hdp2=0;
		END
	END
	ELSE
	BEGIN -- CASE HOME
		IF @hdp<0
		BEGIN
			SET @odd_hdp_Hdp1=ABS(@hdp);
			SET @odd_hdp_Hdp2=0;
		END
		IF @hdp=0
		BEGIN
			SET @odd_hdp_Hdp1=0;
			SET @odd_hdp_Hdp2=0;
		END
		IF @hdp>0
		BEGIN
			SET @odd_hdp_Hdp1=0;
			SET @odd_hdp_Hdp2=@hdp;
		END
	END

	INSERT INTO #tblResult([Key], [Value])
	VALUES ('ODDS_HANDICAP_HDP1', @odd_hdp_Hdp1),
	('ODDS_HANDICAP_HDP2', @odd_hdp_Hdp2)

	INSERT INTO #tblResult([Key], [Value])
	VALUES ('ODDS_OU_HDP1', @ou),
	('ODDS_OU_HDP2', CASE WHEN @ou IS NOT NULL THEN 0
					END)

	SELECT [Key], [Value]
	FROM #tblResult

	DROP TABLE #tblResult;
	DROP TABLE #tblTeamChoice;
	DROP TABLE #tblOddHdpOu;
END