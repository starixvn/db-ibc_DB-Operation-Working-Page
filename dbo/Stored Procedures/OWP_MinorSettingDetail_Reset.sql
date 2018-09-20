CREATE PROCEDURE [dbo].[OWP_MinorSettingDetail_Reset] @UserId INT
	,@MinorBettypeId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*          
 Created: 20170315@Razor.Nguyen
 Task : Max Bet For Minor Bet Types
 DB: bodb_OWP          
          
 Revisions:      
         
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@Xml XML
		,@LogData NVARCHAR(MAX)
	DECLARE @Detail TABLE (
		Id INT
		,Spread SMALLMONEY
		,MaxBet MONEY
		)

	SET @StartRun = GETDATE()

	IF (
			NOT EXISTS (
				SELECT 1
				FROM dbo.MinorSettingDetail WITH (NOLOCK)
				WHERE MinorBettypeId = @MinorBettypeId
				)
			)
	BEGIN
		SELECT @ErrCode = 6701
			,@ErrMsg = 'Do not exist minor bettype'
	END

	INSERT INTO @Detail (
		Id
		,Spread
		,MaxBet
		)
	SELECT MinorSettingId
		,Spread
		,MaxBet
	FROM dbo.MinorSettingDetail WITH (NOLOCK)
	WHERE MinorBettypeId = @MinorBettypeId
		AND (
			Spread IS NOT NULL
			OR Maxbet IS NOT NULL
			)

	UPDATE dbo.MinorSettingDetail WITH (ROWLOCK, UPDLOCK)
	SET Spread = NULL
		,MaxBet = NULL
	WHERE MinorBettypeId = @MinorBettypeId

	-- For write log
	SET @Xml = (
			SELECT @MinorBettypeId AS '@bt'
				,Id AS '@settingId'
				,Spread AS '@sp'
				,MaxBet AS '@mb'
			FROM @Detail
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
		,@SPName = 'OWP_MinorSettingDetail_Reset'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @MinorBettypeId
		,@Data = NULL
		,@DataOld = @LogData
END