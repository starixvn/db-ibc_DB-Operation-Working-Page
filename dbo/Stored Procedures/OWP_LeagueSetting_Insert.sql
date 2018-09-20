CREATE PROCEDURE [dbo].[OWP_LeagueSetting_Insert] @UserId INT
	,@LeagueId INT
	,@OptionIds INT
	,@BettypeId INT
	,@MaxBet MONEY = NULL
	,@Spread SMALLMONEY = NULL
	,@IsMaxBet BIT = 1
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170302@Tim.Trinh
Task : insert league setting
DB: bodb_OWP

Revisions:
   
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@CornerId INT = - 3
		,@ActionId INT = 62

	CREATE TABLE #tblBettypeId (Id INT)

	IF @BettypeId = @CornerId
	BEGIN
		INSERT INTO #tblBettypeId (Id)
		SELECT MinorBettypeId
		FROM dbo.MinorBettype WITH (NOLOCK)
		WHERE MinorBettypeName LIKE '%corner%'
	END
	ELSE
	BEGIN
		INSERT INTO #tblBettypeId (Id)
		VALUES (@BettypeId)
	END

	BEGIN TRY
		SELECT @StartRun = GETDATE()

		IF @IsMaxBet = 1
		BEGIN
			INSERT INTO dbo.LeagueSetting (
				LeagueId
				,OptionsId
				,Bettype
				,Spread
				,Maxbet
				,ModifiedBy
				,ModifiedDate
				)
			SELECT @LeagueId
				,@OptionIds
				,Id
				,NULL
				,@MaxBet * 1000
				,@UserId
				,@StartRun
			FROM #tblBettypeId WITH (NOLOCK)
		END
		ELSE
		BEGIN
			INSERT INTO dbo.LeagueSetting (
				LeagueId
				,OptionsId
				,Bettype
				,Spread
				,Maxbet
				,ModifiedBy
				,ModifiedDate
				)
			SELECT @LeagueId
				,@OptionIds
				,Id
				,@Spread / 100
				,NULL
				,@UserId
				,@StartRun
			FROM #tblBettypeId WITH (NOLOCK)
		END
		
		-- Write log		
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		
		INSERT INTO dbo.UserLog (
			CreatorId
			,LoggedDate
			,ObjectId
			,ActionId
			,Duration
			,Data
			)
		SELECT @UserId
			,@StartRun
			,ls.LeagueId
			,@ActionId
			,@Duration
			,'<r><z lid="' + CAST(ls.LeagueId AS VARCHAR(50))
			     + '" bt="' + CAST(ls.Bettype AS VARCHAR(50))
			     + '" opt="' + CAST(ls.OptionsId AS VARCHAR(50))
			     + '" ' + (CASE @IsMaxBet
			         WHEN 1 THEN 'm="' + CASE WHEN ISNULL(ls.Maxbet, '') = '' THEN '' ELSE CAST(ls.Maxbet AS VARCHAR(50)) END 
			         ELSE 's="' + CASE WHEN ISNULL(ls.Spread, '') = '' THEN '' ELSE CAST(ls.Spread AS VARCHAR(50)) END END)
			     + '" mb="' + CAST(ls.ModifiedBy AS VARCHAR(50))
			     + '" md="' + CAST(ls.ModifiedDate AS VARCHAR(50)) + '" /></r>'
		FROM dbo.LeagueSetting AS ls WITH (NOLOCK)
			INNER JOIN #tblBettypeId AS bt WITH (NOLOCK) ON ls.Bettype = bt.Id
		WHERE LeagueId = @LeagueId
			AND OptionsId = @OptionIds
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Insert league setting failed. Please try again.'
			,@ErrCode = 6201

		RETURN
	END CATCH

	DROP TABLE #tblBettypeId
END