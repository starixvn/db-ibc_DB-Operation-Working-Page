/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_Delete]  @ActorId INT
	,@LeagueSettingId INT
AS
/*
Created: 20200414@Tyler.Dang
Task : Delete league setting
DB: bodb_OWP

Revisions:
   20200414@Tyler.Dang: Init Redmine: #132506
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
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
				  ,ls.CN88Spread_HDP AS '@cn88shdp'
				  ,ls.CN88Spread_OU AS '@cn88sou'
				  ,ls.CN88Spread_1HHDP AS '@cn88s1hhdp'
				  ,ls.CN88Spread_1HOU AS '@cn88s1hou'
				  ,ls.CN88MaxbetWD_HDP AS '@cn88mwdhdp'
				  ,ls.CN88MaxbetWD_OU AS '@cn88mwdou'
				  ,ls.CN88MaxbetWD_1H AS '@cn88mwd1h'
				  ,ls.CN88MaxbetWD_NoOfHDP AS '@cn88mwdnohdp'
				  ,ls.CN88MaxbetWD_MatchOffer AS '@cn88mwdmo'
				  ,ls.CN88MaxbetWK_HDP AS '@cn88mwkhdp'
				  ,ls.CN88MaxbetWK_OU AS '@cn88mwkou'
				  ,ls.CN88MaxbetWK_1H AS '@cn88mwk1h'
				  ,ls.CN88MaxbetWK_NoOfHDP AS '@cn88mwknohdp'
				  ,ls.CN88MaxbetWK_MatchOffer AS '@cn88mwkmo'
				  ,ls.CN88MaxBet_1X2Spread AS '@cn88mb1x2s'
				  ,ls.CN88MaxBet_FT1X2 AS '@cn88mbft1x2'
				  ,ls.CN88MaxBet_1H1X2 AS '@cn88mb1h1x2'
				  ,ls.CN88MaxBet_1X2_MatchOffer AS '@cn88mb1x2mo'
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

	DELETE FROM dbo.[NewLeagueSetting]
    WHERE LeagueSettingId = @LeagueSettingId

	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	IF ISNULL(@LogDataOld, '') <> ''
	BEGIN
		EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
			,@SPName = 'OWP_LeagueManagement_Delete'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPLeagueId
			,@DataOld = @LogDataOld
	END
END