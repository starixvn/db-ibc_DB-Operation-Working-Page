/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_Update] @ActorId INT
	,@LeagueSettingId INT
	,@Category NVARCHAR(20) = 'Live'
	,@TimeDesc NVARCHAR(50) = NULL
	,@Remark NVARCHAR(2000) = NULL
	,@LSTNote NVARCHAR(200) = NULL
	,@Spread_HDP MONEY = NULL
	,@Spread_OU MONEY = NULL
	,@Spread_1HHDP MONEY = NULL
	,@Spread_1HOU MONEY = NULL
	,@Speard_1X2 MONEY = NULL
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
	,@MaxBet_1X2Spread MONEY = NULL
	,@MaxBet_FT1X2 MONEY = NULL
	,@MaxBet_1H1X2 MONEY = NULL
	,@MaxBet_1X2_MatchOffer NVARCHAR(200) = NULL
	,@IsApplied BIT = 0
AS
/*
Created: 20200414@Tyler.Dang
Task : Update league setting
DB: bodb_OWP

Revisions:
   20200414@Tyler.Dang: Init Redmine: #132506
   20210909@Luca.Duong: Remove cn88 - [Feature: #160666]
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@OWPLeagueId INT

		-- Log  
		SET @StartRun = GETDATE()
		SET @Xml = (
				SELECT ls.LeagueSettingId AS '@lsid'
				  ,ls.OWPLeagueId AS '@olid'
				  ,ls.Category AS '@c'
				  ,ls.TimeDesc AS '@td'
				  ,ls.Remark AS '@rm'
				  ,ls.TV AS '@tv'
				  ,ls.HasTV AS '@htv'
				  ,ls.[Round] AS '@r'
				  ,ls.Division AS '@d'
				  ,ls.LSTNote AS '@ln'
				  ,ls.Spread_HDP AS '@shdp'
				  ,ls.Spread_OU AS '@sou'
				  ,ls.Spread_1HHDP AS '@s1hhdp'
				  ,ls.Spread_1HOU AS '@s1hou'
				  ,ls.Speard_1X2 AS '@s1x2'
				  ,ls.MaxbetWD_HDP AS '@mwdhdp'
				  ,ls.MaxbetWD_OU AS '@mwdou'
				  ,ls.MaxbetWD_1H AS '@mwd1h'
				  ,ls.MaxbetWD_NoOfHDP AS '@mwdnohdp'
				  ,ls.MaxbetWD_MatchOffer AS '@mwdmo'
				  ,ls.MaxbetWK_HDP AS '@mwkhdp'
				  ,ls.MaxbetWK_OU AS '@mwkou'
				  ,ls.MaxbetWK_1H AS '@mwk1h'
				  ,ls.MaxbetWK_NoOfHDP AS '@mwknohdp'
				  ,ls.MaxbetWK_MatchOffer AS '@mwkmo'
				  ,ls.MaxBet_1X2Spread AS '@mb1x2s'
				  ,ls.MaxBet_FT1X2 AS '@mbft1x2'
				  ,ls.MaxBet_1H1X2 AS '@mb1h1x2'
				  ,ls.MaxBet_1X2_MatchOffer AS '@mb1x2mo'
				  ,ls.IsApplied AS '@ia'
				FROM dbo.[NewLeagueSetting] AS ls WITH (NOLOCK)
				WHERE @LeagueSettingId = ls.LeagueSettingId 
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	SELECT @OWPLeagueId = OWPLeagueId
	FROM dbo.[NewLeagueSetting]
    WHERE LeagueSettingId = @LeagueSettingId

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
      ,[Category] = @Category
      ,[IsApplied] = @IsApplied
	  ,[LastModifiedBy] = @ActorId
	WHERE LeagueSettingId = @LeagueSettingId

	-- For write log  
		SET @Xml = (
				SELECT ls.LeagueSettingId AS '@lsid'
				  ,ls.OWPLeagueId AS '@olid'
				  ,ls.Category AS '@c'
				  ,ls.TimeDesc AS '@td'
				  ,ls.Remark AS '@rm'
				  ,ls.TV AS '@tv'
				  ,ls.HasTV AS '@htv'
				  ,ls.[Round] AS '@r'
				  ,ls.Division AS '@d'
				  ,ls.LSTNote AS '@ln'
				  ,ls.Spread_HDP AS '@shdp'
				  ,ls.Spread_OU AS '@sou'
				  ,ls.Spread_1HHDP AS '@s1hhdp'
				  ,ls.Spread_1HOU AS '@s1hou'
				  ,ls.Speard_1X2 AS '@s1x2'
				  ,ls.MaxbetWD_HDP AS '@mwdhdp'
				  ,ls.MaxbetWD_OU AS '@mwdou'
				  ,ls.MaxbetWD_1H AS '@mwd1h'
				  ,ls.MaxbetWD_NoOfHDP AS '@mwdnohdp'
				  ,ls.MaxbetWD_MatchOffer AS '@mwdmo'
				  ,ls.MaxbetWK_HDP AS '@mwkhdp'
				  ,ls.MaxbetWK_OU AS '@mwkou'
				  ,ls.MaxbetWK_1H AS '@mwk1h'
				  ,ls.MaxbetWK_NoOfHDP AS '@mwknohdp'
				  ,ls.MaxbetWK_MatchOffer AS '@mwkmo'
				  ,ls.MaxBet_1X2Spread AS '@mb1x2s'
				  ,ls.MaxBet_FT1X2 AS '@mbft1x2'
				  ,ls.MaxBet_1H1X2 AS '@mb1h1x2'
				  ,ls.MaxBet_1X2_MatchOffer AS '@mb1x2mo'
				  ,ls.IsApplied AS '@ia'
				FROM dbo.[NewLeagueSetting] AS ls WITH (NOLOCK)
				WHERE @LeagueSettingId = ls.LeagueSettingId 
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		IF ISNULL(@LogData, '') <> ''
			OR ISNULL(@LogDataOld, '') <> ''
		BEGIN
			EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
				,@SPName = 'OWP_LeagueManagement_Update'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = @OWPLeagueId
				,@Data = @LogData
				,@DataOld = @LogDataOld
		END
END