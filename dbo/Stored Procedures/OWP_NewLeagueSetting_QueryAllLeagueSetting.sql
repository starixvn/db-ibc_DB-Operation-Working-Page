
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_NewLeagueSetting_QueryAllLeagueSetting] @League NVARCHAR(500) = ''
AS

/*      
 Created: 20240429@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20240429@Liam: Get new league Settings  - [Redmine: #202639]

*/

    BEGIN
        SET NOCOUNT ON;
        SELECT l.Id 'LeagueSettingId', 
               l.OWPLeagueId, 
               o.OWPLeagueName 'League', 
               l.[FullConditionDescription], 
               l.[Spread_HDP] 'Spread_HDP_Value', 
               l.[Spread_OU] 'Spread_OU_Value', 
               l.[Spread_Note], 
               l.[MaxbetWD_HDP] 'MaxbetWD_HDP_Value', 
               l.[MaxbetWD_HDP_Note], 
               l.[WD_NoOfHDP] 'WD_NoOfHDP_Value', 
               l.[WD_NoOfHDP_Note], 
               l.[MaxbetWK_HDP] 'WK_HDP_Value', 
               l.[MaxbetWK_HDP_Note], 
               l.[WK_NoOfHDP] 'WK_NoOfHDP_Value', 
               l.[WK_NoOfHDP_Note], 
               l.[LSTNote], 
               l.[Remark2], 
               l.[Comment], 
               o.OWPLeagueName, 
               o.New_CategoryId 'LeagueGroupId', 
               rr.Value 'LeagueGroup'
        FROM LeagueManagementSetting l
             INNER JOIN OWPLeague o ON l.OWPLeagueId = o.OWPLeagueId
             LEFT JOIN RefResource rr ON rr.RefName = 'NewLeagueCategory'
                                         AND o.New_CategoryId = rr.ResourceId
        WHERE o.OWPLeagueName LIKE '%' + @League + '%';
    END;