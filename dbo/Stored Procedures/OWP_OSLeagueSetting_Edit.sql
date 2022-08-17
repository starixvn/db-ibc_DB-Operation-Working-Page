
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_OSLeagueSetting_Edit @UserId          INT, 
                                         @LeagueSettingId INT, 
                                         @IsActive        BIT, 
                                         @Region        INT=NULL, 
                                         @Category      INT=NULL, 
                                         @Rounds         VARCHAR(100), 
                                         @WeekMatch     INT=NULL, 
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
Task : Edit league setting
DB: bodb_OWP

Revisions:
	20220804@Carlos: Initial - [Redmine: #175994]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tblRound TABLE(Id INT);
        DECLARE @tblOfferLine TABLE(Id INT);
        DECLARE @tblProvider TABLE(Id INT);
        DECLARE @tblBettype TABLE(Id INT);
        DECLARE @tblBetDelay TABLE(Id INT);
        DECLARE @OSLeagueId INT;

        INSERT INTO @tblRound(Id)
        SELECT  NULLIF(value, '')
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

        SELECT @OSLeagueId = OSLeagueId
        FROM OSLeagueSetting
        WHERE LeagueSettingId = @LeagueSettingId;

        -- WRITE LOG
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogDataOld NVARCHAR(MAX), @LogData NVARCHAR(MAX), @XmlOld XML, @XmlNew XML;
        SET @StartRun = GETDATE();
        -- Declare Log Old Variable
        DECLARE @IsActiveOld NVARCHAR(MAX);
        DECLARE @RoundInfoOld NVARCHAR(MAX);
        DECLARE @RegionInfoOld NVARCHAR(MAX);
        DECLARE @CategoryInfoOld NVARCHAR(MAX);
        DECLARE @WeekMatchInfoOld NVARCHAR(MAX);
        DECLARE @OfferLinesInfoOld NVARCHAR(MAX);
        DECLARE @BetDelayInfoOld NVARCHAR(MAX);
        DECLARE @ProviderInfoOld NVARCHAR(MAX);
        DECLARE @IsManualUpdateScoreInfoOld NVARCHAR(MAX);
        DECLARE @IsIpTvOnlyInfoOld NVARCHAR(MAX);
        DECLARE @BettypeInfoOld NVARCHAR(MAX);
        -- Declare Log New Variable
        DECLARE @IsActiveNew NVARCHAR(MAX);
        DECLARE @RoundInfoNew NVARCHAR(MAX);
        DECLARE @RegionInfoNew NVARCHAR(MAX);
        DECLARE @CategoryInfoNew NVARCHAR(MAX);
        DECLARE @WeekMatchInfoNew NVARCHAR(MAX);
        DECLARE @OfferLinesInfoNew NVARCHAR(MAX);
        DECLARE @BetDelayInfoNew NVARCHAR(MAX);
        DECLARE @ProviderInfoNew NVARCHAR(MAX);
        DECLARE @IsManualUpdateScoreInfoNew NVARCHAR(MAX);
        DECLARE @IsIpTvOnlyInfoNew NVARCHAR(MAX);
        DECLARE @BettypeInfoNew NVARCHAR(MAX);
        -- Old Data
        -- IsActive
        SELECT @IsActiveOld = CASE ol.IsActive
                                  WHEN 1
                                  THEN 'true'
                                  ELSE 'false'
                              END
        FROM OSLeague ol
        WHERE ol.OSLeagueId = @OSLeagueId;
        -- Region
        SELECT @RegionInfoOld = oro.Label
        FROM OSLeague ol
             INNER JOIN OSRegionOption oro ON ol.RegionId = oro.Id
        WHERE ol.OSLeagueId = @OSLeagueId;
        -- Category
        SELECT @CategoryInfoOld = oco.Label
        FROM OSLeague ol
             INNER JOIN OSCategoryOption oco ON ol.CategoryId = oco.Id
        WHERE ol.OSLeagueId = @OSLeagueId;
        -- Round
        SELECT @RoundInfoOld = STRING_AGG(oso.Label, ',')
        FROM OSSettingRound osr
             INNER JOIN OSRoundOption oso ON osr.RoundId = oso.Id
        WHERE osr.LeagueSettingId = @LeagueSettingId;
        -- OfferLines
        SELECT @OfferLinesInfoOld = STRING_AGG(oso.Label, ',')
        FROM OSSettingOfferLine ofl
             INNER JOIN OSOfferLineOption oso ON ofl.OfferLineId = oso.Id
        WHERE ofl.LeagueSettingId = @LeagueSettingId;
        -- Provider
        SELECT @ProviderInfoOld = STRING_AGG(oso.Label, ',')
        FROM OSSettingProvider op
             INNER JOIN OSProviderOption oso ON op.ProviderId = oso.Id
        WHERE op.LeagueSettingId = @LeagueSettingId;
        -- Bettype
        SELECT @BettypeInfoOld = STRING_AGG(oso.Label, ',')
        FROM OSSettingBettype ob
             INNER JOIN OSBettypeOption oso ON ob.BettypeId = oso.Id
        WHERE ob.LeagueSettingId = @LeagueSettingId;
        -- BetDelay
        SELECT @BetDelayInfoOld = STRING_AGG(oso.Label, ',')
        FROM OSSettingBetDelay ob
             INNER JOIN OSBetDelayOption oso ON ob.BetDelayId = oso.Id
        WHERE ob.LeagueSettingId = @LeagueSettingId;
        -- WeekMatch
        SELECT @WeekMatchInfoOld = omo.Label
        FROM OSLeagueSetting os
             INNER JOIN OSWeekMatchOption omo ON os.WeekMatchId = omo.Id
        WHERE os.LeagueSettingId = @LeagueSettingId;
        -- Update Score, Iptv
        SELECT @IsManualUpdateScoreInfoOld = CASE ols.IsManualUpdateScore
                                                 WHEN 1
                                                 THEN 'true'
                                                 ELSE 'false'
                                             END, 
               @IsIpTvOnlyInfoOld = CASE ols.IsIptvOnly
                                        WHEN 1
                                        THEN 'true'
                                        ELSE 'false'
                                    END
        FROM OSLeagueSetting ols
        WHERE ols.LeagueSettingId = @LeagueSettingId;
        SET @XmlOld =
        (
            SELECT ol.LeagueName '@osLeagueName', 
                   @IsActiveOld '@osIsActive', 
                   ISNULL(@RegionInfoOld, '') '@osRegion', 
                   ISNULL(@CategoryInfoOld, '') '@osCategory', 
                   ISNULL(@RoundInfoOld, '') '@osRound', 
                   ISNULL(@WeekMatchInfoOld, '') '@osWeekMatch', 
                   @OfferLinesInfoOld '@osOfferLines', 
                   @BetDelayInfoOld '@osBetDelay', 
                   ISNULL(@ProviderInfoOld, '') '@osProvider', 
                   ISNULL(ols.KOFromTime, '') '@osKOFromTime', 
                   ISNULL(ols.KOToTime, '') '@osKOToTime', 
                   ISNULL(ols.SpreadHDP, '') '@osSpreadHDP', 
                   ISNULL(ols.SpreadOU, '') '@osSpreadOU', 
                   ols.MaxbetHDP '@osMaxBetHDP', 
                   ols.MaxbetOU '@osMaxBetOU', 
                   ISNULL(ols.Remark, '') '@osRemark', 
                   @IsManualUpdateScoreInfoOld '@osIsManualUpdateScore', 
                   @IsIpTvOnlyInfoOld '@osIsIpTvOnly', 
                   @BettypeInfoOld '@osBetType'
            FROM OSLeagueSetting ols
                 INNER JOIN OSLeague ol ON ols.OSLeagueId = ol.OSLeagueId
            WHERE ols.LeagueSettingId = @LeagueSettingId FOR XML PATH('z'), ROOT('r')
        );
        SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlOld), '" />', '"/"');

        --League--
        UPDATE OSLeague
        SET 
              IsActive = @IsActive, 
              RegionId = @Region, 
              CategoryId = @Category
        WHERE OSLeagueId = @OSLeagueId;

        --Setting--
        UPDATE OSLeagueSetting
          SET 
              WeekMatchId = @WeekMatch, 
              KOFromTime = @KOFromTime, 
              KOToTime = @KOToTime, 
              Remark = @Remark, 
              IsManualUpdateScore = @IsManualUpdateScore, 
              IsIptvOnly = @IsIptvOnly, 
              MaxbetHDP = @MaxbetHDP, 
              MaxbetOU = @MaxbetOU, 
              SpreadHDP = @SpreadHDP, 
              SpreadOU = @SpreadOU
        WHERE LeagueSettingId = @LeagueSettingId;

        --Round--
        DELETE FROM OSSettingRound
        WHERE LeagueSettingId = @LeagueSettingId;

        INSERT INTO OSSettingRound
        (LeagueSettingId, 
         RoundId
        )
         SELECT @LeagueSettingId, 
                r.Id
         FROM @tblRound AS r;

        --Offerline--
        DELETE FROM OSSettingOfferLine
        WHERE LeagueSettingId = @LeagueSettingId;
        INSERT INTO OSSettingOfferLine
        (LeagueSettingId, 
         OfferLineId
        )
         SELECT @LeagueSettingId, 
                      r.Id
         FROM @tblOfferLine AS r;

        --Provider--
        DELETE FROM OSSettingProvider
        WHERE LeagueSettingId = @LeagueSettingId;
        INSERT INTO OSSettingProvider
        (LeagueSettingId, 
         ProviderId
        )
               SELECT @LeagueSettingId, 
                      r.Id
               FROM @tblProvider AS r;

        --Bettype--
        DELETE FROM OSSettingBettype
        WHERE LeagueSettingId = @LeagueSettingId;
        INSERT INTO OSSettingBettype
        (LeagueSettingId, 
         BettypeId
        )
               SELECT @LeagueSettingId, 
                      r.Id
               FROM @tblBettype AS r;
        --BetDelay
        DELETE FROM OSSettingBetDelay
        WHERE LeagueSettingId = @LeagueSettingId;
        INSERT INTO OSSettingBetDelay
        (LeagueSettingId, 
         BetDelayId
        )
               SELECT @LeagueSettingId, 
                      r.Id
               FROM @tblBetDelay AS r;
        -- New Data
        --Region
        SELECT @RegionInfoNew = STRING_AGG(o.Label, ',')
        FROM OSRegionOption o
        WHERE o.Id = @Region;
        --Category
        SELECT @CategoryInfoNew = oc.Label
        FROM OSCategoryOption oc
        WHERE oc.Id = @Category;
        --Round
        SELECT @RoundInfoNew = STRING_AGG(o.Label, ',')
        FROM OSRoundOption o, 
             @tblRound r
        WHERE o.Id = r.Id;
        --Weekmatch
        SELECT @WeekMatchInfoNew = ow.Label
        FROM OSWeekMatchOption ow
        WHERE ow.Id = @WeekMatch;
        --OfferLines
        SELECT @OfferLinesInfoNew = STRING_AGG(ofl.Label, ',')
        FROM OSOfferLineOption ofl, 
             @tblOfferLine tfl
        WHERE ofl.Id = tfl.Id;
        --BetDelay
        SELECT @BetDelayInfoNew = STRING_AGG(ob.Label, ',')
        FROM OSBetDelayOption ob, 
             @tblBetDelay tbd
        WHERE ob.Id = tbd.Id;
        --Provider
        SELECT @ProviderInfoNew = STRING_AGG(op.Label, ',')
        FROM OSProviderOption op, 
             @tblProvider tp
        WHERE op.Id = tp.Id;
        --UpdateScore
        SELECT @IsManualUpdateScoreInfoNew = CASE @IsManualUpdateScore
                                                 WHEN 1
                                                 THEN 'true'
                                                 ELSE 'false'
                                             END;
        --Iptv
        SELECT @IsIpTvOnlyInfoNew = CASE @IsIptvOnly
                                        WHEN 1
                                        THEN 'true'
                                        ELSE 'false'
                                    END;
        --Bettype
        SELECT @BettypeInfoNew = STRING_AGG(obo.Label, ',')
        FROM OSBettypeOption obo, 
             @tblBettype bt
        WHERE obo.Id = bt.Id;
        --IsActive
        SELECT @IsActiveNew = CASE @IsActive
                                  WHEN 1
                                  THEN 'true'
                                  ELSE 'false'
                              END;
        SET @XmlNew =
        (
            SELECT ol.LeagueName '@osLeagueName', 
                   @IsActiveNew '@osIsActive', 
                   ISNULL(@RegionInfoNew, '') '@osRegion', 
                   ISNULL(@CategoryInfoNew, '') '@osCategory', 
                   ISNULL(@RoundInfoNew, '') '@osRound', 
                   ISNULL(@WeekMatchInfoNew, '') '@osWeekMatch', 
                   @OfferLinesInfoNew '@osOfferLines', 
                   @BetDelayInfoNew '@osBetDelay', 
                   ISNULL(@ProviderInfoNew, '') '@osProvider', 
                   ISNULL(@KOFromTime, '') '@osKOFromTime', 
                   ISNULL(@KOToTime, '') '@osKOToTime', 
                   ISNULL(@SpreadHDP, '') '@osSpreadHDP', 
                   ISNULL(@SpreadOU, '') '@osSpreadOU', 
                   @MaxbetHDP '@osMaxBetHDP', 
                   @MaxbetOU '@osMaxBetOU', 
                   ISNULL(@Remark, '') '@osRemark', 
                   @IsManualUpdateScoreInfoNew '@osIsManualUpdateScore', 
                   @IsIpTvOnlyInfoNew '@osIsIpTvOnly', 
                   @BettypeInfoNew '@osBetType'
            FROM OSLeagueSetting ols
                 INNER JOIN OSLeague ol ON ols.OSLeagueId = ol.OSLeagueId
            WHERE ols.LeagueSettingId = @LeagueSettingId FOR XML PATH('z'), ROOT('r')
        );
        SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @XmlNew), '" />', '"/"');
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @UserId, 
             @SPName = 'OWP_OSLeagueSetting_Edit', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @ObjectId = @LeagueSettingId, 
             @Data = @LogData, 
             @DataOld = @LogDataOld;
    END;