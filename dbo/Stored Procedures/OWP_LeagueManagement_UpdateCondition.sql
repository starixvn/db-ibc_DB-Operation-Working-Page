/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_UpdateCondition] @ActorId INT
	,@LeagueSettingId INT
	,@HasTV BIT = 0
	,@TV NVARCHAR(50) = NULL
	,@Round NVARCHAR(200) = NULL
	,@Division NVARCHAR(200) = NULL
	,@FullConditionDescription NVARCHAR(MAX) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
Created: 20200417@Tyler.Dang
Task : update league setting condition
DB: bodb_OWP

Revisions:
   20200417@Tyler.Dang: Init Redmine: #132506
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
	SET [TV] = @TV
		,[HasTV] = @HasTV
		,[Round] = @Round
		,[Division] = @Division
		,[FullConditionDescription] = @FullConditionDescription
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
				,@SPName = 'OWP_LeagueManagement_UpdateCondition'
				,@LoggedDate = @StartRun
				,@Duration = @Duration
				,@ObjectId = @OWPLeagueId
				,@Data = @LogData
				,@DataOld = @LogDataOld
		END

	SELECT @ErrCode = 0
		,@ErrMsg = 'Condition has been updated successfully!'
END