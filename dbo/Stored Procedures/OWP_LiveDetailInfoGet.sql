CREATE PROCEDURE [dbo].[OWP_LiveDetailInfoGet] @OWPMatchId INT
AS
/*  
 Created: 2016-10-06@Aaron
 Task : Get new Match Detail Info
 DB: bodb_OWP

 Revisions:
    20170426@Tim.Trinh: review and refactor
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Televisions NVARCHAR(2000)
		,@Providers VARCHAR(2000)
		,@Runners VARCHAR(2000)
		,@MatchStatus NVARCHAR(15)
		-- Match Status
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Inplay NVARCHAR(15) = 'In-play'
		,@str_Completed NVARCHAR(15) = 'Completed'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'

	CREATE TABLE #tblMatchStatusList (
		DisplayText NVARCHAR(15),
		Value NVARCHAR(15),
		IsDisplay BIT,
		IsSelected BIT
	)

	INSERT INTO #tblMatchStatusList (DisplayText, Value, IsSelected) 
	VALUES 	(@str_Inplay, '', 0),
			(@str_Completed, '', 0),
			(@str_Live, @str_Live, 0),
			(@str_Cancel, @str_Cancel, 0),
			(@str_Postponed, @str_Postponed, 0),
			(@str_Suspended, @str_Suspended, 0)

	-------
	SELECT @Televisions = mi.TVCode
		,@Providers = Provider
		,@Runners = Runner
		,@MatchStatus = [dbo].[OWP_GetCurrentMatchStatus] (om.EventDate, om.KickOffTime, mi.MatchStatus)
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
		LEFT JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = @OWPMatchId
	WHERE mi.OWPMatchId = @OWPMatchId

	SELECT mi.TVCode
		,mi.Channel
		,mi.WatchBet
		,mi.Phone
		,mi.KOTimeRemark
		,mi.IsSelected
		,@MatchStatus AS MatchStatus
		,mi.[Round]
		,mi.IsSoloMatch
		,mi.OutSide
		,mi.Venue
		,(m.OtherTime + m.EventDate) AS OtherTime
		,r.Value AS LeagueCategoryName
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
		LEFT JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
		LEFT JOIN dbo.RefResource AS r WITH (NOLOCK) ON l.CategoryId = r.ResourceId
		AND r.RefName = 'LeagueCategory'
	WHERE m.OWPMatchId = @OWPMatchId

	SELECT t.TVCode
		,t.TVCode AS TVName
		,t.Decoder
		,t.Country
		,(CASE 
			WHEN tv.TVCode IS NULL THEN 0
			ELSE 1 END
			) AS IsSelected
	FROM dbo.Television AS t WITH (NOLOCK)
		LEFT JOIN (
		SELECT DISTINCT tv.TVCode
		FROM dbo.Television AS tv WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(ISNULL(@Televisions, ''), ',') f
		WHERE tv.TVCode = f.[val]
		) AS tv ON t.TVCode = tv.TVCode

	SELECT ref.ResourceId
		,LTRIM(RTRIM(ref.Value)) AS Value
		,(CASE 
			WHEN p.ProviderId IS NULL THEN 0
			ELSE 1 END
			) AS IsSelected
	FROM dbo.RefResource AS ref WITH (NOLOCK)
		LEFT JOIN (
		SELECT rs.ResourceId AS ProviderId
		FROM dbo.RefResource AS rs WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(ISNULL(@Providers, ''), ',') f
		WHERE f.[val] = rs.ResourceId
			AND rs.RefName = 'Provider'
		) AS p ON ref.ResourceId = p.ProviderId
	WHERE ref.RefName = 'Provider'
	ORDER BY Value

	SELECT ref.ResourceId
		,LTRIM(RTRIM(ref.Value)) AS Value
		,(CASE 
			WHEN r.RunnerId IS NULL THEN 0
			ELSE 1 END
			) AS IsSelected
	FROM dbo.RefResource AS ref WITH (NOLOCK)
		LEFT JOIN (
		SELECT rs.ResourceId AS RunnerId
		FROM dbo.RefResource AS rs WITH (NOLOCK)
			CROSS APPLY dbo.fnc_SplitStrings(ISNULL(@Runners, ''), ',') f
		WHERE f.[val] = rs.ResourceId
			AND rs.RefName = 'Runner'
		) AS r ON ref.ResourceId = r.RunnerId
	WHERE ref.RefName = 'Runner'
	ORDER BY Value

	SELECT ref.ResourceId
		,LTRIM(RTRIM(ref.Value)) AS Value
		,(CASE 
			WHEN mm.MarketId IS NULL THEN 0
			ELSE 1 END
			) AS IsSelected
	FROM dbo.RefResource AS ref WITH (NOLOCK)
		LEFT JOIN (
		SELECT mm.MarketId
		FROM dbo.MatchMarket AS mm WITH (NOLOCK)
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON mm.OWPMatchId = om.OWPMatchId
			AND om.OWPMatchId = @OWPMatchId
		) AS mm ON ref.ResourceId = mm.MarketId
	WHERE ref.RefName = 'Market'
	ORDER BY Value

	--- GET list match status to display
	UPDATE #tblMatchStatusList
	SET IsSelected = 1
	WHERE DisplayText = @MatchStatus
	
	IF (@MatchStatus IN (@str_Live, @str_Cancel, @str_Postponed, @str_Suspended))
	BEGIN
		UPDATE #tblMatchStatusList
		SET IsDisplay = 1
		WHERE DisplayText IN (@str_Live, @str_Cancel, @str_Postponed, @str_Suspended)
	END
	ELSE IF (@MatchStatus = @str_Inplay)
	BEGIN
		UPDATE #tblMatchStatusList
		SET IsDisplay = 1
		WHERE DisplayText IN (@str_Inplay, @str_Live, @str_Cancel, @str_Postponed, @str_Suspended)
	END
	ELSE IF (@MatchStatus = @str_Completed)
	BEGIN
		UPDATE #tblMatchStatusList
		SET IsDisplay = 1
		WHERE DisplayText IN (@str_Completed, @str_Live, @str_Cancel, @str_Postponed, @str_Suspended)
	END

	SELECT *
	FROM #tblMatchStatusList AS sl WITH (NOLOCK)
	WHERE sl.IsDisplay = 1

	DROP TABLE #tblMatchStatusList

END