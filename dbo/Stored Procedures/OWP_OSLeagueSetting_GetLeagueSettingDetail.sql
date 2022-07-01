
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [OWP_OSLeagueSetting_GetLeagueSettingDetail] @LeagueSettingId INT
AS

/*
Created: 20220705@Mira
Task : Get OS league setting detail
DB: bodb_OWP

Revisions:
	20220705@Mira: Initial - [Redmine: #174431]	
*/

    BEGIN
        SET NOCOUNT ON;

        -- Select League Setting
        SELECT ls.LeagueSettingId, 
               ol.LeagueName, 
               ls.IsActive, 
               ro.Label AS Region, 
               co.Label AS Category, 
               wm.Label AS WeekMatch, 
               bd.Label AS BetDelay, 
               ls.KOFromTime, 
               ls.KOToTime, 
               ls.Remark, 
               ls.IsManualUpdateScore, 
               ls.IsIptvOnly, 
               ls.SpreadHDP, 
               ls.SpreadOU, 
               ls.MaxbetHDP, 
               ls.MaxbetOU
        FROM dbo.OSLeagueSetting ls
             INNER JOIN dbo.OSLeague ol WITH(NOLOCK) ON ol.OSLeagueId = ls.OSLeagueId
             INNER JOIN dbo.OSRegionOption ro WITH(NOLOCK) ON ro.Id = ls.RegionId
             INNER JOIN dbo.OSCategoryOption co WITH(NOLOCK) ON co.Id = ls.CategoryId
             INNER JOIN dbo.OSWeekMatchOption wm WITH(NOLOCK) ON wm.Id = ls.WeekMatchId
             INNER JOIN dbo.OSBetDelayOption bd WITH(NOLOCK) ON bd.Id = ls.BetDelayId
        WHERE ls.LeagueSettingId = @LeagueSettingId;

        -- select Round
        SELECT lr.LeagueSettingId, 
               ro.Label AS Round
        FROM dbo.OSSettingRound lr
             INNER JOIN dbo.OSRoundOption ro WITH(NOLOCK) ON ro.Id = lr.RoundId
        WHERE lr.LeagueSettingId = @LeagueSettingId;

        -- select OfferLines
        SELECT ol.LeagueSettingId, 
               ro.Label AS OfferLine
        FROM dbo.OSSettingOfferLine ol
             INNER JOIN dbo.OSRoundOption ro WITH(NOLOCK) ON ro.Id = ol.OfferLineId
        WHERE ol.LeagueSettingId = @LeagueSettingId;

        -- select Provider
        SELECT lp.LeagueSettingId, 
               po.Label AS Provider
        FROM dbo.OSSettingProvider lp
             INNER JOIN dbo.OSProviderOption po WITH(NOLOCK) ON po.Id = lp.ProviderId
        WHERE lp.LeagueSettingId = @LeagueSettingId;

		-- select Bettype
        SELECT lb.LeagueSettingId, 
               po.Label AS Provider
        FROM dbo.OSSettingBettype lb
             INNER JOIN dbo.OSProviderOption po WITH(NOLOCK) ON po.Id = lb.BettypeId
        WHERE lb.LeagueSettingId = @LeagueSettingId;
    END;