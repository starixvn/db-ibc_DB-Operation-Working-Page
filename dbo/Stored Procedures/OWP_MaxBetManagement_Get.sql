/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MaxBetManagement_Get] @League NVARCHAR(500) = ''
	,@LeagueGroupId INT = 0
	,@OptionIds NVARCHAR(MAX)
	,@IsActive BIT = 1
	,@PageIndex INT = 0
	,@PageSize INT = 0
	,@TotalItems INT = 0 OUTPUT
AS
/*
Created: 20170301@Tim.Trinh
Task : get max bet, spread of league
DB: bodb_OWP

Revisions:
   20170317@Tim.Trinh: add @OptionIds
   20170418@Tim.Trinh: fix bug get option
   20180601@Leo.VO: change param type - [Redmine: #92868]
   20190521@Lita.Tang: Add Username value - [Feature: #113765]

*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Today DATE = GETDATE()
		,@Weekday TINYINT = 2
		,@Weekend TINYINT = 4
		,@IsUnknownOption BIT = 0

	CREATE TABLE #tblLeagueId (
		RowIndex INT IDENTITY(1, 1)
		,OWPLeagueId INT
		,LeagueName NVARCHAR(2000)
		,HasGroup BIT
		,LeagueGroup NVARCHAR(200)
		)

	CREATE TABLE #tblFinalLeagueId (
		RowIndex INT
		,OWPLeagueId INT
		)

	CREATE TABLE #tblOptionId (OptionId INT)

	CREATE TABLE #tblLeagueOption (
		LeagueId INT
		,Bettype INT
		,OptionIds INT
		,OptionId INT
		)

	CREATE TABLE #tblLastUsing (
		LeagueId INT
		,[Date] DATE
		)

	IF @OptionIds IS NOT NULL
	BEGIN
		INSERT INTO #tblOptionId (OptionId)
		SELECT CAST([val] AS INT)
		FROM dbo.strSplit(@OptionIds, ',')

		INSERT INTO #tblOptionId (OptionId)
		SELECT OptionId + @Weekday
		FROM #tblOptionId WITH (NOLOCK)

		INSERT INTO #tblOptionId (OptionId)
		SELECT OptionId + @Weekend
		FROM #tblOptionId WITH (NOLOCK)
		WHERE OptionId IN (
				SELECT OptionId - @Weekday
				FROM #tblOptionId WITH (NOLOCK)
				)

		IF EXISTS (
				SELECT 1
				FROM #tblOptionId WITH (NOLOCK)
				WHERE OptionId = 0
				)
		BEGIN
			SET @IsUnknownOption = 1

			DELETE
			FROM #tblOptionId
			WHERE OptionId = 0
		END
	END

	INSERT INTO #tblLeagueId (
		OWPLeagueId
		,LeagueName
		,HasGroup
		,LeagueGroup
		)
	SELECT DISTINCT league.OWPLeagueId
		,league.OWPLeagueName
		,(CASE 
			WHEN lg.Value IS NOT NULL THEN 0
			ELSE 1 END
			) AS HasGroup
		,lg.Value AS LeagueGroup
	FROM dbo.OWPLeague AS league WITH (NOLOCK)
		LEFT JOIN dbo.RefResource AS lg WITH (NOLOCK) ON league.CategoryId = lg.ResourceId
		AND lg.RefName = 'LeagueCategory'
		LEFT JOIN dbo.LeagueSetting AS setting WITH (NOLOCK) ON league.OWPLeagueId = setting.LeagueId
	WHERE league.OWPLeagueName LIKE + '%' + ISNULL(@League, '') + '%'
		AND ISNULL(league.IsActive, 0) = (CASE @IsActive
			WHEN 1 THEN @IsActive
			ELSE ISNULL(league.IsActive, 0) END
			)
		AND (
			@LeagueGroupId = 0
			OR (
				@LeagueGroupId = - 1
				AND league.CategoryId IS NULL
				)
			OR league.CategoryId = @LeagueGroupId
			)
		AND (
			(
				@IsUnknownOption = 1
				AND setting.OptionsId IS NULL
				)
			OR setting.OptionsId IN (
				SELECT OptionId
				FROM #tblOptionId WITH (NOLOCK)
				)
			)
	ORDER BY HasGroup
		,LeagueGroup
		,league.OWPLeagueName

	IF @PageIndex = 0
		AND @PageSize = 0
	BEGIN
		INSERT INTO #tblFinalLeagueId (
			RowIndex
			,OWPLeagueId
			)
		SELECT RowIndex
			,OWPLeagueId
		FROM #tblLeagueId WITH (NOLOCK)
	END
	ELSE
	BEGIN
		INSERT INTO #tblFinalLeagueId (
			RowIndex
			,OWPLeagueId
			)
		SELECT RowIndex
			,OWPLeagueId
		FROM #tblLeagueId WITH (NOLOCK)
		WHERE RowIndex BETWEEN ((@PageIndex - 1) * @PageSize + 1)
				AND (@PageIndex * @PageSize)
	END

	INSERT INTO #tblLeagueOption (
		LeagueId
		,Bettype
		,OptionIds
		,OptionId
		)
	SELECT ls.LeagueId
		,ls.Bettype
		,ls.OptionsId
		,opt.Value
	FROM dbo.LeagueSetting AS ls WITH (NOLOCK)
		INNER JOIN #tblFinalLeagueId AS lid WITH (NOLOCK) ON ls.LeagueId = lid.OWPLeagueId
		LEFT JOIN dbo.LeagueOption AS opt WITH (NOLOCK) ON ls.OptionsId = POWER(2.0, opt.Value)
		OR (
			(ls.OptionsId - @Weekday) = POWER(2.0, opt.Value)
			AND POWER(2.0, opt.Value) > @Weekday
			)
		OR (
			(ls.OptionsId - @Weekend) = POWER(2.0, opt.Value)
			AND POWER(2.0, opt.Value) > @Weekend
			)

	INSERT INTO #tblLastUsing (
		LeagueId
		,[Date]
		)
	SELECT om.OWPLeagueId
		,MAX(om.EventDate)
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN #tblFinalLeagueId AS lid WITH (NOLOCK) ON om.OWPLeagueId = lid.OWPLeagueId
	WHERE om.EventDate <= @Today
	GROUP BY om.OWPLeagueId

	-- info
	SELECT lid.RowIndex
		,league.OWPLeagueId AS LeagueId
		,league.OWPLeagueName AS LeagueName
		,league.IsActive
		,league.IsBlackList
		,league.CategoryId AS LeagueGroupId
		,ref.Value AS LeagueGroupName
		,lu.[Date] AS LastUsing
	FROM dbo.OWPLeague AS league WITH (NOLOCK)
		INNER JOIN #tblFinalLeagueId AS lid WITH (NOLOCK) ON league.OWPLeagueId = lid.OWPLeagueId
		LEFT JOIN dbo.RefResource AS ref WITH (NOLOCK) ON league.CategoryId = ref.ResourceId
		AND ref.RefName = 'LeagueCategory'
		LEFT JOIN #tblLastUsing AS lu WITH (NOLOCK) ON lid.OWPLeagueId = lu.LeagueId
	ORDER BY (CASE 
			WHEN ref.Value IS NULL THEN 1
			ELSE 0 END
			)
		,ref.Value
		,league.OWPLeagueName

	-- setting
	SELECT ls.LeagueId
		,POWER(2.0, lopt.Value) AS OptionId
		,lopt.[Name] AS OptionName
		,ls.OptionsId AS OptionIds
		,oc.ResourceId AS CategoryId
		,oc.Value AS CategoryName
		,remark.Remarks
		,ls.Bettype AS BettypeId
		,(ls.Spread * 100) AS Spread
		,(ls.Maxbet / 1000) AS MaxBet
		,u.Username
		,u.Nickname
		,ls.ModifiedDate AS LastUpdatedTime
	FROM dbo.LeagueSetting AS ls WITH (NOLOCK)
		INNER JOIN #tblFinalLeagueId AS lid WITH (NOLOCK) ON ls.LeagueId = lid.OWPLeagueId
		INNER JOIN #tblLeagueOption AS opt WITH (NOLOCK) ON lid.OWPLeagueId = opt.LeagueId
		AND ls.Bettype = opt.Bettype
		AND ls.OptionsId = opt.OptionIds
		INNER JOIN dbo.LeagueOption AS lopt WITH (NOLOCK) ON opt.OptionId = lopt.Value
		LEFT JOIN dbo.LeagueRemarkSetting AS remark WITH (NOLOCK) ON ls.LeagueId = remark.LeagueId
		AND POWER(2.0, opt.OptionId) = remark.OptionId
		LEFT JOIN dbo.RefResource AS oc WITH (NOLOCK) ON lopt.CategoryId = oc.ResourceId
		AND oc.RefName = 'LeagueOptionCategory'
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON ls.ModifiedBy = u.UserId
	WHERE ls.Bettype IN (1, 3, 5, 7, 8, 15)
		AND (
			(
				@IsUnknownOption = 1
				AND opt.OptionIds IS NULL
				)
			OR opt.OptionIds IN (
				SELECT OptionId
				FROM #tblOptionId WITH (NOLOCK)
				)
			)
	ORDER BY ls.LeagueId
		,CategoryId
		,OptionId

	-- total item
	SELECT @TotalItems = COUNT(1)
	FROM #tblLeagueId

	DROP TABLE #tblLeagueId

	DROP TABLE #tblFinalLeagueId

	DROP TABLE #tblLeagueOption

	DROP TABLE #tblLastUsing

	DROP TABLE #tblOptionId
END