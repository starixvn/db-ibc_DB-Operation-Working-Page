
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
            SELECT STRING_AGG(ro.Id, ',')
            FROM dbo.OSSettingRound lr
                 INNER JOIN dbo.OSRoundOption ro WITH(NOLOCK) ON ro.Id = lr.RoundId
            WHERE lr.LeagueSettingId = @LeagueSettingId
        );

        -- OfferLines
        SELECT @OfferLines =
        (
            SELECT STRING_AGG(ofo.Id, ',')
            FROM dbo.OSSettingOfferLine so
                 INNER JOIN dbo.OSOfferLineOption ofo WITH(NOLOCK) ON ofo.Id = so.OfferLineId
            WHERE so.LeagueSettingId = @LeagueSettingId
        );

        -- Provider
        SELECT @Providers =
        (
            SELECT STRING_AGG(po.Id, ',')
            FROM dbo.OSSettingProvider lp
                 INNER JOIN dbo.OSProviderOption po WITH(NOLOCK) ON po.Id = lp.ProviderId
            WHERE lp.LeagueSettingId = @LeagueSettingId
        );

        -- Bettype
        SELECT @BetTypes =
        (
            SELECT STRING_AGG(bo.Id, ',')
            FROM dbo.OSSettingBettype sb
                 INNER JOIN dbo.OSBettypeOption bo WITH(NOLOCK) ON bo.Id = sb.BettypeId
            WHERE sb.LeagueSettingId = @LeagueSettingId
        );

        --Betdelay 
        SELECT @BetDelay =
        (
            SELECT STRING_AGG(bo.Id, ',')
            FROM dbo.OSSettingBetDelay sb
                 INNER JOIN dbo.OSBetDelayOption bo WITH(NOLOCK) ON bo.Id = sb.BetDelayId
            WHERE sb.LeagueSettingId = @LeagueSettingId
        );

        -- Select League Setting detail
        SELECT ls.LeagueSettingId, 
               ol.LeagueName, 
               ol.IsActive, 
               ro.Label AS Region, 
               co.Label AS Category, 
               wm.Label AS WeekMatch, 
               ls.KOFromTime, 
               ls.KOToTime, 
               ls.Remark, 
               ls.IsManualUpdateScore, 
               ls.IsIptvOnly, 
               ls.SpreadHDP, 
               ls.SpreadOU, 
               ls.MaxbetHDP, 
               ls.MaxbetOU, 
               @Rounds AS Rounds, 
               @OfferLines AS OfferLines, 
               @Providers AS Providers, 
               @BetTypes AS BetTypes, 
               @BetDelay AS BetDelay
        FROM dbo.OSLeagueSetting ls
             INNER JOIN dbo.OSLeague ol WITH(NOLOCK) ON ol.OSLeagueId = ls.OSLeagueId
             LEFT JOIN dbo.OSRegionOption ro WITH(NOLOCK) ON ro.Id = ol.RegionId
             LEFT JOIN dbo.OSCategoryOption co WITH(NOLOCK) ON co.Id = ol.CategoryId
             LEFT JOIN dbo.OSWeekMatchOption wm WITH(NOLOCK) ON wm.Id = ls.WeekMatchId
        WHERE ls.LeagueSettingId = @LeagueSettingId;
    END;