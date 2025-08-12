
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_Query]
    @StartDate DATE,
	@EndDate DATE,
    @OnlyShowIsMismatchEvent BIT,
    @ConfirmProvider NVARCHAR(1000) = NULL,
    @LstBookProvider NVARCHAR(1000) = NULL
AS

/*
 Created: 20240405@Johnny
 Task : query provider verification
 DB: bodb_OWP

 Revisions:
	20240405@Johnny: Initial SP - [Feature: #202819]
	20250210@Los: Remove unuse column - [Feature: #213719]
	20250307@Lilac: Add filter Confirm Provider, LST Book Provider - [Feature #213719]
	20250523@Lilac: Get data from 2 table current and old - [Feature #213719]
	20250610@Lilac.Nguyen: change confirm provider rule - [Redmine: #227452]
    20250812@Frankie: add 2 new columns - [Redmine: #234693]
*/

BEGIN
    SET NOCOUNT ON;

    DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @StartDate), '12:00:00');
    DECLARE @ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, -1, @EndDate), '11:59:59');

    DECLARE @tblRefResourceMatchStatus TABLE (
        Id INT NOT NULL,
        Value NVARCHAR(50) NOT NULL
    );

    INSERT INTO @tblRefResourceMatchStatus (Id, Value)
    SELECT ResourceId, Value
    FROM dbo.RefResource WITH(NOLOCK)
    WHERE RefName = 'MatchStatus' AND ResourceId IN (1, 2, 3, 4, 5, 6, 7);

    CREATE TABLE #tblMatchOfferResource (
        Id INT NOT NULL,
        Value NVARCHAR(50) NOT NULL
    );

    INSERT INTO #tblMatchOfferResource (Id, Value)
    SELECT ResourceId, Value
    FROM dbo.RefResource WITH(NOLOCK)
    WHERE RefName = 'MatchOffer';

    CREATE TABLE #owpMatchListByDate (
        OWPMatchId INT,
        MatchNo NVARCHAR(50),
        EventDateTime DATETIME,
        KickOffTime TIME(7),
        OWPLeagueId INT,
        OWPHomeId INT,
        OWPAwayId INT,
        MatchStatus NVARCHAR(15),
        IsNeutral BIT,
        Remark NVARCHAR(2000),
        RemarkBy NVARCHAR(2000),
		LstBookProvider NVARCHAR(2000),
		OtherProvider NVARCHAR(2000)
    );

    INSERT INTO #owpMatchListByDate (
        OWPMatchId,
        MatchNo,
        EventDateTime,
        KickOffTime,
        OWPLeagueId,
        OWPHomeId,
        OWPAwayId,
        MatchStatus,
        IsNeutral,
        Remark,
        RemarkBy,
		LstBookProvider,
		OtherProvider
    )

    SELECT DISTINCT
        om.OWPMatchId,
        om.MatchNo,
        om.EventDateTime,
        om.KickOffTime,
        om.OWPLeagueId,
        om.OWPHomeId,
        om.OWPAwayId,
        dbo.OWP_GetCurrentMatchStatus(om.EventDateTime, om.KickOffTime, mi.MatchStatus),
        om.IsNeutral,
        pv.Remark,
        pv.RemarkBy,
		STUFF((
			SELECT ', ' + rs.ProviderName
			FROM dbo.[Provider] AS rs WITH(NOLOCK)
			INNER JOIN dbo.MatchProvider AS mp WITH(NOLOCK) ON rs.ProviderId = mp.ProviderId
			WHERE mp.OWPMatchId = om.OWPMatchId
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS LstBookProvider,
		STUFF((
            SELECT ', ' + rs.OtherProviderName
            FROM dbo.OtherProvider AS rs WITH(NOLOCK)
            INNER JOIN dbo.MatchOtherProvider AS mot WITH(NOLOCK) ON rs.OtherProviderId = mot.OtherProviderId
            WHERE mot.OWPMatchId = om.OWPMatchId
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS OtherProvider
    FROM dbo.OWPMatch AS om WITH(NOLOCK)
    INNER JOIN dbo.MatchInfo AS mi WITH(NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
    LEFT JOIN dbo.MinorMatch AS mm WITH(NOLOCK) ON om.OWPMatchId = mm.MinorMatchId
    LEFT JOIN dbo.ProviderVerification AS pv WITH(NOLOCK) ON pv.OWPMatchId = om.OWPMatchId
    LEFT JOIN dbo.MatchAgentConfirm AS ma WITH(NOLOCK) ON ma.OWPMatchId = om.OWPMatchId
    LEFT JOIN dbo.MatchProvider AS mp WITH(NOLOCK) ON mp.OWPMatchId = om.OWPMatchId
    WHERE om.EventDateTime BETWEEN @FromDate AND @ToDate
        AND mi.IsSelected = 1
        AND mm.MinorBettypeId IS NULL
        AND (@OnlyShowIsMismatchEvent = 0 OR pv.IsMismatchEvent = @OnlyShowIsMismatchEvent)
        AND (
            @ConfirmProvider IS NULL
            OR ma.AgentId IN (
                SELECT val FROM dbo.fnc_SplitStrings(@ConfirmProvider, ',')
            )
        )
        AND (
            @LstBookProvider IS NULL
            OR mp.ProviderId IN (
                SELECT val FROM dbo.fnc_SplitStrings(@LstBookProvider, ',')
            )
        )

	UNION

	SELECT DISTINCT
		om.OWPMatchId,
		om.MatchNo,
		om.EventDateTime,
		om.KickOffTime,
		om.OWPLeagueId,
		om.OWPHomeId,
		om.OWPAwayId,
		dbo.OWP_GetCurrentMatchStatus(om.EventDateTime, om.KickOffTime, mi.MatchStatus),
		om.IsNeutral,
		pv.Remark,
		pv.RemarkBy,
		STUFF((
				SELECT ', ' + rs.ProviderName
				FROM dbo.[Provider] AS rs WITH(NOLOCK)
				INNER JOIN dbo.MatchProvider_Old AS mp WITH(NOLOCK) ON rs.ProviderId = mp.ProviderId
				WHERE mp.OWPMatchId = om.OWPMatchId
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS LstBookProvider,
		STUFF((
				SELECT ', ' + rs.OtherProviderName
				FROM dbo.OtherProvider AS rs WITH(NOLOCK)
				INNER JOIN dbo.MatchOtherProvider_Old AS mot WITH(NOLOCK) ON rs.OtherProviderId = mot.OtherProviderId
				WHERE mot.OWPMatchId = om.OWPMatchId
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS OtherProvider
		FROM dbo.OWPMatch_Old AS om WITH(NOLOCK)
	INNER JOIN dbo.MatchInfo_Old AS mi WITH(NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
	LEFT JOIN dbo.MinorMatch_Old AS mm WITH(NOLOCK) ON om.OWPMatchId = mm.MinorMatchId
	LEFT JOIN dbo.ProviderVerification AS pv WITH(NOLOCK) ON pv.OWPMatchId = om.OWPMatchId
	LEFT JOIN dbo.MatchAgentConfirm AS ma WITH(NOLOCK) ON ma.OWPMatchId = om.OWPMatchId
	LEFT JOIN dbo.MatchProvider_Old AS mp WITH(NOLOCK) ON mp.OWPMatchId = om.OWPMatchId
	WHERE om.EventDateTime BETWEEN @FromDate AND @ToDate
		AND mi.IsSelected = 1
		AND mm.MinorBettypeId IS NULL
		AND (@OnlyShowIsMismatchEvent = 0 OR pv.IsMismatchEvent = @OnlyShowIsMismatchEvent)
		AND (
			@ConfirmProvider IS NULL
			OR ma.AgentId IN (
				SELECT val FROM dbo.fnc_SplitStrings(@ConfirmProvider, ',')
			)
		)
		AND (
			@LstBookProvider IS NULL
			OR mp.ProviderId IN (
				SELECT val FROM dbo.fnc_SplitStrings(@LstBookProvider, ',')
			)
		);

     -- Get maxbet
    CREATE TABLE #tblMaxBet
		(OWPMatchId     INT, 
		Bettype        INT, 
		MaxBet         MONEY, 
		Spread         MONEY, 
		IsMatchSetting BIT, 
		LeagueId       INT
		);

    INSERT INTO #tblMaxBet
		(OWPMatchId, 
		Bettype, 
		MaxBet, 
		Spread, 
		IsMatchSetting
		)
	SELECT ml.owpmatchid, 
        ms.Bettype, 
        ms.Maxbet, 
        ms.Spread, 
        1
	FROM #owpMatchListByDate AS ml WITH(NOLOCK)
        INNER JOIN dbo.MatchSetting AS ms WITH(NOLOCK) ON ml.owpmatchid = ms.OWPMatchId
	WHERE ms.Bettype = 1 --HDP type

	INSERT INTO #tblMaxBet
		(OWPMatchId, 
		Bettype, 
		MaxBet, 
		Spread, 
		IsMatchSetting
		)
	SELECT ml.owpmatchid, 
			ms.Bettype, 
			ms.Maxbet, 
			ms.Spread, 
			1
	FROM #owpMatchListByDate AS ml WITH(NOLOCK)
			INNER JOIN dbo.MatchSetting_Old AS ms WITH(NOLOCK) ON ml.owpmatchid = ms.OWPMatchId
	WHERE ms.Bettype = 1 --HDP type

	INSERT INTO #tblMaxBet
		(OWPMatchId, 
		LeagueId, 
		Bettype, 
		IsMatchSetting
		)
        SELECT ml.OWPMatchId, 
                ml.OWPLeagueId, 
                ls.Bettype, 
                0
        FROM #owpMatchListByDate AS ml WITH(NOLOCK)
                INNER JOIN dbo.LeagueSetting AS ls WITH(NOLOCK) ON ml.OWPLeagueId = ls.LeagueId
        WHERE ml.OWPMatchId NOT IN
			(
				SELECT OWPMatchId
				FROM #tblMaxBet WITH(NOLOCK)
			)
            AND ls.Bettype = 1 --HDP type
                  
        GROUP BY ml.OWPMatchId, 
                    ml.OWPLeagueId,
					ls.Bettype;

    UPDATE mb
    SET mb.MaxBet = dbo.OWP_MaxBetGet(mb.OWPMatchId, mb.LeagueId, mb.Bettype), 
        mb.Spread = dbo.OWP_SpreadGet(mb.OWPMatchId, mb.LeagueId, mb.Bettype)
    FROM #tblMaxBet AS mb
    WHERE mb.IsMatchSetting = 0;

    SELECT
        ml.OWPMatchId,
        ml.MatchNo,
        ml.MatchStatus,
        ml.EventDateTime,
        ml.KickOffTime AS KoTime,
        l.OWPLeagueName AS League,
        CASE
            WHEN ml.IsNeutral = 1 THEN h.OWPTeamName + ' (N)'
            ELSE h.OWPTeamName
        END AS Home,
        a.OWPTeamName AS Away,
        ml.Remark,
        ml.RemarkBy,
        ml.LstBookProvider,
        ml.OtherProvider,
		mb.MaxBet
    FROM #owpMatchListByDate AS ml WITH(NOLOCK)
    INNER JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON ml.OWPLeagueId = l.OWPLeagueId
    INNER JOIN dbo.OWPTeam AS h WITH(NOLOCK) ON ml.OWPHomeId = h.OWPTeamId
    INNER JOIN dbo.OWPTeam AS a WITH(NOLOCK) ON ml.OWPAwayId = a.OWPTeamId
	LEFT JOIN #tblMaxBet AS mb WITH(NOLOCK) ON ml.OWPMatchId = mb.OWPMatchId
    WHERE l.OWPLeagueName NOT LIKE '%FANTASY%'
        AND ml.MatchStatus IN (
            SELECT [Value] FROM @tblRefResourceMatchStatus
        )
    ORDER BY ml.MatchNo, ml.EventDateTime, ml.KickOffTime, l.OWPLeagueName, h.OWPTeamName;

    SELECT
        mac.OWPMatchId,
        mac.AgentId,
        ao.AgentName
    FROM MatchAgentConfirm AS mac WITH(NOLOCK)
    INNER JOIN #owpMatchListByDate AS ml WITH(NOLOCK) ON ml.OWPMatchId = mac.OWPMatchId
    LEFT JOIN AgentOption AS ao WITH(NOLOCK) ON ao.AgentId = mac.AgentId
    WHERE mac.AgentId IS NOT NULL AND mac.AgentId <> 0;

    SELECT
        m.OWPMatchId,
        apm.ProviderMatchId,
		apm.[Provider] AS InhouseProviderName
    FROM AdminsiteProviderMatch AS apm WITH(NOLOCK)
    INNER JOIN OWPMatch AS m WITH(NOLOCK) ON m.MatchId = apm.MatchId
    WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate

	UNION

	SELECT
		m.OWPMatchId,
		apm.ProviderMatchId,
		apm.[Provider] AS InhouseProviderName
    FROM AdminsiteProviderMatch AS apm WITH(NOLOCK)
    INNER JOIN OWPMatch_Old AS m WITH(NOLOCK) ON m.MatchId = apm.MatchId
    WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate;

    DROP TABLE #owpMatchListByDate;
    DROP TABLE #tblMatchOfferResource;
	DROP TABLE #tblMaxBet;
END;



