
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_OSLeagueSetting_Add
	@LeagueName NVARCHAR(2000),
	@RegionId INT,
	@CategoryId INT,
	@RoundId VARCHAR(100),
	@WeekMatchId INT,
	@OfferLineId VARCHAR(100),
	@BetDelayId INT,
	@ProviderId VARCHAR(100),
	@FromTime TIME,
	@ToTime TIME,
	@SpreadHDP MONEY,
	@SpreadOU MONEY,
	@MaxbetOU MONEY,
	@MaxbetHDP MONEY,
	@Remark VARCHAR(2000),
	@UpdateScore BIT,
	@IpTv BIT,
	@Bettype VARCHAR(100)
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
       
	   DECLARE @tblRound TABLE(Id INT);
	   DECLARE @tblOfferLine TABLE(Id INT);
	   DECLARE @tblProvider TABLE(Id INT);
	   DECLARE @tblBettype TABLE(Id INT);
	   DECLARE @OSLeagueId INT;
	   DECLARE @OSSettingId INT

	   INSERT INTO @tblRound(Id)
	   SELECT NULLIF(value,'')
	   FROM STRING_SPLIT(@RoundId, ',');

	   INSERT INTO @tblOfferLine(Id)
	   SELECT NULLIF(value,'')
	   FROM STRING_SPLIT(@RoundId, ',');

	   INSERT INTO @tblProvider(Id)
	   SELECT NULLIF(value,'')
	   FROM STRING_SPLIT(@RoundId, ',');

	   INSERT INTO @tblBettype(Id)
	   SELECT NULLIF(value,'')
	   FROM STRING_SPLIT(@Bettype, ',');

		
	   IF EXISTS
	   (
			SELECT 1
			FROM OSLeague
			WHERE LeagueName=@LeagueName
	   )
	   BEGIN
		UPDATE OSLeague
		SET RegionId=@RegionId,
			CategoryId=@CategoryId
		WHERE LeagueName=@LeagueName
	   END
	   ELSE
	   BEGIN
			--League--
		   INSERT INTO OSLeague(LeagueName, IsActive, RegionId, CategoryId)
		   VALUES(@LeagueName, 1, @RegionId, @CategoryId);
	   END

		SELECT @OSLeagueId=OSLeagueId
		FROM OSLeague
		WHERE LeagueName=@LeagueName

	    --Setting--
	   INSERT INTO OSLeagueSetting(
		   OSLeagueId, 
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
		   SpreadOU)
	   VALUES(
		   @OSLeagueId,
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
		   @SpreadOU)

		 SELECT @OSSettingId= MAX(LeagueSettingId)
		 FROM OSLeagueSetting
		 WHERE OSLeagueId=@OSLeagueId

		 --Round--
		 INSERT INTO OSSettingRound(LeagueSettingId, RoundId)
		 SELECT @OSSettingId, r.Id
		 FROM @tblRound AS r

		  --Offerline--
		 INSERT INTO OSSettingOfferLine(LeagueSettingId, OfferLineId)
		 SELECT @OSSettingId, r.Id
		 FROM @tblOfferLine AS r

		  --Provider--
		 INSERT INTO OSSettingProvider(LeagueSettingId, ProviderId)
		 SELECT @OSSettingId, r.Id
		 FROM @tblBettype AS r

		  --Bettype--
		 INSERT INTO OSSettingBettype(LeagueSettingId, BettypeId)
		 SELECT @OSSettingId, r.Id
		 FROM @tblProvider AS r
    END;