
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_NewLeagueSetting_InsertLeagueSetting] @LeagueSettingId          INT OUTPUT, 
                                                                 @League                   NVARCHAR(2000), 
                                                                 @ActorId                  INT, 
                                                                 @LeagueGroupId            INT            = NULL, 
                                                                 @Spread_HDP_Value         MONEY          = NULL, 
                                                                 @Spread_OU_Value          MONEY          = NULL, 
                                                                 @Spread_Note              NVARCHAR(2000) = NULL, 
                                                                 @MaxbetWD_HDP_Value       MONEY          = NULL, 
                                                                 @MaxbetWD_HDP_Note        NVARCHAR(2000) = NULL, 
                                                                 @WD_NoOfHDP_Value         NVARCHAR(2000) = NULL, 
                                                                 @WD_NoOfHDP_Note          NVARCHAR(2000) = NULL, 
                                                                 @MaxbetWK_HDP_value       MONEY          = NULL, 
                                                                 @MaxbetWK_HDP_Note        NVARCHAR(2000) = NULL, 
                                                                 @WK_NoOfHDP_value         NVARCHAR(2000) = NULL, 
                                                                 @WK_NoOfHDP_Note          NVARCHAR(2000) = NULL, 
                                                                 @LstNote                  NVARCHAR(2000) = NULL, 
                                                                 @Remark2                  NVARCHAR(2000) = NULL, 
                                                                 @Comment                  NVARCHAR(2000) = NULL, 
                                                                 @FullConditionDescription NVARCHAR(2000) = NULL
AS

/*      
 Created: 20240801@Los
 Task : Init sp
 DB: bodb_OWP      
 
 Revisions:
    20240801@Los: Insert league setting   - [Redmine: #207941]

*/

    BEGIN
        SET NOCOUNT ON;

        /*Insert or update league*/

        IF EXISTS
        (
            SELECT 1
            FROM OWPLeague WITH(NOLOCK)
            WHERE OWPLeagueName = @League
        )
            BEGIN
                UPDATE OWPLeague
                  SET 
                      New_CategoryId = @LeagueGroupId;
        END;
            ELSE
            BEGIN
                INSERT INTO OWPLeague
                (OWPLeagueName, 
                 New_CategoryId
                )
                VALUES
                (@League, 
                 @LeagueGroupId
                );
        END;
        INSERT INTO LeagueManagementSetting
        ([OWPLeagueId], 
         [Spread_HDP], 
         [Spread_OU], 
         [Spread_Note], 
         [MaxbetWD_HDP], 
         [MaxbetWD_HDP_Note], 
         [WD_NoOfHDP], 
         [WD_NoOfHDP_Note], 
         [MaxbetWK_HDP], 
         [MaxbetWK_HDP_Note], 
         [WK_NoOfHDP], 
         [WK_NoOfHDP_Note], 
         [LSTNote], 
         [Remark2], 
         [Comment], 
         [FullConditionDescription]
        )
               SELECT TOP 1 owpl.OWPLeagueId, 
                            @Spread_HDP_Value, 
                            @Spread_OU_Value, 
                            @Spread_Note, 
                            @MaxbetWD_HDP_Value, 
                            @MaxbetWD_HDP_Note, 
                            @WD_NoOfHDP_Value, 
                            @WD_NoOfHDP_Note, 
                            @MaxbetWK_HDP_value, 
                            @MaxbetWK_HDP_Note, 
                            @WK_NoOfHDP_value, 
                            @WK_NoOfHDP_Note, 
                            @LstNote, 
                            @Remark2, 
                            @Comment, 
                            @FullConditionDescription
               FROM OWPLeague AS owpl WITH(NOLOCK)
               WHERE owpl.OWPLeagueName = @League;
        SELECT @LeagueSettingId = @@IDENTITY;
    END;