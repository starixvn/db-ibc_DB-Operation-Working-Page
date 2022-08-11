
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_OSLeagueSetting_Add @UserId          INT, 
                                        @LeagueName  NVARCHAR(2000), 
                                         @Region        INT, 
                                         @Category      INT, 
                                         @Rounds         VARCHAR(100), 
                                         @WeekMatch     INT, 
                                         @OfferLines     VARCHAR(100), 
                                         @BetDelay     VARCHAR(100), 
                                         @Providers      VARCHAR(100), 
                                         @KOFromTime        DATETIME = NULL, 
                                         @KOToTime          DATETIME = NULL, 
                                         @SpreadHDP       MONEY = NULL, 
                                         @SpreadOU        MONEY = NULL, 
                                         @MaxbetOU        MONEY = NULL, 
                                         @MaxbetHDP       MONEY = NULL, 
                                         @Remark          VARCHAR(2000), 
                                         @IsManualUpdateScore     BIT, 
                                         @IsIptvOnly            BIT, 
                                         @BetTypes         VARCHAR(100)
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
        DECLARE @IsActive NVARCHAR(MAX);
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
               FROM STRING_SPLIT(@Rounds, ',');
        INSERT INTO @tblOfferLine(Id)
               SELECT NULLIF(value, '')
               FROM STRING_SPLIT(@OfferLines, ',');
        INSERT INTO @tblProvider(Id)
               SELECT NULLIF(value, '')
               FROM STRING_SPLIT(@Providers, ',');
        INSERT INTO @tblBettype(Id)
               SELECT NULLIF(value, '')
               FROM STRING_SPLIT(@BetTypes, ',');
        INSERT INTO @tblBetDelay(Id)
               SELECT NULLIF(value, '')
               FROM STRING_SPLIT(@BetDelay, ',');
        IF EXISTS
        (
            SELECT 1
            FROM OSLeague
            WHERE LeagueName = @LeagueName
        )
            BEGIN
                UPDATE OSLeague
                  SET 
                      RegionId = @Region, 
                      CategoryId = @Category
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
                 @Region, 
                 @Category
                );
        END;
        SELECT @OSLeagueId = OSLeagueId
        FROM OSLeague
        WHERE LeagueName = @LeagueName;

        --Setting--
        INSERT INTO OSLeagueSetting
        (OSLeagueId, 
         WeekMatchId, 
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
         @WeekMatch, 
         @KOFromTime, 
         @KOToTime, 
         @Remark, 
         @IsManualUpdateScore, 
         @IsIptvOnly, 
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
               FROM @tblProvider AS r;

        --Bettype--
        INSERT INTO OSSettingBettype
        (LeagueSettingId, 
         BettypeId
        )
               SELECT @OSSettingId, 
                      r.Id
               FROM @tblBettype AS r;
        --BetDelay--
        INSERT INTO OSSettingBetDelay
        (LeagueSettingId, 
         BetDelayId
        )
               SELECT @OSSettingId, 
                      r.Id
               FROM @tblBetDelay AS r;
        -- Write Log
        --Region
        SELECT @RegionInfo = STRING_AGG(o.Label, ',')
        FROM OSRegionOption o
        WHERE o.Id = @Region;
        --Category
        SELECT @CategoryInfo = oc.Label
        FROM OSCategoryOption oc
        WHERE oc.Id = @Category;
        --Round
        SELECT @RoundInfo = STRING_AGG(o.Label, ',')
        FROM OSRoundOption o, 
             @tblRound r
        WHERE o.Id = r.Id;
        --Weekmatch
        SELECT @WeekMatchInfo = ow.Label
        FROM OSWeekMatchOption ow
        WHERE ow.Id = @WeekMatch;
        --OfferLines
        SELECT @OfferLinesInfo = STRING_AGG(ofl.Label, ',')
        FROM OSOfferLineOption ofl, 
             @tblOfferLine tfl
        WHERE ofl.Id = tfl.Id;
        --BetDelay
        SELECT @BetDelayInfo = STRING_AGG(ob.Label, ',')
        FROM OSBetDelayOption ob, 
             @tblBetDelay tbd
        WHERE ob.Id = tbd.Id;
        --Provider
        SELECT @ProviderInfo = STRING_AGG(op.Label, ',')
        FROM OSProviderOption op, @tblProvider tp
        WHERE op.Id = tp.Id;
        --UpdateScore
        SELECT @IsManualUpdateScoreInfo = CASE @IsManualUpdateScore
                                              WHEN 1
                                              THEN 'true'
                                              ELSE 'false'
                                          END;
        --Iptv
        SELECT @IsIpTvOnlyInfo = CASE @IsIptvOnly
                                     WHEN 1
                                     THEN 'true'
                                     ELSE 'false'
                                 END;
        --Bettype
        SELECT @BettypeInfo = STRING_AGG(obo.Label, ',')
        FROM OSBettypeOption obo, 
             @tblBettype bt
        WHERE obo.Id = bt.Id;
        --IsActive
        SELECT @IsActive = CASE ol.IsActive
                               WHEN 1
                               THEN 'true'
                               ELSE 'false'
                           END
        FROM OSLeague ol
        WHERE ol.OSLeagueId = @OSLeagueId;
        SET @Xml =
        (
            SELECT ol.LeagueName '@osLeagueName', 
                   @IsActive '@osIsActive', 
                   ISNULL(@RegionInfo, '') '@osRegion', 
                   ISNULL(@CategoryInfo, '') '@osCategory', 
                   ISNULL(@RoundInfo, '') '@osRound', 
                   ISNULL(@WeekMatchInfo, '') '@osWeekMatch', 
                   @OfferLinesInfo '@osOfferLines', 
                   @BetDelayInfo '@osBetDelay', 
                   ISNULL(@ProviderInfo, '') '@osProvider', 
                   ISNULL(@KOFromTime, '') '@osKOFromTime', 
                   ISNULL(@KOToTime, '') '@osKOToTime', 
                   ISNULL(@SpreadHDP, '') '@osSpreadHDP', 
                   ISNULL(@SpreadOU, '') '@osSpreadOU', 
                   @MaxbetHDP '@osMaxBetHDP', 
                   @MaxbetOU '@osMaxBetOU', 
                   ISNULL(@Remark, '') '@osRemark', 
                   @IsManualUpdateScoreInfo '@osIsManualUpdateScore', 
                   @IsIpTvOnlyInfo '@osIsIpTvOnly', 
                   @BettypeInfo '@osBetType'
            FROM OSLeagueSetting ols
                 INNER JOIN OSLeague ol ON ols.OSLeagueId = ol.OSLeagueId
            WHERE ols.LeagueSettingId = @OSSettingId FOR XML PATH('z'), ROOT('r')
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