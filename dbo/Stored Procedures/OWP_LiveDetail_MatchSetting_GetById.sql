
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchSetting_GetById] @MatchId INT
AS
/*
Created: 2019-13-08@Carlos
Task : Get MatchSetting by matchId
DB: bodb_OWP

Revisions:
	20190813@Carlos: Initial SP - [Feature: #118595]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
*/

BEGIN
	CREATE TABLE #tblMinorMatch(
				MatchId INT,
				BettypeId INT,
				Bettype NVARCHAR(100))
				
	CREATE TABLE #tblMatchSetting(
				BettypeId INT,
				Bettype NVARCHAR(100),
				Maxbet MONEY,
				Spread SMALLMONEY)
				
	IF NOT EXISTS(SELECT 1
			  FROM MinorMatch AS mb WITH (NOLOCK)
			  WHERE mb.MinorMatchId=@MatchId )
		BEGIN	
			INSERT INTO #tblMinorMatch(MatchId, BettypeId)
			SELECT DISTINCT mm.MinorMatchId, mm.MinorBettypeId
			FROM MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.MinorBettypeId IN (-1,-88)AND mm.ParentMatchId=@MatchId
			
			INSERT INTO #tblMatchSetting(BettypeId, Maxbet, Spread)
			SELECT DISTINCT tblMm.BettypeId,
				ms.Maxbet,
				ms.Spread
			FROM MatchSetting AS ms WITH (NOLOCK) INNER JOIN #tblMinorMatch AS tblMm WITH (NOLOCK)
				ON tblMm.MatchId=ms.OWPMatchId
		END
	ELSE 
		BEGIN
			DECLARE @parentMatchId INT
					SELECT TOP 1 @parentMatchId = mm.ParentMatchId
					FROM MinorMatch AS mm WITH (NOLOCK)
					WHERE mm.MinorMatchId=@MatchId	
					
			IF EXISTS(SELECT 1
				FROM MinorMatch as mm WITH (NOLOCK)
				WHERE mm.MinorMatchId=@MatchId
					AND mm.MinorBettypeId = -3)
				BEGIN
					INSERT INTO #tblMinorMatch(MatchId, BettypeId)
					SELECT mm.MinorMatchId, mm.MinorBettypeId
					FROM MinorMatch AS mm WITH (NOLOCK)
					WHERE mm.ParentMatchId=@parentMatchId
								AND mm.MinorBettypeId = -5
					
					INSERT INTO #tblMatchSetting(BettypeId, Maxbet, Spread)
					SELECT DISTINCT tblMm.BettypeId,
						ms.Maxbet,
						ms.Spread
					FROM MatchSetting AS ms WITH (NOLOCK) INNER JOIN #tblMinorMatch AS tblMm WITH (NOLOCK)
						ON tblMm.MatchId=ms.OWPMatchId
				END
				
			IF EXISTS(SELECT 1
				FROM MinorMatch as mm WITH (NOLOCK)
				WHERE mm.MinorMatchId=@MatchId AND mm.MinorBettypeId =-6)
				BEGIN
					INSERT INTO #tblMinorMatch(MatchId, BettypeId)
					SELECT mm.MinorMatchId, mm.MinorBettypeId
					FROM MinorMatch AS mm WITH (NOLOCK)
					WHERE mm.ParentMatchId=@parentMatchId
								AND mm.MinorBettypeId =-8
					
					INSERT INTO #tblMatchSetting(BettypeId, Maxbet, Spread)
					SELECT DISTINCT tblMm.BettypeId,
						ms.Maxbet,
						ms.Spread
					FROM MatchSetting AS ms WITH (NOLOCK) INNER JOIN #tblMinorMatch AS tblMm WITH (NOLOCK)
						ON tblMm.MatchId=ms.OWPMatchId
				END
		END
	BEGIN
		INSERT INTO #tblMatchSetting(BettypeId, Maxbet, Spread)
				SELECT DISTINCT ms.Bettype,
					ms.Maxbet,
					ms.Spread
				FROM MatchSetting AS ms WITH (NOLOCK)
				WHERE ms.OWPMatchId=@MatchId
	END
	SELECT tblMs.BettypeId,
		tblMs.Maxbet,
		tblMs.Spread
	FROM #tblMatchSetting AS tblMs
	
	DROP TABLE #tblMatchSetting
	DROP TABLE #tblMinorMatch
	
END