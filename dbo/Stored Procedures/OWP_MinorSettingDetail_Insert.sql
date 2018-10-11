/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MinorSettingDetail_Insert] @UserId INT
	,@MinorSettingId INT
	,@MinorBettypeId INT
	,@Spread SMALLMONEY
	,@MaxBet MONEY
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
		,@LogData NVARCHAR(MAX)
		,@Id INT
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
		SELECT @ErrCode = 6601
			,@ErrMsg = 'Exist minor bettype for the range!'
	END

	INSERT INTO dbo.MinorSettingDetail (
		MinorBettypeId
		,MinorSettingId
		,Spread
		,MaxBet
		)
	VALUES (
		@MinorBettypeId
		,@MinorSettingId
		,@Spread/100
		,@MaxBet*1000
		)

	-- Hardcode insert setting 10mins equal 15mins
	IF (@MinorBettypeId = @Specific15Mins)
	BEGIN
	INSERT INTO dbo.MinorSettingDetail (
		MinorBettypeId
		,MinorSettingId
		,Spread
		,MaxBet
		)
	VALUES (
		@Specific10Mins
		,@MinorSettingId
		,@Spread/100
		,@MaxBet*1000
		)		
	END

	SET @Id = SCOPE_IDENTITY()
	-- For write log
	SET @Xml = (
			SELECT @MinorBettypeId AS '@bt'
				,@MinorSettingId AS '@settingId'
				,@Spread/100 AS '@sp'
				,@MaxBet*1000 AS '@mb'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
		,@SPName = 'OWP_MinorSettingDetail_Insert'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @Id
		,@Data = @LogData
		,@DataOld = NULL
END