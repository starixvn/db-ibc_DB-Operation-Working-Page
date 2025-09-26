
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
                                                                 @FullConditionDescription NVARCHAR(2000) = NULL,
																 @NoOfferLive              BIT,
                                                                 @LogData                  NVARCHAR(MAX) = NULL
AS

/*      
 Created: 20240801@Los
 Task : Init sp
 DB: bodb_OWP      
 
 Revisions:
    20240801@Los: Insert league setting   - [Redmine: #207941]
	20250821@Los: Update NoOfferLive, BlackList - [Redmine: #234901]

*/

    BEGIN
        SET NOCOUNT ON;
		DECLARE @OWPLeagueId INT = NULL;
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogSettingData NVARCHAR(MAX), @XmlSettingNew XML, @LogInfoData NVARCHAR(MAX), @XmlInfoNew XML;
        SET @StartRun = GETDATE();

        /*Insert or update league*/

       IF EXISTS (SELECT 1 FROM OWPLeague WITH(NOLOCK) WHERE OWPLeagueName = @League)
        BEGIN
            -- Update existing league
            UPDATE OWPLeague WITH(ROWLOCK)
            SET New_CategoryId = @LeagueGroupId
            WHERE OWPLeagueName = @League;
            
            SELECT @OWPLeagueId = OWPLeagueId
            FROM OWPLeague WITH(NOLOCK)
            WHERE OWPLeagueName = @League;
        END
        ELSE
        BEGIN
            -- Insert new league
            INSERT INTO OWPLeague (OWPLeagueName, New_CategoryId, NoOfferLive)
            VALUES (@League, @LeagueGroupId, @NoOfferLive);
            
            SELECT @OWPLeagueId = SCOPE_IDENTITY();
        END


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

		EXEC dbo.OWP_OWPLeague_UpdateGroup @ActorId, @OWPLeagueId, @LeagueGroupId

        -- log new league setting 
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
             @DataOld = NULL;

         IF @LogData IS NOT NULL
         BEGIN
			DECLARE @LogDate DATETIME = DATEADD(HOUR, 8, GETUTCDATE());

            EXEC dbo.OWP_LeagueManagement_InsertLog 
                @SettingId = @LeagueSettingId,
                @ModifiedBy = @ActorId,
                @CreatedDate = @LogDate,
                @Action = 'Created',
                @Content = @LogData;
         END
    END;