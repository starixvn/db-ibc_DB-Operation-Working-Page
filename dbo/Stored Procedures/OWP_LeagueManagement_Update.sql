/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_Update] @ActorId INT
	,@LeagueSettingId INT
	,@Category NVARCHAR(20) = 'Live'
	,@TimeDesc NVARCHAR(50) = NULL
	,@Remark NVARCHAR(2000) = NULL
	,@LSTNote NVARCHAR(200) = NULL
	,@Spread_HDP SMALLMONEY = NULL
	,@Spread_OU SMALLMONEY = NULL
	,@Spread_1HHDP SMALLMONEY = NULL
	,@Spread_1HOU SMALLMONEY = NULL
	,@Speard_1X2 SMALLMONEY = NULL
	,@MaxbetWD_HDP MONEY = NULL
	,@MaxbetWD_OU MONEY = NULL
	,@MaxbetWD_1H MONEY = NULL
	,@MaxbetWD_NoOfHDP NVARCHAR(20) = NULL
	,@MaxbetWD_MatchOffer NVARCHAR(200) = NULL
	,@MaxbetWK_HDP MONEY = NULL
	,@MaxbetWK_OU MONEY = NULL
	,@MaxbetWK_1H MONEY = NULL
	,@MaxbetWK_NoOfHDP NVARCHAR(20) = NULL
	,@MaxbetWK_MatchOffer NVARCHAR(200) = NULL
	,@MaxBet_1X2Spread SMALLMONEY = NULL
	,@MaxBet_FT1X2 MONEY = NULL
	,@MaxBet_1H1X2 MONEY = NULL
	,@MaxBet_1X2_MatchOffer NVARCHAR(200) = NULL
	,@CN88Spread_HDP SMALLMONEY = NULL
	,@CN88Spread_OU SMALLMONEY = NULL
	,@CN88Spread_1HHDP SMALLMONEY = NULL
	,@CN88Spread_1HOU SMALLMONEY = NULL
	,@CN88MaxbetWD_HDP MONEY = NULL
	,@CN88MaxbetWD_OU MONEY = NULL
	,@CN88MaxbetWD_1H MONEY = NULL
	,@CN88MaxbetWD_NoOfHDP NVARCHAR(20) = NULL
	,@CN88MaxbetWD_MatchOffer NVARCHAR(200) = NULL
	,@CN88MaxbetWK_HDP MONEY = NULL
	,@CN88MaxbetWK_OU MONEY = NULL
	,@CN88MaxbetWK_1H MONEY = NULL
	,@CN88MaxbetWK_NoOfHDP NVARCHAR(20) = NULL
	,@CN88MaxbetWK_MatchOffer NVARCHAR(200) = NULL
	,@CN88MaxBet_1X2Spread SMALLMONEY = NULL
	,@CN88MaxBet_FT1X2 MONEY = NULL
	,@CN88MaxBet_1H1X2 MONEY = NULL
	,@CN88MaxBet_1X2_MatchOffer NVARCHAR(200) = NULL
	,@IsApplied BIT = 0
AS
/*
Created: 20200414@Tyler.Dang
Task : Update league setting
DB: bodb_OWP

Revisions:
   20200414@Tyler.Dang: Init Redmine: #132506
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.[NewLeagueSetting] WITH (ROWLOCK)
	SET [TimeDesc] = @TimeDesc
      ,[Remark] = @Remark
      ,[LSTNote] = @LSTNote
      ,[Spread_HDP] = @Spread_HDP
      ,[Spread_OU] = @Spread_OU
      ,[Spread_1HHDP] = @Spread_1HHDP
      ,[Spread_1HOU] = @Spread_1HOU
      ,[Speard_1X2] = @Speard_1X2
      ,[MaxbetWD_HDP] = @MaxbetWD_HDP
      ,[MaxbetWD_OU] = @MaxbetWD_OU
      ,[MaxbetWD_1H] = @MaxbetWD_1H
      ,[MaxbetWD_NoOfHDP] = @MaxbetWD_NoOfHDP
      ,[MaxbetWD_MatchOffer] = @MaxbetWD_MatchOffer
      ,[MaxbetWK_HDP] = @MaxbetWK_HDP
      ,[MaxbetWK_OU] = @MaxbetWK_OU
      ,[MaxbetWK_1H] = @MaxbetWK_1H
      ,[MaxbetWK_NoOfHDP] = @MaxbetWK_NoOfHDP
      ,[MaxbetWK_MatchOffer] = @MaxbetWK_MatchOffer
      ,[MaxBet_1X2Spread] = @MaxBet_1X2Spread
      ,[MaxBet_FT1X2] = @MaxBet_FT1X2
      ,[MaxBet_1H1X2] = @MaxBet_1H1X2
      ,[MaxBet_1X2_MatchOffer] = @MaxBet_1X2_MatchOffer
      ,[CN88Spread_HDP] = @CN88Spread_HDP
      ,[CN88Spread_OU] = @CN88Spread_OU
      ,[CN88Spread_1HHDP] = @CN88Spread_1HHDP
      ,[CN88Spread_1HOU] = @CN88Spread_1HOU
      ,[CN88MaxbetWD_HDP] = @CN88MaxbetWD_HDP
      ,[CN88MaxbetWD_OU] = @CN88MaxbetWD_OU
      ,[CN88MaxbetWD_1H] = @CN88MaxbetWD_1H
      ,[CN88MaxbetWD_NoOfHDP] = @CN88MaxbetWD_NoOfHDP
      ,[CN88MaxbetWD_MatchOffer] = @CN88MaxbetWD_MatchOffer
      ,[CN88MaxbetWK_HDP] = @CN88MaxbetWK_HDP
      ,[CN88MaxbetWK_OU] = @CN88MaxbetWK_OU
      ,[CN88MaxbetWK_1H] = @CN88MaxbetWK_1H
      ,[CN88MaxbetWK_NoOfHDP] = @CN88MaxbetWK_NoOfHDP
      ,[CN88MaxbetWK_MatchOffer] = @CN88MaxbetWK_MatchOffer
      ,[CN88MaxBet_1X2Spread] = @CN88MaxBet_1X2Spread
      ,[CN88MaxBet_FT1X2] = @CN88MaxBet_FT1X2
      ,[CN88MaxBet_1H1X2] = @CN88MaxBet_1H1X2
      ,[CN88MaxBet_1X2_MatchOffer] = @CN88MaxBet_1X2_MatchOffer
      ,[Category] = @Category
      ,[IsApplied] = @IsApplied
	  ,[LastModifiedBy] = @ActorId
	WHERE LeagueSettingId = @LeagueSettingId
END