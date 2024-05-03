
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_NewLeagueSetting_QueryAllLeagueSetting] @League NVARCHAR(500) = ''
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
               l.[Spread_HDP] 'Spread_HDP_value', 
               l.[Spread_OU] 'Spread_OU_value', 
               l.[Spread_Note], 
               l.[MaxbetWD_HDP] 'MaxbetWD_HDP_value', 
               l.[MaxbetWD_HDP_Note], 
               l.[MaxbetWD_NoOfHDP] 'MaxbetWD_NoOfHDP_value', 
               l.[MaxbetWD_NoOfHDP_Note], 
               l.[MaxbetWK_HDP] 'MaxbetWK_HDP_value', 
               l.[MaxbetWK_HDP_Note], 
               l.[MaxbetWK_NoOfHDP] 'MaxbetWK_NoOfHDP_value', 
               l.[MaxbetWK_NoOfHDP_Note], 
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