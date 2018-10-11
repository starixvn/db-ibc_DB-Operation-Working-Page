/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueSetting_CopySetting] @UserId INT
	,@Details NVARCHAR(MAX) = ''
	,@Value MONEY = NULL
	,@IsMaxBet BIT = 1
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170309@Tim.Trinh
Task : copy league setting
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @TotalRows INT
		,@RowIndex SMALLINT = 1
		,@idoc INT

	CREATE TABLE #tblLeagueSetting (
		RowIndex INT IDENTITY(1, 1)
		,LeagueId INT
		,OptionIds INT
		,BettypeIds VARCHAR(MAX)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@Details

	INSERT INTO #tblLeagueSetting (
		LeagueId
		,OptionIds
		,BettypeIds
		)
	SELECT DISTINCT data.LeagueId
		,data.OptionIds
		,data.BettypeIds
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (LeagueId INT, OptionIds INT, BettypeIds NVARCHAR(MAX)) AS data

	EXEC sp_xml_removedocument @idoc

	SELECT @TotalRows = COUNT(1)
	FROM #tblLeagueSetting WITH (NOLOCK)

	WHILE @RowIndex <= @TotalRows
	BEGIN
		DECLARE @LeagueId INT
			,@OptionIds INT
			,@BettypeIds VARCHAR(MAX)
			,@MaxBet MONEY
			,@Spread SMALLMONEY

		SELECT @LeagueId = LeagueId
			,@OptionIds = OptionIds
			,@BettypeIds = BettypeIds
			,@MaxBet = CASE @IsMaxBet WHEN 1 THEN @Value ELSE NULL END
			,@Spread = CASE @IsMaxBet WHEN 0 THEN @Value ELSE NULL END
		FROM #tblLeagueSetting WITH (NOLOCK)
		WHERE RowIndex = @RowIndex

		EXEC [dbo].[OWP_LeagueSetting_InsertOrUpdate] @UserId = @UserId
			,@LeagueId = @LeagueId
			,@OptionIds = @OptionIds
			,@BettypeIds = @BettypeIds
			,@MaxBet = @MaxBet
			,@Spread = @Spread
			,@IsMaxBet = @IsMaxBet
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT

		SET @RowIndex = @RowIndex + 1
	END

	DROP TABLE #tblLeagueSetting
END