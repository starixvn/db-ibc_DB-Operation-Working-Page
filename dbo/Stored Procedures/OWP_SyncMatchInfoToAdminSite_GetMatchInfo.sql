
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_SyncMatchInfoToAdminSite_GetMatchInfo] @fromDate DATETIME
    ,@toDate DATETIME
AS
/*
Created: 20241223@Tim
Task: sync match info to AdminSite
DB: bodb_OWP

Revisions:
	20241223@Tim: initial - [Redmine: #212957]
*/
BEGIN
	SET NOCOUNT ON;

    DECLARE @franceLigue1 INT= 3, @championsLeague INT= 748, @championsLeaguePlayOff INT= 1859, @championsLeagueQualifiers INT= 1681

    CREATE TABLE #tblMatch (OWPMatchId INT, OWPLeagueId INT, InfoSiteMatchId INT, AdminSiteMatchId INT, ParentMatchId INT, MinorBettypeId INT, LeagueGroupId INT)

    INSERT INTO #tblMatch
    (
        OWPMatchId
        ,OWPLeagueId
        ,InfoSiteMatchId
        ,AdminSiteMatchId
        ,ParentMatchId
        ,MinorBettypeId
        ,LeagueGroupId
    )
    SELECT m.OWPMatchId
        ,m.OWPLeagueId
        ,im.InfoSiteMatchId
        ,im.AdminSiteMatchId
        ,NULL
        ,NULL
        ,CASE
            WHEN l.OWPLeagueId = @franceLigue1 THEN NULL
            WHEN l.OWPLeagueId IN (@championsLeague, @championsLeagueQualifiers, @championsLeaguePlayOff) THEN 1
            ELSE l.CategoryId END
    FROM dbo.OWPMatch AS m WITH (NOLOCK)
        INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON im.InfoSiteMatchId = m.InfoSiteMatchId
        INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
    WHERE im.ParentId IS NULL
        AND m.EventDateTime BETWEEN @fromDate AND @toDate
        AND im.InfoSiteMatchId IS NOT NULL
        AND im.AdminSiteMatchId > 0

    INSERT INTO #tblMatch
    (
        OWPMatchId
        ,OWPLeagueId
        ,InfoSiteMatchId
        ,AdminSiteMatchId
        ,ParentMatchId
        ,MinorBettypeId
        ,LeagueGroupId
    )
    SELECT mm.MinorMatchId
        ,child.OWPLeagueId
        ,im.InfoSiteMatchId
        ,im.AdminSiteMatchId
        ,parent.OWPMatchId
        ,mm.MinorBettypeId
        ,CASE
            WHEN l.OWPLeagueId = @franceLigue1 THEN NULL
            WHEN l.OWPLeagueId IN (@championsLeague, @championsLeagueQualifiers, @championsLeaguePlayOff) THEN 1
            ELSE l.CategoryId END
    FROM dbo.OWPMatch AS parent WITH (NOLOCK)
        INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON parent.OWPLeagueId = l.OWPLeagueId
        INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON parent.OWPMatchId = mm.ParentMatchId
        INNER JOIN dbo.OWPMatch AS child WITH (NOLOCK) ON mm.MinorMatchId = child.OWPMatchId
        INNER JOIN dbo.InfoSiteMatch AS im WITH (NOLOCK) ON im.InfoSiteMatchId = parent.InfoSiteMatchId
    WHERE im.ParentId IS NULL
        AND parent.EventDateTime BETWEEN @fromDate AND @toDate
        AND im.InfoSiteMatchId IS NOT NULL
        AND im.AdminSiteMatchId > 0

    SELECT m.OWPMatchId
        ,m.ParentMatchId
        ,m.AdminSiteMatchId
        ,m.InfoSiteMatchId
        ,l.OWPLeagueName AS 'League'
        ,(
            SELECT STRING_AGG(p.ProviderName, ', ')
            FROM dbo.[Provider] AS p WITH(NOLOCK)
                 INNER JOIN dbo.MatchProvider AS mp WITH(NOLOCK) ON p.ProviderId = mp.ProviderId
            WHERE mp.OWPMatchId = m.OWPMatchId
        ) AS 'Provider'
        ,(
            SELECT STRING_AGG(op.OtherProviderName, ', ')
            FROM dbo.[OtherProvider] AS op WITH(NOLOCK)
                 INNER JOIN dbo.MatchOtherProvider AS mop WITH(NOLOCK) ON op.OtherProviderId = mop.OtherProviderId
            WHERE mop.OWPMatchId = m.OWPMatchId
        ) AS 'OtherProvider'
        ,mi.WB AS 'WatchBet'
        ,mi.NoOfHDPId
    FROM #tblMatch AS m WITH (NOLOCK)
        INNER JOIN dbo.MatchInfo AS mi WITH(NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
        INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId

    DROP TABLE #tblMatch
END