
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_GetEventPickingChildMatch] @Date DATE
AS

/*      
 Created: 20240812@Liam
 Task : Get event picking child match
 DB: bodb_OWP      
 
 Revisions:
	20230907@Liam: Get event picking child match - [Redmine: #207942]
	20241114@Frankie: get provider info - [Redmine: #213590]
	20241209@Frankie : Update League Category - [Feature: #214351]
	20250113@Frankie : get RoundConfirm - [Feature: #213482]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');

        -- Select InfoSiteMatch
        SELECT DISTINCT 
               im.InfoSiteMatchId, 
               im.AdminSiteMatchId, 
               im.EventDateTime, 
               im.OWPLeagueId, 
               im.LeagueName, 
			   [dbo].[fnc_GetLeagueGroupByDate] (im.EventDateTime, im.OWPLeagueId) AS LeagueGroup,
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
			   im.Provider,
               im.OtherProvider, 
               im.Agent, 
               im.Venue, 
               im.Round,
			   im.RoundConfirm, 
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
                   WHEN us.Id IS NULL
                   THEN 0
                   ELSE 1
               END AS 'IsNoOffer', 
               us.ChildMatchId, 
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
			   epc.Id 'ChildMatchId',
			   epc.MinorBettypeId ,
               epc.MaxbetHdp 'MaxbetHdp', 
               epc.SpreadHdp 'SpreadHdp', 
               epc.SpreadOu 'SpreadOu', 
               epc.NoOfHDP 'NoOfHDP'
        FROM EventPickingChildMatch epc WITH(NOLOCK)
             INNER JOIN dbo.InfoSiteMatch AS im WITH(NOLOCK) ON epc.ParentId = im.InfoSiteMatchId
             LEFT JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON l.OWPLeagueId = im.OWPLeagueId
             LEFT JOIN dbo.EventPickingNoOfferMatch AS us WITH(NOLOCK) ON us.InfoSiteMatchId = im.InfoSiteMatchId
                                                                          AND us.ChildMatchId IS NULL
             LEFT JOIN dbo.EventPickingConfirmed AS ec WITH(NOLOCK) ON im.InfoSiteMatchId = ec.InfositeId
        WHERE(im.EventDateTime BETWEEN @FromDateTime AND @ToDateTime)
             AND im.LeagueName NOT LIKE '%Fantasy%';
    END;