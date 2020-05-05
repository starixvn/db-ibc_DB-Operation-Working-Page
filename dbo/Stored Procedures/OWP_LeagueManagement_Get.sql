
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_Get] @League NVARCHAR(500) = ''
	,@LeagueGroupId INT = -1
	,@Category NVARCHAR(50) = 'Live'
	,@IsActive BIT = 1
AS
/*
Created: 20200330@Tyler.Dang
Task : Get max bet, spread of league
DB: bodb_OWP

Revisions:
   20200330@Tyler.Dang: Init [Redmine: #131598]

*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblLeagueIds (
		OWPLeagueId INT,
		GroupValue INT,
		GroupLabel NVARCHAR(20),
		LeagueName NVARCHAR(500),
		IsActive BIT,
		IsBlackList BIT,
		OrderValue INT
		)

	CREATE TABLE #tblFinalLeagueSetting (
		OWPLeagueId INT,
		MinSpread MONEY,
		MaxSpread MONEY,
		MinMaxbetWD MONEY,
		MaxMaxbetWD MONEY,
		MinMaxbetWK MONEY,
		MaxMaxbetWK MONEY,
		MinFT1X2 MONEY,
		MaxFT1X2 MONEY,
		CN88MinSpread MONEY,
		CN88MaxSpread MONEY,
		CN88MinMaxbetWD MONEY,
		CN88MaxMaxbetWD MONEY,
		CN88MinMaxbetWK MONEY,
		CN88MaxMaxbetWK MONEY,
		CN88MinFT1X2 MONEY,
		CN88MaxFT1X2 MONEY
		)
	
	CREATE TABLE #tblLeagueLastUse (
		OWPLeagueId INT,
		LastUse DATETIME
		)
	
	CREATE TABLE #tblTempLeagueSetting(
		[OWPLeagueId] [int],
		[MaxSpread_HDP] [money],
		[MaxSpread_OU] [money],
		[MaxSpread_1HHDP] [money],
		[MaxSpread_1HOU] [money],
		[MaxMaxbetWD_HDP] [money],
		[MaxMaxbetWD_OU] [money],
		[MaxMaxbetWD_1H] [money],
		[MaxMaxbetWK_HDP] [money],
		[MaxMaxbetWK_OU] [money],
		[MaxMaxbetWK_1H] [money],
		[MaxMaxbet_FT1X2] [money],
		[MaxMaxbet_1H1X2] [money],
		[MaxCN88Spread_HDP] [money],
		[MaxCN88Spread_OU] [money],
		[MaxCN88Spread_1HHDP] [money],
		[MaxCN88Spread_1HOU] [money],
		[MaxCN88MaxbetWD_HDP] [money],
		[MaxCN88MaxbetWD_OU] [money],
		[MaxCN88MaxbetWD_1H] [money],
		[MaxCN88MaxbetWK_HDP] [money],
		[MaxCN88MaxbetWK_OU] [money],
		[MaxCN88MaxbetWK_1H] [money],
		[MaxCN88MaxBet_FT1X2] [money],
		[MaxCN88MaxBet_1H1X2] [money],
		[MinSpread_HDP] [money],
		[MinSpread_OU] [money],
		[MinSpread_1HHDP] [money],
		[MinSpread_1HOU] [money],
		[MinMaxbetWD_HDP] [money],
		[MinMaxbetWD_OU] [money],
		[MinMaxbetWD_1H] [money],
		[MinMaxbetWK_HDP] [money],
		[MinMaxbetWK_OU] [money],
		[MinMaxbetWK_1H] [money],
		[MinMaxBet_FT1X2] [money],
		[MinMaxBet_1H1X2] [money],
		[MinCN88Spread_HDP] [money],
		[MinCN88Spread_OU] [money],
		[MinCN88Spread_1HHDP] [money],
		[MinCN88Spread_1HOU] [money],
		[MinCN88MaxbetWD_HDP] [money],
		[MinCN88MaxbetWD_OU] [money],
		[MinCN88MaxbetWD_1H] [money],
		[MinCN88MaxbetWK_HDP] [money],
		[MinCN88MaxbetWK_OU] [money],
		[MinCN88MaxbetWK_1H] [money],
		[MinCN88MaxBet_FT1X2] [money],
		[MinCN88MaxBet_1H1X2] [money]
	)

	-- Filter league
	INSERT INTO #tblLeagueIds(
		OWPLeagueId,
		GroupValue,
		GroupLabel,
		LeagueName,
		IsActive,
		IsBlackList,
		OrderValue
	)
	SELECT owpl.OWPLeagueId,
		owpl.CategoryId,
		ref.Value,
		owpl.OWPLeagueName,
		owpl.IsActive,
		owpl.IsBlackList,
		'OrderValue' = CASE WHEN owpl.CategoryId IS NULL THEN 100 ELSE owpl.CategoryId END
	FROM OWPLeague AS owpl WITH (NOLOCK)
		LEFT JOIN RefResource AS ref WITH (NOLOCK)
			ON ref.RefName='LeagueCategory' AND ref.ResourceId = owpl.CategoryId
	WHERE owpl.OWPLeagueName LIKE '%'+@League+'%'
		AND (owpl.CategoryId=@LeagueGroupId OR @LeagueGroupId=-1 OR (@LeagueGroupId=0 AND owpl.CategoryId IS NULL))
		AND owpl.IsActive=@IsActive
		AND SUBSTRING(owpl.OWPLeagueName,CHARINDEX('-', owpl.OWPLeagueName)+2, LEN(owpl.OWPLeagueName))
			 NOT IN (SELECT mb.MinorBettypeName FROM MinorBettype AS mb WITH (NOLOCK))

	-- Calculate min max
	INSERT INTO #tblTempLeagueSetting(
		[OWPLeagueId],
		[MaxSpread_HDP],
		[MaxSpread_OU],
		[MaxSpread_1HHDP],
		[MaxSpread_1HOU],
		[MaxMaxbetWD_HDP],
		[MaxMaxbetWD_OU],
		[MaxMaxbetWD_1H],
		[MaxMaxbetWK_HDP],
		[MaxMaxbetWK_OU],
		[MaxMaxbetWK_1H],
		[MaxMaxbet_FT1X2],
		[MaxMaxbet_1H1X2],
		[MaxCN88Spread_HDP],
		[MaxCN88Spread_OU],
		[MaxCN88Spread_1HHDP],
		[MaxCN88Spread_1HOU],
		[MaxCN88MaxbetWD_HDP],
		[MaxCN88MaxbetWD_OU],
		[MaxCN88MaxbetWD_1H],
		[MaxCN88MaxbetWK_HDP],
		[MaxCN88MaxbetWK_OU],
		[MaxCN88MaxbetWK_1H],
		[MaxCN88MaxBet_FT1X2],
		[MaxCN88MaxBet_1H1X2],
		[MinSpread_HDP],
		[MinSpread_OU],
		[MinSpread_1HHDP],
		[MinSpread_1HOU],
		[MinMaxbetWD_HDP],
		[MinMaxbetWD_OU],
		[MinMaxbetWD_1H],
		[MinMaxbetWK_HDP],
		[MinMaxbetWK_OU],
		[MinMaxbetWK_1H],
		[MinMaxBet_FT1X2],
		[MinMaxBet_1H1X2],
		[MinCN88Spread_HDP],
		[MinCN88Spread_OU],
		[MinCN88Spread_1HHDP],
		[MinCN88Spread_1HOU],
		[MinCN88MaxbetWD_HDP],
		[MinCN88MaxbetWD_OU],
		[MinCN88MaxbetWD_1H],
		[MinCN88MaxbetWK_HDP],
		[MinCN88MaxbetWK_OU],
		[MinCN88MaxbetWK_1H],
		[MinCN88MaxBet_FT1X2],
		[MinCN88MaxBet_1H1X2]
	)
	SELECT owpl.OWPLeagueId,
		max(ls.Spread_HDP),
		max(ls.Spread_OU),
		max(ls.Spread_1HHDP),
		max(ls.Spread_1HOU),
		max(ls.MaxbetWD_HDP),
		max(ls.MaxbetWD_OU),
		max(ls.MaxbetWD_1H),
		max(ls.MaxbetWK_HDP),
		max(ls.MaxbetWK_OU),
		max(ls.MaxbetWK_1H),
		max(ls.MaxBet_FT1X2),
		max(ls.MaxBet_1H1X2),
		max(ls.CN88Spread_HDP),
		max(ls.CN88Spread_OU),
		max(ls.CN88Spread_1HHDP),
		max(ls.CN88Spread_1HOU),
		max(ls.CN88MaxbetWD_HDP),
		max(ls.CN88MaxbetWD_OU),
		max(ls.CN88MaxbetWD_1H),
		max(ls.CN88MaxbetWK_HDP),
		max(ls.CN88MaxbetWK_OU),
		max(ls.CN88MaxbetWK_1H),
		max(ls.CN88MaxBet_FT1X2),
		max(ls.CN88MaxBet_1H1X2),
		min(ls.Spread_HDP),
		min(ls.Spread_OU),
		min(ls.Spread_1HHDP),
		min(ls.Spread_1HOU),
		min(ls.MaxbetWD_HDP),
		min(ls.MaxbetWD_OU),
		min(ls.MaxbetWD_1H),
		min(ls.MaxbetWK_HDP),
		min(ls.MaxbetWK_OU),
		min(ls.MaxbetWK_1H),
		min(ls.MaxBet_FT1X2),
		min(ls.MaxBet_1H1X2),
		min(ls.CN88Spread_HDP),
		min(ls.CN88Spread_OU),
		min(ls.CN88Spread_1HHDP),
		min(ls.CN88Spread_1HOU),
		min(ls.CN88MaxbetWD_HDP),
		min(ls.CN88MaxbetWD_OU),
		min(ls.CN88MaxbetWD_1H),
		min(ls.CN88MaxbetWK_HDP),
		min(ls.CN88MaxbetWK_OU),
		min(ls.CN88MaxbetWK_1H),
		min(ls.CN88MaxBet_FT1X2),
		min(ls.CN88MaxBet_1H1X2)
	FROM #tblLeagueIds AS owpl WITH (NOLOCK)
		LEFT JOIN NewLeagueSetting AS ls WITH (NOLOCK)
			ON owpl.OWPLeagueId = ls.OWPLeagueId
	WHERE ls.Category = @Category
	GROUP BY owpl.OWPLeagueId

	-- Calculate LastUse
	INSERT INTO #tblLeagueLastUse(
		OWPLeagueId,
		LastUse
	)
	SELECT owpl.OWPLeagueId,
		max(owpm.EventDate)
	FROM #tblLeagueIds AS owpl WITH (NOLOCK)
		LEFT JOIN OWPMatch AS owpm WITH (NOLOCK)
			ON owpl.OWPLeagueId = owpm.OWPLeagueId
	GROUP BY owpl.OWPLeagueId

	INSERT INTO #tblFinalLeagueSetting(
		OWPLeagueId,
		MinSpread,
		MaxSpread,
		MinMaxbetWD,
		MaxMaxbetWD,
		MinMaxbetWK,
		MaxMaxbetWK,
		MinFT1X2,
		MaxFT1X2,
		CN88MinSpread,
		CN88MaxSpread,
		CN88MinMaxbetWD,
		CN88MaxMaxbetWD,
		CN88MinMaxbetWK,
		CN88MaxMaxbetWK,
		CN88MinFT1X2,
		CN88MaxFT1X2
	)
	SELECT OWPLeagueId,
		(SELECT Min(Spread) 
			FROM (VALUES (MinSpread_HDP), (MinSpread_OU), (MinSpread_1HHDP), (MinSpread_1HOU)) AS value(Spread)),
		(SELECT Max(Spread)
			FROM (VALUES (MaxSpread_HDP), (MaxSpread_OU), (MaxSpread_1HHDP), (MaxSpread_1HOU)) AS value(Spread)),
		(SELECT Min(MaxbetWD) 
			FROM (VALUES (MinMaxbetWD_HDP), (MinMaxbetWD_OU), (MinMaxbetWD_1H)) AS value(MaxbetWD)),
		(SELECT Max(MaxbetWD)
			FROM (VALUES (MaxMaxbetWD_HDP), (MaxMaxbetWD_OU), (MaxMaxbetWD_1H)) AS value(MaxbetWD)),
		(SELECT Min(MaxbetWK) 
			FROM (VALUES (MinMaxbetWK_HDP), (MinMaxbetWK_OU), (MinMaxbetWK_1H)) AS value(MaxbetWK)),
		(SELECT Max(MaxbetWK)
			FROM (VALUES (MaxMaxbetWK_HDP), (MaxMaxbetWK_OU), (MaxMaxbetWK_1H)) AS value(MaxbetWK)),
		(SELECT Min(FT1X2) 
			FROM (VALUES (MinMaxBet_FT1X2), (MaxMaxbet_1H1X2)) AS value(FT1X2)),
		(SELECT Max(FT1X2)
			FROM (VALUES (MaxMaxbet_FT1X2), (MaxMaxbet_1H1X2)) AS value(FT1X2)),
		(SELECT Min(CN88Spread) 
			FROM (VALUES (MinCN88Spread_HDP), (MinCN88Spread_OU), (MinCN88Spread_1HHDP), (MinCN88Spread_1HOU)) AS value(CN88Spread)),
		(SELECT Max(CN88Spread)
			FROM (VALUES (MaxCN88Spread_HDP), (MaxCN88Spread_OU), (MaxCN88Spread_1HHDP), (MaxCN88Spread_1HOU)) AS value(CN88Spread)),
		(SELECT Min(CN88MaxbetWD) 
			FROM (VALUES (MinCN88MaxbetWD_HDP), (MinCN88MaxbetWD_OU), (MinCN88MaxbetWD_1H)) AS value(CN88MaxbetWD)),
		(SELECT Max(CN88MaxbetWD)
			FROM (VALUES (MaxCN88MaxbetWD_HDP), (MaxCN88MaxbetWD_OU), (MaxCN88MaxbetWD_1H)) AS value(CN88MaxbetWD)),
		(SELECT Min(CN88MaxbetWK) 
			FROM (VALUES (MinCN88MaxbetWK_HDP), (MinCN88MaxbetWK_OU), (MinCN88MaxbetWK_1H)) AS value(CN88MaxbetWK)),
		(SELECT Max(CN88MaxbetWK)
			FROM (VALUES (MaxCN88MaxbetWK_HDP), (MaxCN88MaxbetWK_OU), (MaxCN88MaxbetWK_1H)) AS value(CN88MaxbetWK)),
		(SELECT Min(CN88MaxBet) 
			FROM (VALUES (MinCN88MaxBet_FT1X2), (MinCN88MaxBet_1H1X2)) AS value(CN88MaxBet)),
		(SELECT Max(CN88MaxBet)
			FROM (VALUES (MaxCN88MaxBet_FT1X2), (MaxCN88MaxBet_1H1X2)) AS value(CN88MaxBet))
	FROM #tblTempLeagueSetting WITH (NOLOCK)

	SELECT owpl.OWPLeagueId,
		owpl.GroupValue,
		owpl.GroupLabel,
		owpl.LeagueName,
		owpl.IsActive,
		owpl.IsBlackList,
		ls.MinSpread,
		ls.MaxSpread,
		ls.MinMaxbetWD,
		ls.MaxMaxbetWD,
		ls.MinMaxbetWK,
		ls.MaxMaxbetWK,
		ls.MinFT1X2,
		ls.MaxFT1X2,
		ls.CN88MinSpread,
		ls.CN88MaxSpread,
		ls.CN88MinMaxbetWD,
		ls.CN88MaxMaxbetWD,
		ls.CN88MinMaxbetWK,
		ls.CN88MaxMaxbetWK,
		ls.CN88MinFT1X2,
		ls.CN88MaxFT1X2,
		llu.LastUse
	FROM #tblLeagueIds AS owpl WITH (NOLOCK)
		LEFT JOIN #tblFinalLeagueSetting AS ls WITH (NOLOCK)
			ON owpl.OWPLeagueId = ls.OWPLeagueId
		LEFT JOIN #tblLeagueLastUse AS llu WITH (NOLOCK)
			ON owpl.OWPLeagueId = llu.OWPLeagueId	
	ORDER BY owpl.OrderValue ASC, owpl.LeagueName ASC

	DROP TABLE #tblLeagueIds
	DROP TABLE #tblTempLeagueSetting
	DROP TABLE #tblFinalLeagueSetting
	DROP TABLE #tblLeagueLastUse
END