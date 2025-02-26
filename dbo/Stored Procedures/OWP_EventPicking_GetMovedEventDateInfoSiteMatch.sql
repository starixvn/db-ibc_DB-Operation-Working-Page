
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_GetMovedEventDateInfoSiteMatch] @Date DATE
AS

/*      
 Created: 20241028@Oliver
 Task : Get match had changed EventDate to another day
 DB: bodb_OWP      
 
 Revisions:
    20241028@Oliver: Event picking new - [Redmine: #212599]
	20241107@Frankie: Sort R&D column - [Redmine: #212795]
	20241114@Frankie: get provider info - [Redmine: #213590]
	20241209@Frankie : Update League Category - [Feature: #214351]
	20250113@Frankie : get RoundConfirm - [Feature: #213482]
	20250210@Frankie : get ispostponed - [Feature: #216746]
	20241106@Frankie: get old and new value when change - [Redmine: #216746]
*/

BEGIN
    SET NOCOUNT ON;
    DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
    DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');
	DECLARE @CheckValue VARCHAR(5000)= 'Checked';  
    DECLARE @InitValue VARCHAR(5000)= 'Initialize';  
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
            1 as IsMovedEventDate,
			im.MatchStatus AS 'InfoSiteMatchStatus',
			im.RoundConfirm,
			im.IsHomeBadRanking,
			im.IsAwayBadRanking,
			im.IsHomeDowngrade,
			im.IsAwayDowngrade,
			im.IsPostponed
    FROM @TempMatch AS tmp 
            INNER JOIN dbo.InfoSiteMatch AS im WITH(NOLOCK) ON tmp.InfoSiteMatchId = im.InfoSiteMatchId
            LEFT JOIN dbo.OWPLeague AS l WITH(NOLOCK) ON l.OWPLeagueId = im.OWPLeagueId
            LEFT JOIN dbo.EventPickingNoOfferMatch AS us WITH(NOLOCK) ON us.InfoSiteMatchId = im.InfoSiteMatchId
                                                                        AND us.ChildMatchId IS NULL
            LEFT JOIN dbo.EventPickingConfirmed AS ec WITH(NOLOCK) ON im.InfoSiteMatchId = ec.InfositeId
            LEFT JOIN dbo.EventPicking AS ep WITH(NOLOCK) ON ep.InfositeMatchId = im.InfoSiteMatchId
    WHERE im.LeagueName NOT LIKE '%Fantasy%';

	-- Select R&D
	DECLARE @TempTime TABLE (InfoSiteMatchId INT NOT NULL, ShowDate DATETIME);
	INSERT INTO @TempTime (InfoSiteMatchId, ShowDate)  
    SELECT el.InfositeId,   
            MAX([date])  
    FROM EventPickingLog el WITH(NOLOCK) 
        INNER JOIN @TempMatch im ON el.InfositeId = im.InfoSiteMatchId  
    WHERE(el.NewValue = @CheckValue  
            OR el.OldValue = @InitValue)  
    GROUP BY el.InfositeId;  


    SELECT DISTINCT 
        el.InfositeId, 
        eu.Id AS UpdateTypeId, 
        eu.RAndDUpdate, 
        el.AwayUpdated, 
        el.HomeUpdated,
		el.[Date],
		el.[OldValue],
		el.[NewValue]
    FROM dbo.EventPickingLog AS el WITH(NOLOCK)  
        INNER JOIN @TempTime temp ON el.InfositeId = temp.InfoSiteMatchId  
        INNER JOIN EventPickingUpDateType eu WITH(NOLOCK) ON el.UpdateTypeId = eu.Id 
    WHERE el.[Date] >= temp.ShowDate  
        AND eu.Id NOT IN(14, 15, 25)  
	ORDER BY el.[Date];
END;