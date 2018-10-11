/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Get] @Date DATE
	,@League NVARCHAR(500) = ''
	,@PageIndex INT = NULL
	,@ItemsPerPage INT = NULL
	,@TotalItem INT = NULL OUT
AS
/*          
 Created: 20170317@Alvin.Nguyen
 Task : get odds compiler
 DB: bodb_OWP
          
 Revisions:
    20170421@Tim.Trinh: refactor code
	20180131@Raymone.Le: show match when match status is Live
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Tomorrow DATE = DATEADD(DAY, 1, @Date)
	DECLARE @Handicap TINYINT = 1
		,@OverUnder TINYINT = 3
		,@1X2 TINYINT = 5

	CREATE TABLE #tblMatchId (
		RowIndex INT
		,OWPMatchId INT
		)

	CREATE TABLE #tblFinalMatchId (OWPMatchId INT)

	CREATE TABLE #tblMatch (
		OWPMatchId INT
		,MatchNo VARCHAR(50)
		,KickOffTime TIME
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		)

	CREATE TABLE #tblFinalMatch (
		OWPMatchId INT
		,MatchNo VARCHAR(50)
		,KickOffTime TIME
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		)

	CREATE TABLE #tblMatchSetting (
		OWPMatchId INT
		,LeagueId INT
		,Bettype INT
		,MaxBet MONEY
		,Spread SMALLMONEY
		,IsMatchSetting BIT
		)

	-- get match
	INSERT INTO #tblMatch (
		OWPMatchId
		,MatchNo
		,KickOffTime
		,League
		,Home
		,Away
		)
	SELECT m.OWPMatchId
		,m.MatchNo
		,m.KickOffTime
		,League.OWPLeagueName
		,home.OWPTeamName
		,away.OWPTeamName
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON m.OWPMatchId = info.OWPMatchId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = m.OWPHomeId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = m.OWPAwayId
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON m.OWPLeagueId = league.OWPLeagueId
		LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON m.OWPMatchId = minor.MinorMatchId
	WHERE info.MatchStatus = 'Live'
		AND info.IsSelected = 1
		AND league.OWPLeagueName LIKE + '%' + ISNULL(@League, '') + '%'
		AND (
			(
				m.EventDate = @Date
				AND m.KickOffTime >= '12:00:00'
				)
			OR (
				m.EventDate = @Tomorrow
				AND m.KickOffTime < '12:00:00'
				)
			)
		AND minor.MinorMatchId IS NULL

	--insert match setting
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,Bettype
		,MaxBet
		,Spread
		,IsMatchSetting
		)
	SELECT m.OWPMatchId
		,ms.Bettype
		,ms.Maxbet
		,ms.Spread
		,1
	FROM #tblMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
	WHERE ms.Bettype IN (@Handicap, @OverUnder)

	--insert league setting
	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,LeagueId
		,Bettype
		,Maxbet
		,Spread
		,IsMatchSetting
		)
	SELECT OWPMatchId
		,OWPLeagueId
		,tb2.Bettype
		,ls.Maxbet
		,ls1.Spread
		,0
	FROM (
		SELECT OWPMatchId
			,OWPLeagueId
			,Bettype
			,POWER(2 * wd, 1) + POWER(2 * wk, 2) + POWER(2 * tv, 3) + POWER(2 * ukrb, 4) AS MaxBetOption
			,POWER(2 * tv, 3) + POWER(2 * ukrb, 4) AS SpreadOption
		FROM (
			SELECT OWPMatchId
				,OWPLeagueId
				,Bettype
				,CASE ISNULL(DATEPART(dw, OnDate), - 1)
					WHEN 1 THEN 0
					WHEN 2 THEN 1
					WHEN 3 THEN 1
					WHEN 4 THEN 1
					WHEN 5 THEN 1
					WHEN 6 THEN 1
					WHEN 7 THEN 0
					END AS wd
				,CASE ISNULL(DATEPART(dw, OnDate), - 1)
					WHEN 1 THEN 1
					WHEN 2 THEN 0
					WHEN 3 THEN 0
					WHEN 4 THEN 0
					WHEN 5 THEN 0
					WHEN 6 THEN 0
					WHEN 7 THEN 1
					END AS wk
				,tv
				,CASE 
					WHEN tv = 1
						AND ukrb = 1 THEN 0
					ELSE ukrb
					END AS ukrb
			FROM (
				SELECT m.OWPMatchId
					,m.OWPLeagueId
					,ls.Bettype
					,DATEADD(dd, DATEDIFF(dd, 0, m.EventDate), CAST(m.KickOffTime AS DATETIME)) AS OnDate
					,(CASE 
						WHEN NULLIF(mif.TVCode, '') IS NOT NULL THEN 1
						ELSE 0 END
						) AS tv
					,(CASE 
						WHEN NULLIF(mif.Channel, '') IS NOT NULL
							OR NULLIF(mif.Provider, '') IS NOT NULL THEN 1
						ELSE 0 END
						) AS ukrb
				FROM #tblMatch AS mt WITH (NOLOCK)
					INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON mt.OWPMatchId = m.OWPMatchId
					INNER JOIN dbo.MatchInfo AS mif WITH (NOLOCK) ON m.OWPMatchId = mif.OWPMatchId
					INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON m.OWPLeagueId = ls.LeagueId
				WHERE m.OWPMatchId NOT IN (
						SELECT OWPMatchId
						FROM #tblMatchSetting WITH (NOLOCK)
						)
					AND ls.Bettype IN (@Handicap, @OverUnder)
				GROUP BY m.OWPMatchId
					,m.OWPleagueid
					,ls.Bettype
					,m.EventDate
					,m.KickOffTime
					,mif.TVCode
					,mif.Channel
					,mif.Provider
				) AS tb
			) AS tb1
		) AS tb2
		LEFT JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON ls.LeagueId = tb2.OWPLeagueId
		AND ls.OptionsId = tb2.MaxBetOption
		AND ls.Bettype = tb2.Bettype
		LEFT JOIN dbo.LeagueSetting AS ls1 WITH (NOLOCK) ON ls1.LeagueId = tb2.OWPLeagueId
		AND ls1.OptionsId = tb2.SpreadOption
		AND ls1.Bettype = tb2.Bettype

	INSERT INTO #tblFinalMatch (
		OWPMatchId
		,MatchNo
		,KickOffTime
		,League
		,Home
		,Away
		)
	SELECT DISTINCT m.OWPMatchId
		,MatchNo
		,KickOffTime
		,League
		,Home
		,Away
	FROM #tblMatch AS m WITH (NOLOCK)
		LEFT JOIN #tblMatchSetting AS ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId

	INSERT INTO #tblMatchId (
		RowIndex
		,OWPMatchId
		)
	SELECT DISTINCT ROW_NUMBER() OVER (
			ORDER BY KickOffTime
			)
		,OWPMatchId
	FROM #tblFinalMatch WITH (NOLOCK)

	IF @PageIndex IS NOT NULL
		AND @ItemsPerPage IS NOT NULL
	BEGIN
		INSERT INTO #tblFinalMatchId (OWPMatchId)
		SELECT OWPMatchId
		FROM #tblMatchId WITH (NOLOCK)
		WHERE RowIndex BETWEEN ((@PageIndex - 1) * @ItemsPerPage + 1)
				AND (@PageIndex * @ItemsPerPage)
	END
	ELSE
	BEGIN
		INSERT INTO #tblFinalMatchId (OWPMatchId)
		SELECT OWPMatchId
		FROM #tblMatchId WITH (NOLOCK)
	END

	--get matchs
	SELECT m.OWPMatchId
		,MatchNo
		,KickOffTime
		,League
		,Home
		,Away
	FROM #tblFinalMatch AS m WITH (NOLOCK)
		INNER JOIN #tblFinalMatchId AS mid WITH (NOLOCK) ON m.OWPMatchId = mid.OWPMatchId
	ORDER BY KickOffTime

	--get match settings
	SELECT m.OWPMatchId
		,ms.Bettype
		,ms.Maxbet
		,ms.Spread
	FROM #tblFinalMatch AS m WITH (NOLOCK)
		INNER JOIN #tblFinalMatchId AS mid WITH (NOLOCK) ON m.OWPMatchId = mid.OWPMatchId
		INNER JOIN #tblMatchSetting AS ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
	WHERE ms.Bettype IN (@Handicap, @OverUnder)
		AND (
			ms.Maxbet IS NOT NULL
			OR ms.Spread IS NOT NULL
			)

	--get recommend odds
	SELECT mr.MatchRecommendOddsId AS Id
		,mr.OWPMatchId
		,mr.Bettype
		,mr.HDP AS Handicap
		,mr.TeamChoice
		,mrd.Choice
		,mrd.Odds
	FROM #tblFinalMatchId AS mid WITH (NOLOCK)
		INNER JOIN dbo.MatchRecommendOdds AS mr WITH (NOLOCK) ON mid.OWPMatchId = mr.OWPMatchId
		LEFT JOIN dbo.MatchRecommendOddsDetail AS mrd WITH (NOLOCK) ON mr.MatchRecommendOddsId = mrd.MatchRecommendOddsId
	WHERE mr.Bettype IN (@Handicap, @OverUnder, @1X2)
	ORDER BY mr.MatchRecommendOddsId

	-- total item
	SELECT @TotalItem = COUNT(1)
	FROM #tblMatchId

	DROP TABLE #tblMatch

	DROP TABLE #tblMatchId

	DROP TABLE #tblFinalMatchId

	DROP TABLE #tblFinalMatch

	DROP TABLE #tblMatchSetting
END