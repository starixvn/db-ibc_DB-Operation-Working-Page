
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_OSLeagueSetting_Add @UserId      INT, 
                                        @LeagueName  NVARCHAR(2000), 
                                        @RegionId    INT, 
                                        @CategoryId  INT, 
                                        @RoundId     VARCHAR(100), 
                                        @WeekMatchId INT, 
                                        @OfferLineId VARCHAR(100), 
                                        @BetDelayId  VARCHAR(100),
                                        @ProviderId  VARCHAR(100), 
                                        @FromTime    TIME, 
                                        @ToTime      TIME, 
                                        @SpreadHDP   MONEY, 
                                        @SpreadOU    MONEY, 
                                        @MaxbetOU    MONEY, 
                                        @MaxbetHDP   MONEY, 
                                        @Remark      VARCHAR(2000), 
                                        @UpdateScore BIT, 
                                        @IpTv        BIT, 
                                        @Bettype     VARCHAR(100)
AS

/*
Created: 20220804@Carlos
Task : New league setting
DB: bodb_OWP

Revisions:
	20220804@Carlos: Initial - [Redmine: #175994]
*/

    BEGIN
        SET NOCOUNT ON;
        -- WRITE LOG
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogDataOld NVARCHAR(MAX), @LogData NVARCHAR(MAX), @Xml XML;
        SET @StartRun = GETDATE();
        DECLARE @tblRound TABLE(Id INT);
        DECLARE @tblOfferLine TABLE(Id INT);
        DECLARE @tblProvider TABLE(Id INT);
        DECLARE @tblBettype TABLE(Id INT);
		DECLARE @tblBetDelay TABLE(Id INT);
        DECLARE @OSLeagueId INT;
        DECLARE @OSSettingId INT;
        DECLARE @RoundInfo NVARCHAR(MAX);
        DECLARE @RegionInfo NVARCHAR(MAX);
        DECLARE @CategoryInfo NVARCHAR(MAX);
        DECLARE @WeekMatchInfo NVARCHAR(MAX);
        DECLARE @OfferLinesInfo NVARCHAR(MAX);
        DECLARE @BetDelayInfo NVARCHAR(MAX);
        DECLARE @ProviderInfo NVARCHAR(MAX);
        DECLARE @IsManualUpdateScoreInfo NVARCHAR(MAX);
        DECLARE @IsIpTvOnlyInfo NVARCHAR(MAX);
        DECLARE @BettypeInfo NVARCHAR(MAX);
        INSERT INTO @tblRound(Id)
               SELECT NULLIF(value, '')
               FROM STRING_SPLIT(@RoundId, ',');
        INSERT INTO @tblOfferLine(Id)
               SELECT NULLIF(value, '')
               FROM STRING_SPLIT(@OfferLineId, ',');
        INSERT INTO @tblProvider(Id)
               SELECT NULLIF(value, '')
               FROM STRING_SPLIT(@ProviderId, ',');
        INSERT INTO @tblBettype(Id)
               SELECT NULLIF(value, '')
               FROM STRING_SPLIT(@Bettype, ',');
		INSERT INTO @tblBetDelay(Id)
				SELECT NULLIF(value, '')
               FROM STRING_SPLIT(@BetDelayId, ','); 
        IF EXISTS
        (
            SELECT 1
            FROM OSLeague
            WHERE LeagueName = @LeagueName
        )
            BEGIN
                UPDATE OSLeague
                  SET 
                      RegionId = @RegionId, 
                      CategoryId = @CategoryId
                WHERE LeagueName = @LeagueName;
        END;
            ELSE
            BEGIN
                --League--
                INSERT INTO OSLeague
                (LeagueName, 
                 IsActive, 
                 RegionId, 
                 CategoryId
                )
                VALUES
                (@LeagueName, 
                 1, 
                 @RegionId, 
                 @CategoryId
                );
        END;
        SELECT @OSLeagueId = OSLeagueId
        FROM OSLeague
        WHERE LeagueName = @LeagueName;

        --Setting--
        INSERT INTO OSLeagueSetting
        (OSLeagueId, 
         WeekMatchId, 
         BetDelayId, 
         KOFromTime, 
         KOToTime, 
         Remark, 
         IsManualUpdateScore, 
         IsIptvOnly, 
         MaxbetHDP, 
         MaxbetOU, 
         SpreadHDP, 
         SpreadOU
        )
        VALUES
        (@OSLeagueId, 
         @WeekMatchId, 
         @BetDelayId, 
         @FromTime, 
         @ToTime, 
         @Remark, 
         @UpdateScore, 
         @IpTv, 
         @MaxbetHDP, 
         @MaxbetOU, 
         @SpreadHDP, 
         @SpreadOU
        );
        SELECT @OSSettingId = MAX(LeagueSettingId)
        FROM OSLeagueSetting
        WHERE OSLeagueId = @OSLeagueId;

        --Round--
        INSERT INTO OSSettingRound
        (LeagueSettingId, 
         RoundId
        )
               SELECT @OSSettingId, 
                      r.Id
               FROM @tblRound AS r;

        --Offerline--
        INSERT INTO OSSettingOfferLine
        (LeagueSettingId, 
         OfferLineId
        )
               SELECT @OSSettingId, 
                      r.Id
               FROM @tblOfferLine AS r;

        --Provider--
        INSERT INTO OSSettingProvider
        (LeagueSettingId, 
         ProviderId
        )
               SELECT @OSSettingId, 
                      r.Id
               FROM @tblBettype AS r;

        --Bettype--
        INSERT INTO OSSettingBettype
        (LeagueSettingId, 
         BettypeId
        )
               SELECT @OSSettingId, 
                      r.Id
               FROM @tblProvider AS r;
        -- Write Log
        SELECT @RegionInfo = STRING_AGG(o.Label, ',')
        FROM OSRegionOption o
        WHERE o.Id = @RegionId;
        SELECT @CategoryInfo = oc.Label
        FROM OSCategoryOption oc
        WHERE oc.Id = @CategoryId;
        SELECT @RoundInfo = STRING_AGG(o.Label, ',')
        FROM OSRoundOption o, 
             @tblRound r
        WHERE o.Id = r.Id;
        SELECT @WeekMatchInfo = ow.Label
        FROM OSWeekMatchOption ow
        WHERE ow.Id = @WeekMatchId;
        SELECT @OfferLinesInfo = STRING_AGG(ofl.Label, ',')
        FROM OSOfferLineOption ofl, 
             @tblOfferLine tfl
        WHERE ofl.Id = tfl.Id;
        SELECT @BetDelayInfo = ob.Label
        FROM OSBetDelayOption ob, @tblBetDelay bd
        WHERE ob.Id = bd.Id;
        SELECT @ProviderInfo = op.Label
        FROM OSProviderOption op
        WHERE op.Id = @ProviderId;
        SELECT @IsManualUpdateScoreInfo = CASE @UpdateScore
                                              WHEN 'True'
                                              THEN 'true'
                                              ELSE 'false'
                                          END;
        SELECT @IsIpTvOnlyInfo = CASE @IpTv
                                     WHEN 'True'
                                     THEN 'true'
                                     ELSE 'false'
                                 END;
        SELECT @BettypeInfo = STRING_AGG(obo.Label, ',')
        FROM OSBettypeOption obo, 
             @tblBettype bt
        WHERE obo.Id = bt.Id;
        SET @Xml =
        (
            SELECT ol.LeagueName '@osLeagueName', 
                   ISNULL(@RegionInfo, '') 'osRegion', 
                   ISNULL(@CategoryInfo, '') 'osCategory', 
                   ISNULL(@RoundInfo, '') 'osRound', 
                   ISNULL(@WeekMatchInfo, '') 'osWeekMatch', 
                   @OfferLinesInfo 'osOfferLines', 
                   @BetDelayInfo 'osBetDelay', 
                   ISNULL(@ProviderInfo, '') 'osProvider', 
                   ISNULL(@FromTime, '') 'osKOFromTime', 
                   ISNULL(@ToTime, '') 'osKOToTime', 
                   ISNULL(@SpreadHDP, '') 'osSpreadHDP', 
                   ISNULL(@SpreadOU, '') 'osSpreadOU', 
                   @MaxbetHDP 'osMaxBetHDP', 
                   @MaxbetOU 'osMaxBetOU', 
                   ISNULL(@Remark, '') 'osRemark', 
                   @IsManualUpdateScoreInfo 'osIsManualUpdateScore', 
                   @IsIpTvOnlyInfo 'osIsIpTvOnly', 
                   @BettypeInfo 'osBetType'
            FROM OSLeagueSetting ols
                 INNER JOIN OSLeague ol ON ols.OSLeagueId = ol.OSLeagueId FOR XML PATH('z'), ROOT('r')
        );
        SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
        SET @LogDataOld = NULL;
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        IF @OSSettingId <> -1
            EXEC dbo.OWP_WriteLog 
                 @CreatorId = @UserId, 
                 @SPName = 'OWP_OSLeagueSetting_Add', 
                 @LoggedDate = @StartRun, 
                 @Duration = @Duration, 
                 @ObjectId = @OSSettingId, 
                 @Data = @LogData, 
                 @DataOld = @LogDataOld;
    END;