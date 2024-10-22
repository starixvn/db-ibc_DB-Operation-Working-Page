
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MaxbetSetting_Get] @FT_HDP MONEY = 0
AS

/*    
Created: 20220822@Mira
Task : Soccer Maxbet setting
DB: bodb_OWP

Revisions:
	20220822@Mira: SP get maxbet default value - [Redmine: #176781]
	20220915@Mira: add condition het last update - [Redmine: #176781]
*/

    BEGIN
        SET NOCOUNT ON;

        -- Select maxbet all or by FT_HDP
        SELECT FT_HDP, 
               FT_OU, 
               FirstHalf_HDP, 
               FirstHalf_OU, 
               NoOfCorner_FT_HDP, 
               NoOfCorner_FT_OU, 
               NoOfCorner_1H_HDP, 
               NoOfCorner_1H_OU, 
               NextCorner_FT_HDP, 
               TotalBooking_FT_HDP, 
               TotalBooking_FT_OU, 
               TotalBooking_1H_HDP, 
               TotalBooking_1H_OU, 
               NextBooking_FT_HDP, 
               rrm.Value 'SecondAccept_Main', 
               rrc.Value 'SecondAccept_Corner', 
               rrt.Value 'SecondAccept_TotalBooking', 
               rrf.Value 'SecondAccept_Fantasy', 
               lg.Username 'LastUpdatedBy'
        FROM dbo.MaxbetSetting ms
             LEFT JOIN dbo.RefResource AS rrm WITH(NOLOCK) ON ms.SecondAccept_Main = rrm.ResourceId
                                                              AND rrm.RefName = 'MatchOffer'
             LEFT JOIN dbo.RefResource AS rrc WITH(NOLOCK) ON ms.SecondAccept_Corner = rrc.ResourceId
                                                              AND rrc.RefName = 'MatchOffer'
             LEFT JOIN dbo.RefResource AS rrt WITH(NOLOCK) ON ms.SecondAccept_TotalBooking = rrt.ResourceId
                                                              AND rrt.RefName = 'MatchOffer'
             LEFT JOIN dbo.RefResource AS rrf WITH(NOLOCK) ON ms.SecondAccept_Fantasy = rrf.ResourceId
                                                              AND rrf.RefName = 'MatchOffer'
             OUTER APPLY
        (
            SELECT TOP 1 *
            FROM dbo.UserLog ul
                 LEFT JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = ul.CreatorId
            WHERE ul.ObjectId = ms.FT_HDP
                  AND ul.ActionId IN(128)
            ORDER BY ul.LoggedDate DESC
        ) AS lg
        WHERE(@FT_HDP = 0
              OR FT_HDP = @FT_HDP)
        ORDER BY FT_HDP DESC;
    END;