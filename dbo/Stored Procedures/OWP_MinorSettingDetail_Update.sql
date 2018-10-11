/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MinorSettingDetail_Update] @UserId INT
	,@MinorSettingId INT
	,@MinorBettypeId INT
	,@IsMaxBet BIT
	,@Spread SMALLMONEY = NULL
	,@MaxBet MONEY = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170315@Razor.Nguyen
 Task : Max Bet For Minor Bet Types
 DB: bodb_OWP          
          
 Revisions:      
    20180806@Raymond.Le: Combine setting X Mins - [Redmine: #92868]       
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@Xml XML
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2

	SET @StartRun = GETDATE()

	IF (
			NOT EXISTS (
				SELECT 1
				FROM dbo.MinorSettingDetail WITH (NOLOCK)
				WHERE MinorBettypeId = @MinorBettypeId
					AND MinorSettingId = @MinorSettingId
				)
			)
	BEGIN
		EXEC dbo.OWP_MinorSettingDetail_INSERT @UserId
			,@MinorSettingId
			,@MinorBettypeId
			,@Spread
			,@MaxBet
			,@ErrCode OUTPUT
			,@ErrMsg OUTPUT
	END
	ELSE
	BEGIN
		SET @Xml = (
				SELECT MinorBettypeId AS '@bt'
					,MinorSettingId AS '@settingId'
					,(CASE @IsMaxBet
						WHEN 0 THEN Spread
						ELSE NULL END
						) AS '@sp'
					,(CASE @IsMaxBet
						WHEN 1 THEN MaxBet
						ELSE NULL END
						) AS '@mb'
				FROM dbo.MinorSettingDetail WITH (NOLOCK)
				WHERE MinorBettypeId = @MinorBettypeId
					AND MinorSettingId = @MinorSettingId
					AND Spread IS NOT NULL
					AND Maxbet IS NOT NULL
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		IF (@IsMaxBet = 1)
		BEGIN
			UPDATE dbo.MinorSettingDetail WITH (ROWLOCK, UPDLOCK)
			SET MaxBet = @MaxBet * 1000
			WHERE MinorBettypeId = @MinorBettypeId
				AND MinorSettingId = @MinorSettingId

			-- Hardcode insert setting 10mins equal 15mins
			IF (@MinorBettypeId = @Specific15Mins)
			BEGIN
				UPDATE dbo.MinorSettingDetail WITH (ROWLOCK, UPDLOCK)
				SET MaxBet = @MaxBet * 1000
				WHERE MinorBettypeId = @Specific10Mins
					AND MinorSettingId = @MinorSettingId
			END
		END
		ELSE
		BEGIN
			UPDATE dbo.MinorSettingDetail WITH (ROWLOCK, UPDLOCK)
			SET Spread = @Spread / 100
			WHERE MinorBettypeId = @MinorBettypeId
				AND MinorSettingId = @MinorSettingId

			-- Hardcode insert setting 10mins equal 15mins
			IF (@MinorBettypeId = @Specific15Mins)
			BEGIN
				UPDATE dbo.MinorSettingDetail WITH (ROWLOCK, UPDLOCK)
				SET Spread = @Spread / 100
				WHERE MinorBettypeId = @Specific10Mins
					AND MinorSettingId = @MinorSettingId
			END
		END

		-- For write log
		SET @Xml = (
				SELECT @MinorBettypeId AS '@bt'
					,@MinorSettingId AS '@settingId'
					,(CASE @IsMaxBet
						WHEN 0 THEN @Spread / 100
						ELSE NULL END
						) AS '@sp'
					,(CASE @IsMaxBet
						WHEN 1 THEN @MaxBet * 1000
						ELSE NULL END
						) AS '@mb'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_MinorSettingDetail_Update'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @MinorBettypeId
			,@Data = @LogData
			,@DataOld = @LogDataOld
	END
END