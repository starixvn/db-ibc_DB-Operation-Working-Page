
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_API_AdminsiteIntegration_GetSpread] @MatchId INT
AS
/*
Created: 20201203@Carlos.Nguyen
Task: Get spread
DB: bodb_OWP

Revisions:
	20201203@Carlos.Nguyen: Get spread - [Redmine: #145096]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @HandicapHDP INT = 1
		,@OverUnderOU INT = 3
		,@1H_HandicapHDP INT = 7
		,@1H_OverUnder INT = 8
		,@LeagueCategoryId_MJ INT = 1
	
	CREATE TABLE #tblMatchInfo(
		bettypeId INT,
		spread MONEY
	)
	
	-- FT HDP, FT OU, 1H HDP, 1H OU
		INSERT INTO #tblMatchInfo(
			bettypeId,
			spread
		)
		SELECT ms.Bettype,
			ms.Spread
		FROM MatchSetting AS ms WITH (NOLOCK)
		WHERE ms.Bettype IN (@HandicapHDP, @OverUnderOU, @1H_HandicapHDP, @1H_OverUnder) AND ms.OWPMatchId=@MatchId

	-- Match (MJ)
	IF EXISTS (SELECT 1
		FROM OWPLeague AS ol WITH (NOLOCK)
		INNER JOIN OWPMatch AS om WITH (NOLOCK) ON ol.OWPLeagueId=om.OWPLeagueId
		WHERE ol.CategoryId=@LeagueCategoryId_MJ AND om.OWPMatchId=@MatchId)
	BEGIN
		-- Value @1H_HandicapHDP follow FT HDP if not exists
		IF NOT EXISTS (SELECT 1
			FROM #tblMatchInfo AS tblm WITH (NOLOCK)
			WHERE tblm.bettypeId=@1H_HandicapHDP)
		BEGIN
			INSERT INTO #tblMatchInfo(
				bettypeId,
				spread
			)
			SELECT @1H_HandicapHDP,
				tblm.spread
			FROM #tblMatchInfo AS tblm WITH (NOLOCK)
			WHERE tblm.bettypeId = @HandicapHDP
		END
		
		-- Value @1H_OU follow FT OU if not exists
		IF NOT EXISTS (SELECT 1
			FROM #tblMatchInfo AS tblm WITH (NOLOCK)
			WHERE tblm.bettypeId=@1H_OverUnder)
		BEGIN
			INSERT INTO #tblMatchInfo(
				bettypeId,
				spread
			)
			SELECT @1H_OverUnder,
				tblm.spread
			FROM #tblMatchInfo AS tblm WITH (NOLOCK)
			WHERE tblm.bettypeId = @OverUnderOU
		END
	END
	ELSE -- Not MJ
	BEGIN
		-- Value @1H_HandicapHDP not exists
		IF NOT EXISTS (SELECT 1
			FROM #tblMatchInfo AS tblm WITH (NOLOCK)
			WHERE tblm.bettypeId=@1H_HandicapHDP)
		BEGIN
			-- Value @1H_HandicapHDP is 0.1 when spread FT HDP <10%
			IF EXISTS (SELECT 1
				FROM #tblMatchInfo AS tblm WITH (NOLOCK)
				WHERE tblm.bettypeId=@HandicapHDP AND tblm.spread<0.1 AND tblm.spread IS NOT NULL)
			BEGIN
				INSERT INTO #tblMatchInfo(
					bettypeId,
					spread
				)
				VALUES (@1H_HandicapHDP,0.1)
			END
			ELSE -- Value @1H_HandicapHDP follow FT HDP
			BEGIN
				INSERT INTO #tblMatchInfo(
					bettypeId,
					spread
				)
				SELECT @1H_HandicapHDP,
					tblm.spread
				FROM #tblMatchInfo AS tblm WITH (NOLOCK)
				WHERE tblm.bettypeId = @HandicapHDP
			END
		END
		
		-- Value @1H_OU not exists
		IF NOT EXISTS (SELECT 1
			FROM #tblMatchInfo AS tblm WITH (NOLOCK)
			WHERE tblm.bettypeId=@1H_OverUnder)
		BEGIN
			-- Value @1H_OU is 0.1 when spread FT OU <10%
			IF EXISTS (SELECT 1
				FROM #tblMatchInfo AS tblm WITH (NOLOCK)
				WHERE tblm.bettypeId=@OverUnderOU AND tblm.spread<0.1 AND tblm.spread IS NOT NULL)
			BEGIN
				INSERT INTO #tblMatchInfo(
					bettypeId,
					spread
				)
				VALUES (@1H_OverUnder,0.1)
			END
			ELSE -- Value @1H_OU follow FT OU
			BEGIN
				INSERT INTO #tblMatchInfo(
					bettypeId,
					spread
				)
				SELECT @1H_OverUnder,
					tblm.spread
				FROM #tblMatchInfo AS tblm WITH (NOLOCK)
				WHERE tblm.bettypeId = @OverUnderOU
			END
		END
	END
	
	SELECT tblmi.bettypeId,
			tblmi.spread
	FROM #tblMatchInfo AS tblmi
		
	DROP TABLE #tblMatchInfo
END