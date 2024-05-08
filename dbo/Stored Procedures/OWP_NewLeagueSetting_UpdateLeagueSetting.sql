
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_NewLeagueSetting_UpdateLeagueSetting] @LeagueSettingId          INT, 
                                                                  @OWPLeagueId              INT, 
																  @UserId                   INT,
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
        -- WRITE LOG
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogSettingDataOld NVARCHAR(MAX), @LogSettingData NVARCHAR(MAX), @XmlSettingOld XML, @XmlSettingNew XML, @LogInfoDataOld NVARCHAR(MAX), @LogInfoData NVARCHAR(MAX), @XmlInfoOld XML, @XmlInfoNew XML;
        SET @StartRun = GETDATE();

        SET @XmlSettingOld =
        (
            SELECT l.Id 'LeagueSettingId', 
                   l.OWPLeagueId, 
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
                   o.New_CategoryId 'LeagueGroupId'
            FROM LeagueManagementSetting l
                 INNER JOIN OWPLeague o ON l.OWPLeagueId = o.OWPLeagueId
            WHERE l.Id = @LeagueSettingId FOR XML PATH('z'), ROOT('r')
        );
        SET @LogSettingDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlSettingOld), '" />', '"/"');



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



        SET @XmlSettingNew =
        (
            SELECT l.Id 'LeagueSettingId', 
                   l.OWPLeagueId, 
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
                   o.New_CategoryId 'LeagueGroupId'
            FROM LeagueManagementSetting l
                 INNER JOIN OWPLeague o ON l.OWPLeagueId = o.OWPLeagueId
            WHERE l.Id = @LeagueSettingId FOR XML PATH('z'), ROOT('r')
        );
        SET @LogSettingData = REPLACE(CONVERT(NVARCHAR(MAX), @XmlSettingNew), '" />', '"/"');
		 SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @UserId, 
             @SPName = 'OWP_NewLeagueSetting_UpdateLeagueSetting', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @ObjectId = @LeagueSettingId, 
             @Data = @LogSettingData, 
             @DataOld = @LogSettingDataOld;
    END;