/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueSetting_InsertOrUpdate] @UserId INT
	,@LeagueId INT
	,@OptionIds INT
	,@BettypeIds VARCHAR(MAX) = ''
	,@MaxBet MONEY = NULL
	,@Spread SMALLMONEY = NULL
	,@IsMaxBet BIT = 1
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170302@Tim.Trinh
Task : sp main for insert/update league setting
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @TotalRows INT
		,@RowIndex INT = 1
		,@BettypeId INT

	CREATE TABLE #tblBettype (
		RowIndex INT
		,BettpyeId INT
		)

	IF ISNULL(@BettypeIds, '') <> ''
	BEGIN
		INSERT INTO #tblBettype (
			RowIndex
			,BettpyeId
			)
		SELECT ROW_NUMBER() OVER (
				ORDER BY [val]
				) AS RowIndex
			,[val]
		FROM dbo.strSplit(@BettypeIds, ',')
	END

	SELECT @TotalRows = COUNT(1)
	FROM #tblBettype WITH (NOLOCK)

	WHILE @RowIndex <= @TotalRows
	BEGIN
		SELECT @BettypeId = BettpyeId
		FROM #tblBettype WITH (NOLOCK)
		WHERE RowIndex = @RowIndex

		-- insert
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.LeagueSetting WITH (NOLOCK)
				WHERE LeagueId = @LeagueId
					AND OptionsId = @OptionIds
					AND Bettype = @BettypeId
				)
		BEGIN
			EXEC [dbo].[OWP_LeagueSetting_Insert] @UserId = @UserId
				,@LeagueId = @LeagueId
				,@OptionIds = @OptionIds
				,@BettypeId = @BettypeId
				,@MaxBet = @MaxBet
				,@Spread = @Spread
				,@IsMaxBet = @IsMaxBet
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			IF @ErrCode <> 0 RETURN
		END
		ELSE -- update
		BEGIN
			EXEC [dbo].[OWP_LeagueSetting_Update] @UserId = @UserId
				,@LeagueId = @LeagueId
				,@OptionIds = @OptionIds
				,@BettypeId = @BettypeId
				,@MaxBet = @MaxBet
				,@Spread = @Spread
				,@IsMaxBet = @IsMaxBet
				,@ErrCode = @ErrCode OUTPUT
				,@ErrMsg = @ErrMsg OUTPUT

			IF @ErrCode <> 0 RETURN
		END

		SET @RowIndex = @RowIndex + 1
	END

	DROP TABLE #tblBettype
END