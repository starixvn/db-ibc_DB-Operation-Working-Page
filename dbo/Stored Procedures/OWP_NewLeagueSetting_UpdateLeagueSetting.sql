
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_NewLeagueSetting_UpdateLeagueSetting] @LeagueSettingId          INT, 
                                                                 @OWPLeagueId              INT, 
                                                                 @ActorId                  INT, 
                                                                 @LeagueGroupId            INT, 
                                                                 @Spread_HDP_Value         MONEY          = NULL, 
                                                                 @Spread_OU_Value          MONEY          = NULL, 
                                                                 @Spread_Note              NVARCHAR(2000) = NULL, 
                                                                 @MaxbetWD_HDP_Value       MONEY          = NULL, 
                                                                 @MaxbetWD_HDP_Note        NVARCHAR(2000) = NULL, 
                                                                 @WD_NoOfHDP_Value         NVARCHAR(2000) = NULL, 
                                                                 @WD_NoOfHDP_Note          NVARCHAR(2000) = NULL, 
                                                                 @MaxbetWK_HDP_Value       MONEY          = NULL, 
                                                                 @MaxbetWK_HDP_Note        NVARCHAR(2000) = NULL, 
                                                                 @WK_NoOfHDP_Value         NVARCHAR(2000) = NULL, 
                                                                 @WK_NoOfHDP_Note          NVARCHAR(2000) = NULL, 
                                                                 @LstNote                  NVARCHAR(2000) = NULL, 
                                                                 @Remark2                  NVARCHAR(2000) = NULL, 
                                                                 @Comment                  NVARCHAR(2000) = NULL, 
                                                                 @FullConditionDescription NVARCHAR(2000) = NULL, 
                                                                 @NoOfferLive              BIT
AS

/*      
 Created: 20240429@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20240429@Liam: Get new league Setting detail   - [Redmine: #202639]
	20240707@Liam: Correct maxbet setting - [Redmine: #207941]
	20250711@Hank: Update League Group into CategoryHistory - [Redmine: #232603]
	20250821@Los: Update NoOfferLive, BlackList - [Redmine: #234901]

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
                   l.[Spread_HDP] 'Spread_HDP_Value', 
                   l.[Spread_OU] 'Spread_OU_Value', 
                   l.[Spread_Note], 
                   l.[MaxbetWD_HDP] 'MaxbetWD_HDP_Value', 
                   l.[MaxbetWD_HDP_Note], 
                   l.[WD_NoOfHDP] 'WD_NoOfHDP_Value', 
                   l.[WD_NoOfHDP_Note], 
                   l.[MaxbetWK_HDP] 'WK_HDP_Value', 
                   l.[MaxbetWK_HDP_Note], 
                   l.[WK_NoOfHDP] 'MaxbetWK_NoOfHDP_Value', 
                   l.[WK_NoOfHDP_Note], 
                   l.[LSTNote], 
                   l.[Remark2], 
                   l.[Comment], 
                   o.New_CategoryId 'LeagueGroupId'
            FROM LeagueManagementSetting l WITH(NOLOCK)
                 INNER JOIN OWPLeague o WITH(NOLOCK) ON l.OWPLeagueId = o.OWPLeagueId
            WHERE l.Id = @LeagueSettingId FOR XML PATH('z'), ROOT('r')
        );
        SET @LogSettingDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlSettingOld), '" />', '"/"');
        IF NOT EXISTS
        (
            SELECT 1
            FROM LeagueCategoryHistory
            WHERE OWPLeagueId = @OWPLeagueId
                  AND CategoryId = @LeagueGroupId
                  AND EndDate IS NULL
        )
            BEGIN
                EXEC dbo.OWP_OWPLeague_UpdateGroup 
                     @ActorId, 
                     @OWPLeagueId, 
                     @LeagueGroupId;
        END;
        UPDATE OWPLeague
          SET 
              NoOfferLive = @NoOfferLive
        WHERE OWPLeagueId = @OWPLeagueId;
        UPDATE LeagueManagementSetting
          SET 
              MaxbetWD_HDP = @MaxbetWD_HDP_Value, 
              MaxbetWD_HDP_Note = @MaxbetWD_HDP_Note, 
              MaxbetWK_HDP = @MaxbetWK_HDP_Value, 
              MaxbetWK_HDP_Note = @MaxbetWK_HDP_Note, 
              Spread_HDP = @Spread_HDP_Value, 
              Spread_OU = @Spread_OU_Value, 
              Spread_Note = @Spread_Note, 
              WD_NoOfHDP = @WD_NoOfHDP_Value, 
              WD_NoOfHDP_Note = @WD_NoOfHDP_Note, 
              WK_NoOfHDP = @WK_NoOfHDP_value, 
              WK_NoOfHDP_Note = @WK_NoOfHDP_Note, 
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
                   l.[Spread_HDP] 'Spread_HDP_Value', 
                   l.[Spread_OU] 'Spread_OU_Value', 
                   l.[Spread_Note], 
                   l.[MaxbetWD_HDP] 'MaxbetWD_HDP_Value', 
                   l.[MaxbetWD_HDP_Note], 
                   l.[WD_NoOfHDP] 'WD_NoOfHDP_Value', 
                   l.[WD_NoOfHDP_Note], 
                   l.[MaxbetWK_HDP] 'WK_HDP_Value', 
                   l.[MaxbetWK_HDP_Note], 
                   l.[WK_NoOfHDP] 'MaxbetWK_NoOfHDP_Value', 
                   l.[WK_NoOfHDP_Note], 
                   l.[LSTNote], 
                   l.[Remark2], 
                   l.[Comment], 
                   o.New_CategoryId 'LeagueGroupId'
            FROM LeagueManagementSetting l WITH(NOLOCK)
                 INNER JOIN OWPLeague o WITH(NOLOCK) ON l.OWPLeagueId = o.OWPLeagueId
            WHERE l.Id = @LeagueSettingId FOR XML PATH('z'), ROOT('r')
        );
        SET @LogSettingData = REPLACE(CONVERT(NVARCHAR(MAX), @XmlSettingNew), '" />', '"/"');
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_NewLeagueSetting_UpdateLeagueSetting', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @ObjectId = @LeagueSettingId, 
             @Data = @LogSettingData, 
             @DataOld = @LogSettingDataOld;
    END;