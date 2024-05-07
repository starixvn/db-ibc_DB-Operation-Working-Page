
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_NewLeagueSetting_UpdateLeagueSetting] @LeagueSettingId          INT, 
                                                                  @OWPLeagueId              INT, 
                                                                  @LeagueGroupId            INT, 
                                                                  @Spread_HDP_value         MONEY NULL, 
                                                                  @Spread_OU_value          MONEY NULL, 
                                                                  @Spread_Note              NVARCHAR(2000) NULL, 
                                                                  @MaxbetWD_HDP_value       MONEY NULL, 
                                                                  @MaxbetWD_HDP_Note        NVARCHAR(2000) NULL, 
                                                                  @MaxbetWD_NoOfHDP_value   NVARCHAR(2000) NULL, 
                                                                  @MaxbetWD_NoOfHDP_Note    NVARCHAR(2000) NULL, 
                                                                  @MaxbetWK_HDP_value       MONEY NULL, 
                                                                  @MaxbetWK_HDP_Note        NVARCHAR(2000) NULL, 
                                                                  @MaxbetWK_NoOfHDP_value   NVARCHAR(2000) NULL, 
                                                                  @MaxbetWK_NoOfHDP_Note    NVARCHAR(2000) NULL, 
                                                                  @LstNote                  NVARCHAR(2000), 
                                                                  @Remark2                  NVARCHAR(2000), 
                                                                  @Comment                  NVARCHAR(2000), 
                                                                  @FullConditionDescription NVARCHAR(2000)
AS

/*      
 Created: 20240429@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20240429@Liam: Get new league Setting detail   - [Redmine: #202639]

*/

    BEGIN
        SET NOCOUNT ON;

        UPDATE OWPLeague
          SET 
              New_CategoryId = @LeagueGroupId
        WHERE OWPLeagueId = @OWPLeagueId;
        UPDATE LeagueManagementSetting
          SET 
              MaxbetWD_HDP = @MaxbetWD_HDP_value, 
              MaxbetWD_HDP_Note = @MaxbetWD_HDP_Note, 
              MaxbetWK_HDP = @MaxbetWK_HDP_value, 
              MaxbetWK_HDP_Note = @MaxbetWK_HDP_Note, 
              Spread_HDP = @Spread_HDP_value, 
              Spread_OU = @Spread_OU_value, 
              Spread_Note = @Spread_Note, 
              MaxbetWD_NoOfHDP = @MaxbetWD_NoOfHDP_value, 
              MaxbetWD_NoOfHDP_Note = @MaxbetWD_NoOfHDP_Note, 
              MaxbetWK_NoOfHDP = @MaxbetWK_NoOfHDP_value, 
              MaxbetWK_NoOfHDP_Note = @MaxbetWK_NoOfHDP_Note, 
              LSTNote = @LstNote, 
              Remark2 = @Remark2, 
              Comment = @Comment, 
              FullConditionDescription = @FullConditionDescription
        WHERE Id = @LeagueSettingId;
    END;
