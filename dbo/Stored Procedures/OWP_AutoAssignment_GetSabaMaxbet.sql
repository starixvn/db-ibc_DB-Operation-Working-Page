/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROC [dbo].[OWP_AutoAssignment_GetSabaMaxbet]
	@MatchIds NVARCHAR(MAX)
AS
/*  
Created: 20211129@Luca.Duong
Task : Auto assignment get maxbet of saba
DB: bodb_OWP  
  
Revisions:  
	 20211129@Luca.Duong: Initial SP - [Redmine: #]
*/
BEGIN
	SET NOCOUNT ON;
	--
	CREATE TABLE #tblTempLeagueSetting(
		OWPLeagueId INT,
		MaxMaxbetWD_HDP MONEY,
		MaxMaxbetWD_OU MONEY,
		MaxMaxbetWD_1H MONEY,
		MaxMaxbetWK_HDP MONEY,
		MaxMaxbetWK_OU MONEY,
		MaxMaxbetWK_1H MONEY,
	);
	CREATE TABLE #tblMatch (
		Id INT,
		KoTime DATETIME,
		OWPLeagueId INT,
	);
	CREATE TABLE #tblFinalLeagueSetting (
		OWPLeagueId INT,
		MaxMaxbetWD MONEY,
		MaxMaxbetWK MONEY,
	)
	--
	INSERT INTO #tblMatch
	SELECT InfoSiteMatchId, EventDateTime, OWPLeagueId 
	FROM InfoSiteMatch
	WHERE InfoSiteMatchId IN (SELECT val FROM dbo.strSplit(@MatchIds,','))
    --
	INSERT INTO #tblTempLeagueSetting
	SELECT ls.OWPLeagueId,
		max(ls.MaxbetWD_HDP),
		max(ls.MaxbetWD_OU),
		max(ls.MaxbetWD_1H),
		max(ls.MaxbetWK_HDP),
		max(ls.MaxbetWK_OU),
		max(ls.MaxbetWK_1H)
	FROM #tblMatch AS m  WITH (NOLOCK)
		LEFT JOIN NewLeagueSetting AS ls WITH (NOLOCK)
		ON m.OWPLeagueId = ls.OWPLeagueId
	GROUP BY ls.OWPLeagueId;
    --
	INSERT INTO #tblFinalLeagueSetting
	SELECT OWPLeagueId,
		(SELECT Max(MaxbetWD)
			FROM (VALUES (MaxMaxbetWD_HDP), (MaxMaxbetWD_OU), (MaxMaxbetWD_1H)) AS value(MaxbetWD)),
		(SELECT Max(MaxbetWK)
			FROM (VALUES (MaxMaxbetWK_HDP), (MaxMaxbetWK_OU), (MaxMaxbetWK_1H)) AS value(MaxbetWK))
	FROM #tblTempLeagueSetting WITH (NOLOCK);
    --
	SELECT m.Id AS MatchId,
		CASE WHEN DATEPART(DW,m.KoTime + @@DATEFIRST - 1) > 5  
			 THEN ls.MaxMaxbetWK 
			 ELSE ls.MaxMaxbetWD 
		END AS MaxBet 
	FROM #tblMatch AS m WITH (NOLOCK)
		LEFT JOIN #tblFinalLeagueSetting AS ls WITH (NOLOCK)
		ON m.OWPLeagueId = ls.OWPLeagueId;
    --
	DROP TABLE #tblTempLeagueSetting;
	DROP TABLE  #tblMatch;
	DROP TABLE #tblFinalLeagueSetting;
END