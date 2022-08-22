
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MaxbetSetting_Get] @FT_HDP MONEY = 0
AS

/*    
Created: 20220822@Mira
Task : Soccer Maxbet setting
DB: bodb_OWP

Revisions:
	20220822@Mira: SP get maxbet default value - [Redmine: #176781]
*/

    BEGIN
        SET NOCOUNT ON;

        -- Select maxbet all or by FT_HDP
        SELECT FT_HDP, 
               FirstHalf_HDP, 
               FirstHalf_OU, 
               NoOfCorner_FT_HDP, 
               NoOfCorner_FT_OU, 
               NoOfCorner_1H_HDP, 
               NoOfCorner_1H_OU, 
               TotalBooking_FT_HDP_OU, 
               TotalBooking_1H_HDP_OU
        FROM dbo.MaxbetSetting
        WHERE @FT_HDP = 0
              OR FT_HDP = @FT_HDP
        ORDER BY FT_HDP DESC;
    END;