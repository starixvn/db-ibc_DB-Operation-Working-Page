
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetInfoSiteMatch] @Date DATE
AS

/*
Created: 20221102@Mira
Task : Get main match
DB: bodb_OWP

Revisions:
	20221102@Mira: Event picking new - [Redmine: #179302]
	20230907@Liam: Get deleted matches  - [Redmine: #190039]
	20231026@los: sync round - [Redmine: #193810]
	20240307@Mira: get IsBlackList column - [Redmine: #201375]
	20240328@Johnny: reduce select match - [Redmine: #202638]
	20240419@Mira: Save league, home, away blacklist column - [Redmine: #203309s]
	20240422@Carlos.nguyen: init data league management - [Redmine: #202639]
	20240925@Johnny: get remark2 - [Redmine: #210649]
	20241001@Carlos.nguyen: init data league management - [Redmine: #210649]
	20241114@Frankie: get provider info - [Redmine: #213590]
	20241126@Tim: get MatchStatus, RoundConfirm, IsHomeBadRanking, IsAwayBadRanking, IsHomeDowngrade, IsAwayDowngrade - [Redmine: #214095]
	20241209@Frankie : Update League Category - [Feature: #214351]
	20250210@Frankie : get ispostponed - [Feature: #216746]
	20250220@Los : exclude IDOL CHAMPIONSHIP (Including Penalty Shoot-out Results)  - [Feature: #217894]
	20250911@los: Event picking auto mark no offer  [Redmine: #236469]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');
        SELECT DISTINCT 
               im.InfoSiteMatchId, 
               im.AdminSiteMatchId, 
               im.EventDateTime, 
               im.OWPLeagueId, 
               im.LeagueName, 
               [dbo].[fnc_GetLeagueGroupByDate](im.EventDateTime, im.OWPLeagueId) AS LeagueGroup, 
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
               CASE
                   WHEN ofM.Id IS NULL
                   THEN l.NoOfferLive
                   ELSE 1
               END AS 'IsNoOffer', 
               ofM.ChildMatchId, 
               im.IsTest AS IsTestMatch,
               CASE
                   WHEN ec.InfositeId IS NULL
                   THEN 0
                   ELSE 1
               END AS IsCheck, 
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
             LEFT JOIN dbo.EventPickingNoOfferMatch AS ofM WITH(NOLOCK) ON ofM.InfoSiteMatchId = im.InfoSiteMatchId
                                                                          AND ofM.ChildMatchId IS NULL
             LEFT JOIN dbo.EventPickingConfirmed AS ec WITH(NOLOCK) ON im.InfoSiteMatchId = ec.InfositeId
             LEFT JOIN dbo.EventPicking AS ep WITH(NOLOCK) ON ep.InfositeMatchId = im.InfoSiteMatchId
        WHERE im.EventDateTime BETWEEN @FromDateTime AND @ToDateTime
              AND im.LeagueName NOT LIKE '%Fantasy%'
              AND im.LeagueName <> 'IDOL CHAMPIONSHIP (Including Penalty Shoot-out Results)';
    END;