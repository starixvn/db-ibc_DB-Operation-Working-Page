
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetInfoSiteMatchByIds] @InfoSiteIds NVARCHAR(MAX)
AS

/*
Created: 20251023@Hank
Task : Get info site match by ids
DB: bodb_OWP

Revisions:
	20251023@Hank: Get info site match by ids - [Redmine: #238985]

*/

    BEGIN
        SET NOCOUNT ON;
      
        SELECT DISTINCT 
               im.InfoSiteMatchId, 
               im.AdminSiteMatchId, 
               im.EventDateTime, 
               im.OWPLeagueId, 
               im.LeagueName, 
               l.IsBlackList,
               CASE
                   WHEN im.IsNeutral = 1
                   THEN im.HomeName + ' (N)'
                   ELSE im.HomeName
               END AS HomeName, 
               im.AwayName, 
               im.TV, 
               im.IPTV, 
               im.Channel, 
               im.WB, 
               im.[Provider], 
               im.OtherProvider, 
               im.Agent, 
               im.Venue, 
               im.[Round], 
               im.Division, 
               im.ETPK, 
               im.Remark, 
               im.HomeRemark, 
               im.AwayRemark, 
               im.Remark2, 
               im.TotalRound, 
               im.Website1, 
               im.Website2, 
               im.Website3, 
               im.Website4,
               im.IsDeleted, 
               im.IsLeagueBlackList, 
               im.IsHomeBlackList, 
               im.IsAwayBlackList, 
               ep.MaxbetHdp 'MaxbetHdp', 
               ep.SpreadHdp 'SpreadHdp', 
               ep.SpreadOu 'SpreadOu', 
               ep.NoOfHDP 'NoOfHDP', 
               ep.LSTNote 'LstNote', 
               ep.Remark2 'Remark2LeagueManagement',
               CASE
                   WHEN ep.InfositeMatchId IS NOT NULL
                   THEN 1
                   ELSE 0
               END 'IsSync', 
               im.MatchStatus AS 'InfoSiteMatchStatus', 
               im.RoundConfirm, 
               im.IsHomeBadRanking, 
               im.IsAwayBadRanking, 
               im.IsHomeDowngrade, 
               im.IsAwayDowngrade, 
               im.IsPostponed
        FROM dbo.InfoSiteMatch AS im WITH(NOLOCK)
             LEFT JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON l.OWPLeagueId = im.OWPLeagueId
             LEFT JOIN dbo.EventPicking AS ep WITH(NOLOCK) ON ep.InfositeMatchId = im.InfoSiteMatchId
        WHERE im.InfoSiteMatchId IN (SELECT [value] FROM STRING_SPLIT(@InfoSiteIds, ','))
    END;