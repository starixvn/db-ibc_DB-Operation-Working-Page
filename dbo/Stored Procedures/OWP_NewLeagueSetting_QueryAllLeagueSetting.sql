
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_NewLeagueSetting_QueryAllLeagueSetting] @League        NVARCHAR(500) = '', 
                                                                   @IsEqualLeague BIT           = 0
AS

/*      
 Created: 20240429@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20240429@Liam: Get new league Settings  - [Redmine: #202639]
    20240802@Mira: Order setting by league  - [Redmine: #207941]
	20250711@Los: Get new league category  - [Redmine: #232603]
    20250822@Hank: Get league more short league, isblacklist, noofferlive- [Redmine: #234901]
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #LatestLeague
        (CategoryId  INT, 
         OwpLeagueId INT
        );
        INSERT INTO #LatestLeague
        (CategoryId, 
         OwpLeagueId
        )
               SELECT h.CategoryId, 
                      h.OWPLeagueId
               FROM LeagueCategoryHistory h WITH(NOLOCK)
               WHERE h.Id =
               (
                   SELECT MAX(id)
                   FROM LeagueCategoryHistory h2 WITH(NOLOCK)
                   WHERE h.OWPLeagueId = h2.OWPLeagueId
               );
        SELECT  
               l.Id 'LeagueSettingId', 
               l.OWPLeagueId, 
               o.OWPLeagueName 'League', 
			   ISNULL(o.IsBlackList, 0) as IsBlackList,
			   ISNULL(o.NoOfferLive, 0) as NoOfferLive,
			   o.ShortLeague,
               l.[FullConditionDescription], 
               l.[Spread_HDP] 'Spread_HDP_Value', 
               l.[Spread_OU] 'Spread_OU_Value', 
               l.[Spread_Note], 
               l.[MaxbetWD_HDP] 'MaxbetWD_HDP_Value', 
               l.[MaxbetWD_HDP_Note], 
               l.[WD_NoOfHDP] 'WD_NoOfHDP_Value', 
               l.[WD_NoOfHDP_Note], 
               l.[MaxbetWK_HDP] 'MaxbetWK_HDP_Value', 
               l.[MaxbetWK_HDP_Note], 
               l.[WK_NoOfHDP] 'WK_NoOfHDP_Value', 
               l.[WK_NoOfHDP_Note], 
               l.[LSTNote], 
               l.[Remark2], 
               l.[Comment], 
               o.OWPLeagueName, 
               ll.CategoryId 'LeagueGroupId', 
               rr.Value 'LeagueGroup'
        FROM LeagueManagementSetting l WITH(NOLOCK)
             INNER JOIN OWPLeague o WITH(NOLOCK) ON l.OWPLeagueId = o.OWPLeagueId
             LEFT JOIN #LatestLeague ll ON l.OWPLeagueId = ll.OwpLeagueId
             LEFT JOIN RefResource rr WITH(NOLOCK) ON ll.CategoryId = rr.ResourceId
                                                      AND rr.RefName = 'LeagueCategory'
        WHERE(@IsEqualLeague = 0
              AND o.OWPLeagueName LIKE '%' + @League + '%')
             OR (@IsEqualLeague = 1
                 AND o.OWPLeagueName = @League)
        ORDER BY o.OWPLeagueName, 
                 l.Id;
    END;