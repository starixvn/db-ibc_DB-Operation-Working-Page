
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchSetting_GetById] @MatchId INT
AS
/*
Created: 2019-13-08@Carlos
Task : Get MatchSetting by matchId
DB: bodb_OWP

Revisions:
	20190813@Carlos: Initial SP - [Feature: #118595]
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
				Spread SMALLMONEY,
				MaxbetCN88 MONEY,
				SpreadCN88 SMALLMONEY)
				
	IF NOT EXISTS(SELECT 1
			  FROM MinorMatch AS mb WITH (NOLOCK)
			  WHERE mb.MinorMatchId=@MatchId )
		BEGIN	
			INSERT INTO #tblMinorMatch(MatchId, BettypeId)
			SELECT DISTINCT mm.MinorMatchId, mm.MinorBettypeId
			FROM MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.MinorBettypeId IN (-1,-88)AND mm.ParentMatchId=@MatchId
			
			INSERT INTO #tblMatchSetting(BettypeId, Maxbet, Spread, MaxbetCN88, SpreadCN88)
			SELECT tblMm.BettypeId,
				ms.Maxbet,
				ms.Spread,
				ms.MaxbetCN88,
				ms.SpreadCN88
			FROM MatchSetting AS ms WITH (NOLOCK) INNER JOIN #tblMinorMatch AS tblMm WITH (NOLOCK)
				ON tblMm.MatchId=ms.OWPMatchId
		END
	ELSE 
		BEGIN 
			IF EXISTS(SELECT 1
				FROM MinorMatch as mm WITH (NOLOCK)
				WHERE mm.MinorMatchId=@MatchId
					AND mm.MinorBettypeId IN(-3,-6))
				BEGIN
					DECLARE @parentMatchId INT
					SELECT TOP 1 @parentMatchId = mm.ParentMatchId
					FROM MinorMatch AS mm WITH (NOLOCK)
					WHERE mm.MinorMatchId=@MatchId	
					
					INSERT INTO #tblMinorMatch(MatchId, BettypeId)
					SELECT mm.MinorMatchId, mm.MinorBettypeId
					FROM MinorMatch AS mm WITH (NOLOCK)
					WHERE mm.ParentMatchId=@parentMatchId
								AND mm.MinorBettypeId IN (-5, -8)
					
					INSERT INTO #tblMatchSetting(BettypeId, Maxbet, Spread, MaxbetCN88, SpreadCN88)
					SELECT DISTINCT tblMm.BettypeId,
						ms.Maxbet,
						ms.Spread,
						ms.MaxbetCN88,
						ms.SpreadCN88
					FROM MatchSetting AS ms WITH (NOLOCK) INNER JOIN #tblMinorMatch AS tblMm WITH (NOLOCK)
						ON tblMm.MatchId=ms.OWPMatchId
				END
		END
	BEGIN
		INSERT INTO #tblMatchSetting(BettypeId, Maxbet, Spread, MaxbetCN88, SpreadCN88)
				SELECT DISTINCT ms.Bettype,
					ms.Maxbet,
					ms.Spread,
					ms.MaxbetCN88,
					ms.SpreadCN88
				FROM MatchSetting AS ms WITH (NOLOCK)
				WHERE ms.OWPMatchId=@MatchId
	END
	SELECT tblMs.BettypeId,
		tblMs.Maxbet,
		tblMs.Spread,
		tblMs.MaxbetCN88,
		tblMs.SpreadCN88
	FROM #tblMatchSetting AS tblMs
	
	DROP TABLE #tblMatchSetting
	DROP TABLE #tblMinorMatch
	
END