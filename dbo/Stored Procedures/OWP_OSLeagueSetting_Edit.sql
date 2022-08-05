
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_OSLeagueSetting_Edit
	@LeagueSettingId INT,
	@IsActive BIT,
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
	   DECLARE @OSLeagueId INT;

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

		SELECT @OSLeagueId=OSLeagueId
		FROM OSLeagueSetting
		WHERE LeagueSettingId=LeagueSettingId

		--League--
	   UPDATE OSLeague
		SET RegionId=@RegionId,
			CategoryId=@CategoryId
		WHERE LeagueName=@LeagueSettingId

	    --Setting--
	   UPDATE OSLeagueSetting
	   SET
		   WeekMatchId=@WeekMatchId,
		   BetDelayId=@BetDelayId,
		   KOFromTime=@FromTime,
		   KOToTime=@ToTime,
		   Remark=@Remark,
		   IsManualUpdateScore=@UpdateScore,
		   IsIptvOnly=@IpTv,
		   MaxbetHDP=@MaxbetHDP,
		   MaxbetOU=@MaxbetOU,
		   SpreadHDP=@SpreadHDP,
		   SpreadOU=@SpreadOU
		WHERE LeagueSettingId=@LeagueSettingId
		

		 --Round--
		 DELETE FROM OSSettingRound
		 WHERE LeagueSettingId=@LeagueSettingId

		 INSERT INTO OSSettingRound(LeagueSettingId, RoundId)
		 SELECT @LeagueSettingId, r.Id
		 FROM @tblRound AS r

		  --Offerline--
		 DELETE FROM OSSettingOfferLine
		 WHERE LeagueSettingId=@LeagueSettingId

		 INSERT INTO OSSettingOfferLine(LeagueSettingId, OfferLineId)
		 SELECT @LeagueSettingId, r.Id
		 FROM @tblOfferLine AS r

		  --Provider--
		 DELETE FROM OSSettingOfferLine
		 WHERE LeagueSettingId=@LeagueSettingId

		 INSERT INTO OSSettingProvider(LeagueSettingId, ProviderId)
		 SELECT @LeagueSettingId, r.Id
		 FROM @tblBettype AS r

		  --Bettype--
		 DELETE FROM OSSettingBettype
		 WHERE LeagueSettingId=@LeagueSettingId

		 INSERT INTO OSSettingBettype(LeagueSettingId, BettypeId)
		 SELECT @LeagueSettingId, r.Id
		 FROM @tblProvider AS r
    END;