/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OddsCompiler_Get] @Date DATE
	,@League NVARCHAR(500) = ''
AS
/*          
 Created: 20170317@Alvin.Nguyen
 Task : get odds compiler
 DB: bodb_OWP
          
 Revisions:
    20170421@Tim.Trinh: refactor code
	20180131@Raymone.Le: show match when match status is Live
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181120@Raymond.Le: Add more info to Odds Compiler - [Redmine: #105043]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
	20190513@Kane.Le: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
	20191024@Kane.Le: Get Provider/Other Provider - [Redmine: #122194]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Tomorrow DATE = DATEADD(DAY, 1, @Date)
	DECLARE @Handicap TINYINT = 1
		,@OverUnder TINYINT = 3
		,@1X2 TINYINT = 5

	CREATE TABLE #tblMatch (
		OWPMatchId INT
		,MatchNo VARCHAR(50)
		,KickOffTime TIME
		,League NVARCHAR(2000)
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,Remark NVARCHAR(2000)
		,[Round] NVARCHAR(2000)
		,Division NVARCHAR(2000)
		,[Provider] NVARCHAR(MAX)
		,WatchBet NVARCHAR(100)
		,OtherProvider NVARCHAR(MAX)
		,Website1 NVARCHAR(1000)
		,Website2 NVARCHAR(1000)
		,Website3 NVARCHAR(1000)
		,Website4 NVARCHAR(1000)
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
		,Remark
		,[Round]
		,Division
		,[Provider]
		,WatchBet
		,OtherProvider
		,Website1
		,Website2
		,Website3
		,Website4
		)
	SELECT m.OWPMatchId
		,m.MatchNo
		,m.KickOffTime
		,League.OWPLeagueName
		,home.OWPTeamName
		,away.OWPTeamName
		,info.Remark
		,info.[Round]
		,info.Division
		,STUFF((
				SELECT ', ' + rs.ProviderName
				FROM dbo.[Provider] rs WITH (NOLOCK)
					INNER JOIN dbo.MatchProvider AS f WITH (NOLOCK) ON rs.ProviderId = f.ProviderId
				WHERE m.OWPMatchId = f.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS 'Provider'
		,info.WB
		,STUFF((
				SELECT ', ' + rs.OtherProviderName
				FROM dbo.OtherProvider rs WITH (NOLOCK)
					INNER JOIN dbo.MatchOtherProvider AS f WITH (NOLOCK) ON rs.OtherProviderId = f.OtherProviderId
				WHERE m.OWPMatchId = f.OWPMatchId
				FOR XML PATH('')
				), 1, 2, '') AS 'OtherProvider'
		,info.Website1
		,info.Website2
		,info.Website3
		,info.Website4
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
				SELECT DISTINCT m.OWPMatchId
					,m.OWPLeagueId
					,ls.Bettype
					,DATEADD(dd, DATEDIFF(dd, 0, m.EventDate), CAST(m.KickOffTime AS DATETIME)) AS OnDate
					,(CASE 
						WHEN EXISTS (
								SELECT 1
								FROM dbo.MatchTelevision WITH (NOLOCK)
								WHERE OWPMatchId = mif.OWPMatchId
								) THEN 1
						ELSE 0 END
						) AS tv
					,(CASE 
						WHEN EXISTS (
								SELECT 1
								FROM dbo.MatchOtherProvider WITH (NOLOCK)
								WHERE OWPMatchId = mif.OWPMatchId
								) THEN 1
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
				) AS tb
			) AS tb1
		) AS tb2
		LEFT JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON ls.LeagueId = tb2.OWPLeagueId
		AND ls.OptionsId = tb2.MaxBetOption
		AND ls.Bettype = tb2.Bettype
		LEFT JOIN dbo.LeagueSetting AS ls1 WITH (NOLOCK) ON ls1.LeagueId = tb2.OWPLeagueId
		AND ls1.OptionsId = tb2.SpreadOption
		AND ls1.Bettype = tb2.Bettype

	--get matchs
	SELECT m.OWPMatchId
		,m.MatchNo
		,m.KickOffTime
		,m.League
		,m.Home
		,m.Away
		,m.Remark
		,m.[Round]
		,m.Division
		,m.[Provider]
		,m.WatchBet
		,m.OtherProvider
		,m.Website1
		,m.Website2
		,m.Website3
		,m.Website4
	FROM #tblMatch AS m WITH (NOLOCK)
	ORDER BY KickOffTime

	--get match settings
	SELECT m.OWPMatchId
		,ms.Bettype
		,ms.Maxbet
		,ms.Spread
	FROM #tblMatch AS m WITH (NOLOCK)
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
	FROM dbo.MatchRecommendOdds AS mr WITH (NOLOCK)
		INNER JOIN #tblMatch AS tm ON mr.OWPMatchId = tm.OWPMatchId
		LEFT JOIN dbo.MatchRecommendOddsDetail AS mrd WITH (NOLOCK) ON mr.MatchRecommendOddsId = mrd.MatchRecommendOddsId
	WHERE mr.Bettype IN (@Handicap, @OverUnder, @1X2)
	ORDER BY mr.MatchRecommendOddsId

	DROP TABLE #tblMatch

	DROP TABLE #tblMatchSetting
END