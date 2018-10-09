/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueSetting_Update] @UserId INT
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
Task : update league setting
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure 
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@OldData NVARCHAR(MAX)
		,@NewData NVARCHAR(MAX)
		,@Xml XML
		,@CornerId INT = - 3
		,@ActionId INT = 63

	CREATE TABLE #tblBettypeId (Id INT)

	CREATE TABLE #tblLeagueSetting (
		LeagueId INT
		,OptionIds INT
		,BettypeId INT
		,OldData NVARCHAR(MAX)
		,NewData NVARCHAR(MAX)
		)

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
		INSERT INTO #tblLeagueSetting (
			LeagueId
			,OptionIds
			,BettypeId
			,OldData
			)
		SELECT ls.LeagueId
			,ls.OptionsId
			,ls.Bettype
			,'<r><z lid="' + CAST(ls.LeagueId AS VARCHAR(50))
			     + '" bt="' + CAST(ls.Bettype AS VARCHAR(50))
			     + '" opt="' + CAST(ls.OptionsId AS VARCHAR(50))
			     + '" ' + (CASE @IsMaxBet
			         WHEN 1 THEN 'm="' + CASE WHEN ISNULL(ls.Maxbet, '') = '' THEN '' ELSE CAST(ls.Maxbet AS VARCHAR(50)) END
			         ELSE 's="' + CASE WHEN ISNULL(ls.Spread, '') = '' THEN '' ELSE CAST(ls.Spread AS VARCHAR(50)) END END)
			     + '" mb="' + CAST(ls.ModifiedBy AS VARCHAR(50))
			     + '" md="' + CAST(ls.ModifiedDate AS VARCHAR(50)) + '" /></r>'
		FROM dbo.LeagueSetting AS ls WITH (NOLOCK)
			INNER JOIN #tblBettypeId AS lid WITH (NOLOCK) ON ls.Bettype = lid.Id
		WHERE ls.LeagueId = @LeagueId
			AND ls.OptionsId = @OptionIds
			AND (
				(
					@IsMaxBet = 1
					AND ISNULL(ls.Maxbet, 0) <> ISNULL(@MaxBet, 0)
					)
				OR (
					@IsMaxBet = 0
					AND ISNULL(ls.Spread, 0) <> ISNULL(@Spread, 0)
					)
				)

		SET @StartRun = GETDATE()

		IF @IsMaxBet = 1
		BEGIN
			UPDATE ls
			SET ls.Maxbet = @MaxBet * 1000
				,ls.ModifiedBy = @UserId
				,ls.ModifiedDate = @StartRun
			FROM dbo.LeagueSetting AS ls
				INNER JOIN #tblBettypeId AS lid WITH (NOLOCK) ON ls.Bettype = lid.Id
			WHERE ls.LeagueId = @LeagueId
				AND ls.OptionsId = @OptionIds
		END
		ELSE
		BEGIN
			UPDATE ls
			SET ls.Spread = @Spread / 100
				,ls.ModifiedBy = @UserId
				,ls.ModifiedDate = @StartRun
			FROM dbo.LeagueSetting AS ls
				INNER JOIN #tblBettypeId AS lid WITH (NOLOCK) ON ls.Bettype = lid.Id
			WHERE ls.LeagueId = @LeagueId
				AND ls.OptionsId = @OptionIds
		END

		UPDATE tbl
		SET tbl.NewData = '<r><z lid="' + CAST(ls.LeagueId AS VARCHAR(50))
		          + '" bt="' + CAST(ls.Bettype AS VARCHAR(50))
		          + '" opt="' + CAST(ls.OptionsId AS VARCHAR(50))
		          + '" ' + (CASE @IsMaxBet
				    WHEN 1 THEN 'm="' + CASE WHEN ISNULL(ls.Maxbet, '') = '' THEN '' ELSE CAST(ls.Maxbet AS VARCHAR(50)) END
				    ELSE 's="' + CASE WHEN ISNULL(ls.Spread, '') = '' THEN '' ELSE CAST(ls.Spread AS VARCHAR(50)) END END)
				+ '" mb="' + CAST(ls.ModifiedBy AS VARCHAR(50))
				+ '" md="' + CAST(ls.ModifiedDate AS VARCHAR(50)) + '" /></r>'
		FROM #tblLeagueSetting AS tbl
			INNER JOIN dbo.LeagueSetting AS ls WITH (NOLOCK) ON tbl.LeagueId = ls.LeagueId
			AND tbl.OptionIds = ls.OptionsId
			AND tbl.BettypeId = ls.Bettype
			INNER JOIN #tblBettypeId AS lid WITH (NOLOCK) ON ls.Bettype = lid.Id
		WHERE ls.LeagueId = @LeagueId
			AND ls.OptionsId = @OptionIds
			AND (
				(
					@IsMaxBet = 1
					AND ISNULL(ls.Maxbet, 0) <> ISNULL(@MaxBet, 0)
					)
				OR (
					@IsMaxBet = 0
					AND ISNULL(ls.Spread, 0) <> ISNULL(@Spread, 0)
					)
				)

		-- Write log		
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		INSERT INTO dbo.UserLog (
			CreatorId
			,LoggedDate
			,ObjectId
			,ActionId
			,Duration
			,DataOld
			,Data
			)
		SELECT @UserId
			,@StartRun
			,LeagueId
			,@ActionId
			,@Duration
			,OldData
			,NewData
		FROM #tblLeagueSetting WITH (NOLOCK)
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update league setting failed. Please try again.'
			,@ErrCode = 6301

		RETURN
	END CATCH

	DROP TABLE #tblBettypeId

	DROP TABLE #tblLeagueSetting
END