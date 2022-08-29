
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSLeagueSetting_GetLeagueSettingDetail] @LeagueSettingId INT
AS

/*
Created: 20220705@Mira
Task : Get OS league setting detail
DB: bodb_OWP

Revisions:
	20220705@Mira: Initial - [Redmine: #174431]	
	20220809@Liam: correct betdelay - [Redmine: #175994]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @Rounds NVARCHAR(MAX);
        DECLARE @OfferLines NVARCHAR(MAX);
        DECLARE @Providers NVARCHAR(MAX);
        DECLARE @BetTypes NVARCHAR(MAX);
        DECLARE @BetDelay NVARCHAR(MAX);

        -- Round
        SELECT @Rounds =
        (
             SELECT ISNULL(STRING_AGG(ro.Id, ','), '') 
            FROM dbo.OSSettingRound lr
                 INNER JOIN dbo.OSRoundOption ro WITH(NOLOCK) ON ro.Id = lr.RoundId
            WHERE lr.LeagueSettingId = @LeagueSettingId
        );

        -- OfferLines
        SELECT @OfferLines =
        (
            SELECT ISNULL(STRING_AGG(ofo.Id, ','), '') 
            FROM dbo.OSSettingOfferLine so
                 INNER JOIN dbo.OSOfferLineOption ofo WITH(NOLOCK) ON ofo.Id = so.OfferLineId
            WHERE so.LeagueSettingId = @LeagueSettingId
        );

        -- Provider
        SELECT @Providers =
        (
             SELECT ISNULL(STRING_AGG(po.Id, ','), '') 
            FROM dbo.OSSettingProvider lp
                 INNER JOIN dbo.OSProviderOption po WITH(NOLOCK) ON po.Id = lp.ProviderId
            WHERE lp.LeagueSettingId = @LeagueSettingId
        );

        -- Bettype
        SELECT @BetTypes =
        (
            SELECT ISNULL(STRING_AGG(bo.Id, ','), '') 
            FROM dbo.OSSettingBettype sb
                 INNER JOIN dbo.OSBettypeOption bo WITH(NOLOCK) ON bo.Id = sb.BettypeId
            WHERE sb.LeagueSettingId = @LeagueSettingId
        );

        --Betdelay 
        SELECT @BetDelay =
        (
            SELECT ISNULL(STRING_AGG(bo.Id, ','), '') 
            FROM dbo.OSSettingBetDelay sb
                 INNER JOIN dbo.OSBetDelayOption bo WITH(NOLOCK) ON bo.Id = sb.BetDelayId
            WHERE sb.LeagueSettingId = @LeagueSettingId
        );

        -- Select League Setting detail
        SELECT ls.LeagueSettingId AS leagueSettingId, 
               ol.LeagueName AS leagueName, 
               ol.IsActive AS isActive, 
               ro.Id AS region, 
               co.Id AS category, 
               wm.Id AS weekMatch, 
               ls.KOFromTime AS koFromTime, 
               ls.KOToTime AS koToTime, 
               ls.Remark AS remark, 
               ls.IsManualUpdateScore AS isManualUpdateScore, 
               ls.IsIptvOnly AS isIptvOnly, 
               ls.SpreadHDP AS spreadHDP, 
               ls.SpreadOU AS spreadOU, 
               ls.MaxbetHDP AS maxbetHDP, 
               ls.MaxbetOU AS maxbetOU, 
               @Rounds AS rounds, 
               @OfferLines AS offerLines, 
               @Providers AS providers, 
               @BetTypes AS betTypes, 
               @BetDelay AS betDelay
        FROM dbo.OSLeagueSetting ls
             INNER JOIN dbo.OSLeague ol WITH(NOLOCK) ON ol.OSLeagueId = ls.OSLeagueId
             LEFT JOIN dbo.OSRegionOption ro WITH(NOLOCK) ON ro.Id = ol.RegionId
             LEFT JOIN dbo.OSCategoryOption co WITH(NOLOCK) ON co.Id = ol.CategoryId
             LEFT JOIN dbo.OSWeekMatchOption wm WITH(NOLOCK) ON wm.Id = ls.WeekMatchId
        WHERE ls.LeagueSettingId = @LeagueSettingId;
    END;