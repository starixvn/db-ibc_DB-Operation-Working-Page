
CREATE PROCEDURE [dbo].[OWP_MaxBetManagement_Get_New] @League NVARCHAR(500) = ''
	,@LeagueGroupId INT = -1
	,@LeagueCategoryId INT = 1
	,@IsActive BIT = 1
AS
/*
Created: 20200330@Tyler.Dang
Task : Get max bet, spread of league
DB: bodb_OWP

Revisions:
   20200330@Tyler.Dang: Init

*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblLeagueIds (
		OWPLeagueId INT,
		GroupValue INT,
		GroupLabel NVARCHAR(20),
		LeagueName NVARCHAR(500),
		IsActive BIT,
		IsBlackList BIT
		)

	CREATE TABLE #tblLeagueSetting (
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
	
	-- Filter league
	INSERT INTO #tblLeagueIds(
		OWPLeagueId,
		GroupValue,
		GroupLabel,
		LeagueName,
		IsActive,
		IsBlackList
	)
	SELECT owpl.OWPLeagueId,
		owpl.CategoryId,
		ref.Value,
		owpl.OWPLeagueName,
		owpl.IsActive,
		owpl.IsBlackList
	FROM OWPLeague AS owpl WITH (NOLOCK)
		LEFT JOIN RefResource AS ref WITH (NOLOCK)
			ON ref.RefName='LeagueCategory' AND ref.ResourceId = owpl.CategoryId
	WHERE owpl.OWPLeagueName LIKE '%'+@League+'%'
		AND (owpl.CategoryId=@LeagueGroupId OR @LeagueGroupId=-1 OR (@LeagueGroupId=0 AND owpl.CategoryId IS NULL))
		AND owpl.IsActive=@IsActive
		AND SUBSTRING(owpl.OWPLeagueName,CHARINDEX('-', owpl.OWPLeagueName)+2, LEN(owpl.OWPLeagueName))
			 NOT IN (SELECT mb.MinorBettypeName FROM MinorBettype AS mb WITH (NOLOCK))
	ORDER BY owpl.CategoryId DESC

	-- Calculate min max
	INSERT INTO #tblLeagueSetting(
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
	SELECT owpl.OWPLeagueId AS LeagueId,
		min(ls.Spread_HDP) as MinSpread,
		max(ls.Spread_HDP) as MaxSpread,
		min(ls.MaxbetWD_HDP) as MinMaxbetWD,
		max(ls.MaxbetWD_HDP) as MaxMaxbetWD,
		min(ls.MaxbetWK_HDP) as MinMaxbetWK,
		max(ls.MaxbetWK_HDP) as MaxMaxbetWK,
		min(ls.MaxBet_FT1X2) as MinFT1X2,
		max(ls.MaxBet_FT1X2) as MaxFT1X2,
		min(ls.CN88Spread_HDP) as CN88MinSpread,
		max(ls.CN88Spread_HDP) as CN88MaxSpread,
		min(ls.CN88MaxbetWD_HDP) as CN88MinMaxbetWD,
		max(ls.CN88MaxbetWD_HDP) as CN88MaxMaxbetWD,
		min(ls.CN88MaxbetWK_HDP) as CN88MinMaxbetWK,
		max(ls.CN88MaxbetWK_HDP) as CN88MaxMaxbetWK,
		min(ls.CN88MaxBet_FT1X2) as CN88MinFT1X2,
		max(ls.CN88MaxBet_FT1X2) as CN88MaxFT1X2
	FROM #tblLeagueIds AS owpl WITH (NOLOCK)
		LEFT JOIN NewLeagueSetting AS ls WITH (NOLOCK)
			ON owpl.OWPLeagueId = ls.OWPLeagueId
	WHERE ls.OptionId = @LeagueCategoryId
	GROUP BY owpl.OWPLeagueId

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
		ls.CN88MaxFT1X2
	FROM #tblLeagueIds AS owpl WITH (NOLOCK)
		LEFT JOIN #tblLeagueSetting AS ls WITH (NOLOCK)
			ON owpl.OWPLeagueId = ls.OWPLeagueId
			
	DROP TABLE #tblLeagueIds
	DROP TABLE #tblLeagueSetting
END