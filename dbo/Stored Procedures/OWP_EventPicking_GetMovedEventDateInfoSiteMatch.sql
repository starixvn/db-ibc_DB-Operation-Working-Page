
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_GetMovedEventDateInfoSiteMatch] @Date DATE
AS

/*      
 Created: 20241028@Oliver
 Task : Get match had changed EventDate to another day
 DB: bodb_OWP      
 
 Revisions:
    20241028@Oliver: Event picking new - [Redmine: #212599]
*/

BEGIN
    SET NOCOUNT ON;
    DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
    DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');

    DECLARE @TempMatch TABLE (InfoSiteMatchId INT NOT NULL);
    INSERT INTO @TempMatch (InfoSiteMatchId )
    SELECT DISTINCT epl.InfositeId
    FROM dbo.EventPickingLog epl WITH (NOLOCK)
    WHERE epl.UpdateTypeId = 24 and
    CONVERT(DATETIME, epl.OldValue) BETWEEN @FromDateTime AND @ToDateTime


    -- Select InfoSiteMatch
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
            im.OtherProvider, 
            im.Agent, 
            im.Venue, 
            im.Round, 
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
            ep.MaxbetHdp 'MaxbetHdp', 
            ep.SpreadHdp 'SpreadHdp', 
            ep.SpreadOu 'SpreadOu', 
            ep.NoOfHDP 'NoOfHDP',
            ep.LSTNote 'LstNote',
            ep.Remark2 'Remark2LeagueManagement',
            CASE WHEN ep.InfositeMatchId IS NOT NULL
            THEN 1
            ELSE 0
            END 'IsSync',
            1 as IsMovedEventDate
    FROM @TempMatch AS tmp 
            INNER JOIN dbo.InfoSiteMatch AS im WITH(NOLOCK) ON tmp.InfoSiteMatchId = im.InfoSiteMatchId
            LEFT JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON l.OWPLeagueId = im.OWPLeagueId
            LEFT JOIN dbo.EventPickingNoOfferMatch AS us WITH(NOLOCK) ON us.InfoSiteMatchId = im.InfoSiteMatchId
                                                                        AND us.ChildMatchId IS NULL
            LEFT JOIN dbo.EventPickingConfirmed AS ec WITH(NOLOCK) ON im.InfoSiteMatchId = ec.InfositeId
            LEFT JOIN dbo.EventPicking AS ep WITH(NOLOCK) ON ep.InfositeMatchId = im.InfoSiteMatchId
    WHERE(im.EventDateTime BETWEEN @FromDateTime AND @ToDateTime)
            AND im.LeagueName NOT LIKE '%Fantasy%';
END;