
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

Create PROCEDURE [dbo].[OWP_EventPicking_GetEventPickingChildMatchForLST] @Date DATE
AS

/*      
 Created: 20241308@Liam
 Task : Get main match
 DB: bodb_OWP      
 
 Revisions:
	20241308@Liam: Get event picking child match for LST - [Redmine: #207942]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');

        -- Select InfoSiteMatch
        SELECT DISTINCT 
               im.EventDateTime, 
               im.OtherProvider,
               CASE
                   WHEN im.IsNeutral = 1
                   THEN im.HomeName + ' (N)'
                   ELSE im.HomeName
               END AS HomeName, 
               im.AwayName, 
               im.LeagueName, 
               im.Division, 
               im.Remark2, 
               im.WB, 
               im.Round, 
               im.ETPK, 
               im.TV, 
               im.Channel, 
               im.Website1, 
               im.Website2, 
               im.Website3, 
               im.Website4, 
               im.InfoSiteMatchId, 
               im.IsLeagueBlackList, 
               im.IsHomeBlackList, 
               im.IsAwayBlackList,
               CASE
                   WHEN us.Id IS NULL
                   THEN 0
                   ELSE 1
               END AS 'IsNoOffer', 
			   epc.MaxbetHdp 'Maxbet',
			   epc.NoOfHDP 'NoHDP' ,
			   epc.SpreadHdp 'SpreadHDP',
			   epc.SpreadOu 'SpreadOU',
			   epc.MinorBettypeId 'MinorBettypeId',
			   epc.Id 'ChildMatchId',
               im.IsTest AS IsTestMatch
         FROM EventPickingChildMatch epc WITH(NOLOCK)
		      INNER JOIN dbo.InfoSiteMatch AS im WITH(NOLOCK) ON epc.ParentId = im.InfoSiteMatchId
              LEFT JOIN dbo.EventPickingNoOfferMatch AS us WITH(NOLOCK) ON us.InfoSiteMatchId = im.InfoSiteMatchId
                                                                          AND us.ChildMatchId IS NULL

	        
        WHERE(im.EventDateTime BETWEEN @FromDateTime AND @ToDateTime)
             AND im.LeagueName NOT LIKE '%Fantasy%';
    END;