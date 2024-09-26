/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MatchSetting_GetByMatchId] @OWPMatchId int
AS	
/*
Created: 20180807@Leo
Task : Get match setting
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20190712@Tyler.Dang: WEB - Add MaxbetCN88 and SpreadCN88 LiveDetails - [Redmine: #116790]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @LeagueId INT
		,@MaxBetHDP MONEY

	SELECT @LeagueId = OWPLeagueId
	FROM dbo.OWPMatch WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId

	CREATE TABLE #tblMatchSetting (
		OWPMatchId INT
		,Bettype INT
		,MinorBettypeId INT
		,DisplayName VARCHAR(50)
		,Maxbet MONEY
		,Spread SMALLMONEY 
		,IsFromMaxbetSetting BIT DEFAULT(0)
		)

	-- get match setting of marjor bettype
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,Bettype
		,DisplayName
		,Maxbet
		,Spread 
		)
	SELECT ms.OWPMatchId
		,ms.Bettype
		,mb.ShortName
		,ms.Maxbet
		,ms.Spread 
	FROM dbo.MatchSetting AS ms WITH (NOLOCK)
		INNER JOIN dbo.MajorBettype AS mb WITH (NOLOCK) ON ms.Bettype = mb.BettypeId
	WHERE ms.OWPMatchId = @OWPMatchId

	-- insert major bettypes not be set
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,Bettype
		,DisplayName
		)
	SELECT @OWPMatchId
		,ls.BettypeId
		,ls.ShortName
	FROM (
		SELECT BettypeId
			,ShortName
		FROM dbo.MajorBettype WITH (NOLOCK)
		WHERE BettypeId <> - 1002
		) AS ls
	WHERE NOT EXISTS (
			SELECT 1
			FROM #tblMatchSetting AS ms
			WHERE ms.Bettype = ls.BettypeId
			)

	-- update default Spread & MaxBet of major bettype not be set
	UPDATE ms
	SET ms.MaxBet = dbo.OWP_MaxBetGet(@OWPMatchId, @LeagueId, ms.Bettype)
		,ms.Spread = dbo.OWP_SpreadGet(@OWPMatchId, @LeagueId, ms.Bettype)
		,ms.IsFromMaxbetSetting = 1
	FROM #tblMatchSetting AS ms
	WHERE ms.MaxBet IS NULL
		AND ms.Spread IS NULL

	-- get match setting of minor bettype
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,Bettype
		,MinorBettypeId
		,DisplayName
		,Maxbet
		,Spread 
		)
	SELECT mm.MinorMatchId
		,mb.InheritedBettypeId
		,mb.ParentBettypeId
		,mb.MinorBettypeName
		,ms.Maxbet
		,ms.Spread 
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON m.OWPMatchId = @OWPMatchId
		AND m.OWPMatchId = mm.ParentMatchId
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.IsActive = 1
		AND mm.MinorBettypeId = mb.ParentBettypeId
		AND mb.InheritedBettypeId <> - 1002
		LEFT JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON ms.OWPMatchId = mm.MinorMatchId
		AND ms.Bettype = mb.InheritedBettypeId

	--Get MaxBetHDP
	SELECT @MaxBetHDP = Maxbet
	FROM #tblMatchSetting
	WHERE Bettype = 1
		AND MinorBettypeId IS NULL

	IF @MaxBetHDP IS NOT NULL
	BEGIN
		UPDATE tms
		SET tms.MaxBet = ms.MaxBet
			,tms.Spread = ms.Spread
			,tms.IsFromMaxbetSetting = 1
		FROM #tblMatchSetting AS tms
			INNER JOIN (
			SELECT mb.ParentBettypeId AS MinorBettypeId
				,mb.InheritedBettypeId AS Bettype
				,msd.MaxBet
				,msd.Spread
			FROM dbo.MinorSettingDetail AS msd WITH (NOLOCK)
				INNER JOIN dbo.MinorSetting AS ms WITH (NOLOCK) ON msd.MinorSettingId = ms.MinorSettingId
				AND (
					ms.FromMaxBet IS NULL
					OR @MaxBetHDP >= ms.FromMaxBet
					)
				AND (
					ms.ToMaxBet IS NULL
					OR @MaxBetHDP <= ms.ToMaxBet
					)
				INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mb.IsActive = 1
				AND mb.ParentBettypeId = msd.MinorBettypeId
			) AS ms ON tms.MinorBettypeId = ms.MinorBettypeId
			AND tms.Bettype = ms.Bettype
		WHERE tms.MaxBet IS NULL
			AND tms.Spread IS NULL
	END

	SELECT OWPMatchId
		,Bettype
		,MinorBettypeId
		,DisplayName
		,Maxbet
		,Spread 
		,IsFromMaxbetSetting
	FROM #tblMatchSetting

	DROP TABLE #tblMatchSetting
END