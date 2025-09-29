USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_NewLeagueSetting_RemoveLeagueSetting]    Script Date: 8/5/2024 1:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_NewLeagueSetting_RemoveLeagueSetting] @LeagueSettingId          INT, 
                                                                 @ActorId              INT,
                                                                 @LogData              NVARCHAR(MAX) = NULL
                                                                
AS

/*      
 Created: 20240801@Los
 Task : Init sp
 DB: bodb_OWP      
 
 Revisions:
    20240801@Los: Remove league setting   - [Redmine: #207941]
    20250916@Frankkie: Update NoOfferLive Setting when delete all setting table LeagueManagementSetting - [Redmine: #236469]
*/

    BEGIN
        SET NOCOUNT ON;

		-- WRITE LOG
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogSettingDataOld NVARCHAR(MAX), @XmlSettingOld XML, @XmlSettingNew XML, @LogInfoDataOld NVARCHAR(MAX), @LogInfoData NVARCHAR(MAX), @XmlInfoOld XML, @XmlInfoNew XML;
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

		DECLARE @OWPLeagueId INT;

		-- Lấy OWPLeagueId trước khi xoá
		SELECT @OWPLeagueId = OWPLeagueId
		FROM LeagueManagementSetting WITH(NOLOCK)
		WHERE Id = @LeagueSettingId;

		-- Xoá row
		DELETE FROM LeagueManagementSetting WITH(ROWLOCK)
		WHERE Id = @LeagueSettingId;

		-- Update nếu không còn row nào khác tham chiếu OWPLeagueId
		UPDATE OWPLeague WITH(ROWLOCK)
		SET NoOfferLive = 0
		WHERE OWPLeagueId = @OWPLeagueId
		  AND NOT EXISTS (
				SELECT 1
				FROM LeagueManagementSetting WITH(NOLOCK)
				WHERE OWPLeagueId = @OWPLeagueId
			  );

		SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);

		EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_NewLeagueSetting_RemoveLeagueSetting', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @ObjectId = @LeagueSettingId, 
             @Data = NULL,
             @DataOld = @LogSettingDataOld;

         IF @LogData IS NOT NULL
         BEGIN
			DECLARE @LogDate DATETIME = DATEADD(HOUR, 8, GETUTCDATE());
            DECLARE @Username NVARCHAR(255); 
            SELECT TOP 1 @Username = u.Username
			FROM dbo.[User] AS u WITH(NOLOCK) 
			WHERE u.UserId = @ActorId;
            
            EXEC dbo.OWP_LeagueManagement_InsertLog 
                @SettingId = @LeagueSettingId,
                @ModifiedBy = @Username,
                @CreatedDate = @LogDate,
                @Action = 'Deleted',
                @Content = @LogData;
         END
    END;