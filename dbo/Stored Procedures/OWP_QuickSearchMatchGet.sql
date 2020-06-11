/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_QuickSearchMatchGet] @UserId INT = 0
	,@SearchKeywords NVARCHAR(100)
	,@IsNumericKeywords BIT = 0
	,@SelectTop INT = NULL
	,@LastOWPMatchId INT = NULL
	,@IsFullTimeView BIT = 0
	,@IsTimeRange BIT =0
AS
/*    
Created: 20161005@Simon.Huynh    
Task : select match with search string   
DB: bodb_OWP    

Revisions:    
  20161011@Long.Luu: restructure
  20161103@Long.Luu: support search by role
  20170411@Raymond.Le: Change Order search and not show minor match
  20170419@Tim.Trinh: modify trader view time
  20170731@Raymond.Le: Implement Quick Search v2.0, can search by assignee name, merge result 15'... to main match
  20180427@leo.vo: Add FM & AIO
  20181002@Raymond.Le: Fix overflow data type in RefResource
  20180806@Raymond.Le: New structure of event assignment - [Redmine: #92868]
  20190521@Leo.Vo: Add Username value - [Feature: #113765]
  20190920@Leo.Vo: Update permission - [Feature: #120415]
  20200906@Carlos.Nguyen: Split full time/timerange/ony match is assign - [Redmine: #135527]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @owpTodayFrom DATETIME
		,@owpTodayTo DATETIME
		,@CurrentRow INT = NULL
		,@FromTimeToGetData DATETIME
		,@FromTimePM TIME = '12:00:00'
		,@ToTimePM TIME = '23:59:59'
		,@YesterdayGMT8 DATETIME = DATEADD(hh, 12, DATEADD(DAY, - 1, GETDATE()))
	DECLARE @FromTime DATETIME
		,@ToTime DATETIME
		,@FromTimeForSpecialBettype DATETIME
		,@ToTimeViewDetailForSpecialBettype DATETIME
		,@ToTimeForSpecialBettype DATETIME
		,@Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@Specific15MinsNoOfCorners INT = - 5
		,@NoOfCorners INT = - 3
		,@NextCorners INT = - 4
		,@LastCorners INT = - 90
		,@HomeSingleTeamCorners INT = - 94
		,@AwaySingleTeamCorners INT = - 95
		,@Specific15MinsTotalBooking INT = - 8
		,@TotalBooking INT = - 6
		,@NextBooking INT = - 7
		,@LastBooking INT = - 91
		,@FastMarket INT = - 88
		,@AllInOne INT = - 89

	--Initialize parameter
	SELECT @FromTimeToGetData = (CASE 
			WHEN CAST(@YesterdayGMT8 AS TIME) BETWEEN @FromTimePM
					AND @ToTimePM THEN DATEADD(dd, DATEDIFF(dd, 0, @YesterdayGMT8), '12:00:00')
			ELSE DATEADD(dd, DATEDIFF(dd, 0, DATEADD(DAY, - 1, @YesterdayGMT8)), '12:00:00') END
			)

	SELECT @FromTime = @FromTimeToGetData
		,@ToTime = ToTime
		,@FromTimeForSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeForSpecialBettype = ToTimeForSpecialBettype
		,@ToTimeViewDetailForSpecialBettype = ToTimeViewDetailForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	SELECT @owpTodayFrom = @FromTimeForSpecialBettype
		,@owpTodayTo = @ToTimeForSpecialBettype

	CREATE TABLE #tblAssignedMatches (OWPMatchId INT)

	CREATE TABLE #tblSuggestedMatches (
		OWPMatchId INT
		,ParentMatchId INT
		,MinorBettypeId INT
		,MatchNo NVARCHAR(50)
		,EventDate DATETIME
		,[Event] NVARCHAR(500)
		,IsToday BIT
		,UserId INT
		,AssigneeName VARCHAR(50)
		,Bettype INT
		,AssignmentType SMALLINT
		)

	CREATE TABLE #tblFinalResults (
		OWPMatchId INT
		,ParentMatchId INT
		,MatchNo NVARCHAR(50)
		,EventDate DATETIME
		,[Event] NVARCHAR(500)
		,IsToday BIT
		,IsAllowedToViewDetail BIT
		,UserId INT
		,AssigneeName VARCHAR(50)
		,Bettype INT
		,AssignmentType SMALLINT
		)

	--- Filter match & assignee like keyword 		
	IF (@IsNumericKeywords = 1)
	BEGIN
		--DECLARE @TrimSearchKeywords NVARCHAR(100) = CAST( CAST(@SearchKeywords AS INT) AS NVARCHAR(100))	
		INSERT INTO #tblSuggestedMatches (
			OWPMatchId
			,ParentMatchId
			,MinorBettypeId
			,MatchNo
			,EventDate
			,[Event]
			,IsToday
			,UserId
			,AssigneeName
			,Bettype
			,AssignmentType
			)
		SELECT sm.OWPMatchId
			,sm.ParentMatchId
			,sm.MinorBettypeId
			,sm.MatchNo
			,sm.EventDate
			,sm.[Event]
			,sm.IsToday
			,am.UserId
			,NULL
			,am.Bettype
			,am.AssignmentType
		FROM (
			SELECT DISTINCT om.OWPMatchId
				,minor.ParentMatchId
				,minor.MinorBettypeId
				,ISNULL(om.MatchNo, '') AS MatchNo
				,om.EventDateTime AS EventDate
				,(CASE 
					WHEN minor.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne) THEN NULL
					ELSE home.OWPTeamName + ' -vs- ' + away.OWPTeamName END
					) AS [Event]
				,(CASE 
					WHEN om.EventDateTime BETWEEN @owpTodayFrom
							AND @owpTodayTo THEN 1
					ELSE 0 END
					) AS IsToday
			FROM dbo.OWPMatch AS om WITH (NOLOCK)
				INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
				AND mi.IsSelected = 1
				LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
				LEFT JOIN dbo.OWPLeague AS ol WITH (NOLOCK) ON om.OWPLeagueId = ol.OWPLeagueId
				INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = om.OWPHomeId
				INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = om.OWPAwayId
			) AS sm
			FULL OUTER JOIN dbo.Assignment AS am WITH (NOLOCK) ON am.OWPMatchId = sm.OWPMatchId
			LEFT JOIN dbo.[User] AS us WITH (NOLOCK) ON us.UserId = am.UserId
		WHERE sm.IsToday = 1
			AND (
				(
					ISNUMERIC(sm.MatchNo) = 1
					AND sm.MatchNo = CAST(@SearchKeywords AS INT)
					)
				OR (LTRIM(SUBSTRING(sm.MatchNo, PATINDEX('%[^0]%', sm.MatchNo), 50)) LIKE @SearchKeywords + '[^0-9]%')
				)
	END
	ELSE
	BEGIN
		INSERT INTO #tblSuggestedMatches (
			OWPMatchId
			,ParentMatchId
			,MinorBettypeId
			,MatchNo
			,EventDate
			,[Event]
			,IsToday
			,UserId
			,AssigneeName
			,Bettype
			,AssignmentType
			)
		SELECT sm.OWPMatchId
			,sm.ParentMatchId
			,sm.MinorBettypeId
			,sm.MatchNo
			,sm.EventDate
			,sm.[Event]
			,sm.IsToday
			,am.UserId
			,(CASE 
				WHEN us.Username LIKE '%' + @SearchKeywords + '%' THEN us.Username
				WHEN us.Nickname LIKE '%' + @SearchKeywords + '%' THEN us.Nickname END
				)
			,am.Bettype
			,am.AssignmentType
		FROM (
			SELECT DISTINCT om.OWPMatchId
				,minor.ParentMatchId
				,minor.MinorBettypeId
				,ISNULL(om.MatchNo, '') AS MatchNo
				,om.EventDateTime AS EventDate
				,(CASE 
					WHEN minor.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking, @FastMarket, @AllInOne) THEN NULL
					ELSE home.OWPTeamName + ' -vs- ' + away.OWPTeamName END
					) AS [Event]
				,(CASE 
					WHEN om.EventDateTime BETWEEN @owpTodayFrom
							AND @owpTodayTo THEN 1
					ELSE 0 END
					) AS IsToday
			FROM dbo.OWPMatch AS om WITH (NOLOCK)
				INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
				AND mi.IsSelected = 1
				LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
				INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = om.OWPHomeId
				INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = om.OWPAwayId
			) AS sm
			FULL OUTER JOIN dbo.Assignment AS am WITH (NOLOCK) ON am.OWPMatchId = sm.OWPMatchId
			LEFT JOIN dbo.[User] AS us WITH (NOLOCK) ON us.UserId = am.UserId
		WHERE sm.EventDate > @FromTimeToGetData
			AND (
				sm.[Event] LIKE '%' + @SearchKeywords + '%'
				OR (
					sm.MatchNo LIKE '%' + @SearchKeywords + '%'
					AND sm.IsToday = 1
					)
				OR us.Username LIKE '%' + @SearchKeywords + '%'
				OR us.Nickname LIKE '%' + @SearchKeywords + '%'
				)
	END

	-- Merge specific 15', 10', FM, AIO to main match
	UPDATE sm
	SET sm.OWPMatchId = om.OWPMatchId
		,sm.ParentMatchId = NULL
		,sm.MatchNo = ISNULL(om.MatchNo, '')
		,sm.MinorBettypeId = NULL
		,sm.EventDate = om.EventDateTime
		,sm.[Event] = home.OWPTeamName + ' -vs- ' + away.OWPTeamName
	FROM #tblSuggestedMatches AS sm WITH (ROWLOCK)
		LEFT JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = sm.ParentMatchId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = om.OWPHomeId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = om.OWPAwayId
	WHERE sm.MinorBettypeId IN (@Specific15Mins, @Specific10Mins, @FastMarket, @AllInOne)

	-- Merge NoC 15' to NoC, Total booking 15' to Total Booking 
	UPDATE sm
	SET sm.OWPMatchId = om.OWPMatchId
		,sm.MatchNo = ISNULL(om.MatchNo, '')
		,sm.MinorBettypeId = minor.MinorBettypeId
		,sm.EventDate = om.EventDateTime
		,sm.[Event] = home.OWPTeamName + ' -vs- ' + away.OWPTeamName
	FROM #tblSuggestedMatches AS sm WITH (ROWLOCK)
		LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON minor.ParentMatchId = sm.ParentMatchId
		AND minor.MinorBettypeId = (CASE 
			WHEN sm.MinorBettypeId = @Specific15MinsNoOfCorners THEN @NoOfCorners
			WHEN sm.MinorBettypeId = @Specific15MinsTotalBooking THEN @TotalBooking
			ELSE NULL END
			)
		LEFT JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = om.OWPHomeId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = om.OWPAwayId
	WHERE sm.MinorBettypeId IN (@Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)

	-- GET USER'S ASSIGNED MATCHES
	INSERT INTO #tblAssignedMatches (OWPMatchId)
	SELECT DISTINCT a.OWPMatchId
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON a.OWPMatchId = om.OWPMatchId
		AND om.EventDateTime > @FromTimeToGetData
	WHERE a.UserId = @UserId
	--SELECT @UserId

	-- FILTER RESULTS
	IF @IsFullTimeView = 0 AND @IsTimeRange=0
	BEGIN
		-- get events can view detail
		INSERT INTO #tblFinalResults (
			OWPMatchId
			,ParentMatchId
			,MatchNo
			,EventDate
			,[Event]
			,IsToday
			,IsAllowedToViewDetail
			,UserId
			,AssigneeName
			,Bettype
			,AssignmentType
			)
		SELECT a.OWPMatchId
			,a.ParentMatchId
			,a.MatchNo
			,a.EventDate
			,a.[Event]
			,a.IsToday
			,1
			,a.UserId
			,a.AssigneeName
			,a.Bettype
			,a.AssignmentType
		FROM #tblSuggestedMatches AS a WITH (NOLOCK)
			INNER JOIN (
			SELECT am.OWPMatchId
			FROM #tblAssignedMatches AS am WITH (NOLOCK)
			
			UNION
			SELECT DISTINCT mm.ParentMatchId
			FROM dbo.MinorMatch AS mm WITH (NOLOCK)
				INNER JOIN #tblAssignedMatches AS am WITH (NOLOCK) ON mm.MinorMatchId = am.OWPMatchId
			) AS b ON a.OWPMatchId = b.OWPMatchId
		WHERE a.EventDate>DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00')
			AND a.UserId=@UserId
			AND a.EventDate BETWEEN @FromTime
				AND @ToTimeViewDetailForSpecialBettype
		ORDER BY a.IsToday DESC
			,(CASE 
				WHEN ISNUMERIC(@SearchKeywords) = 1
					AND a.MatchNo = @SearchKeywords THEN 1
				WHEN ISNUMERIC(@SearchKeywords) = 1
					AND a.MatchNo LIKE '%' + @SearchKeywords + '%' THEN 2
				WHEN a.EventDate >= @owpTodayFrom THEN 3
				ELSE 4 END
				) ASC
			,(CASE 
				WHEN a.EventDate >= @owpTodayFrom THEN a.EventDate END
				) ASC
			,(CASE 
				WHEN a.EventDate < @owpTodayFrom THEN a.EventDate END
				) DESC
		
			-- get events can not view detail
		INSERT INTO #tblFinalResults (
			OWPMatchId
			,ParentMatchId
			,MatchNo
			,EventDate
			,[Event]
			,IsToday
			,IsAllowedToViewDetail
			,UserId
			,AssigneeName
			,Bettype
			,AssignmentType
			)
		SELECT sm.OWPMatchId
			,sm.ParentMatchId
			,sm.MatchNo
			,sm.EventDate
			,sm.[Event]
			,sm.IsToday
			,0 AS IsAllowedToViewDetail
			,sm.UserId
			,sm.AssigneeName
			,sm.Bettype
			,sm.AssignmentType
		FROM #tblSuggestedMatches AS sm WITH (NOLOCK)
		WHERE sm.EventDate>DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00')
			AND sm.EventDate > @ToTimeViewDetailForSpecialBettype
			AND sm.EventDate <= @ToTimeForSpecialBettype
			AND sm.UserId=@UserId
			AND EXISTS (
				SELECT 1
				FROM dbo.MinorMatch AS minor WITH (NOLOCK)
				WHERE sm.OWPMatchId = minor.MinorMatchId
					AND minor.MinorBettypeId IN (@NextCorners, @NoOfCorners, @LastCorners, @HomeSingleTeamCorners, @AwaySingleTeamCorners, @NextBooking, @TotalBooking, @LastBooking)
					AND minor.IsRepresented = 1
				)
			AND NOT EXISTS (
				SELECT 1
				FROM #tblFinalResults WITH (NOLOCK)
				WHERE OWPMatchId = sm.OWPMatchId
				)
		ORDER BY sm.IsToday DESC
			,(CASE 
				WHEN ISNUMERIC(@SearchKeywords) = 1
					AND sm.MatchNo = @SearchKeywords THEN 1
				WHEN ISNUMERIC(@SearchKeywords) = 1
					AND sm.MatchNo LIKE '%' + @SearchKeywords + '%' THEN 2
				WHEN sm.EventDate >= @owpTodayFrom THEN 3
				ELSE 4 END
				) ASC
			,(CASE 
				WHEN sm.EventDate >= @owpTodayFrom THEN sm.EventDate END
				) ASC
			,(CASE 
				WHEN sm.EventDate < @owpTodayFrom THEN sm.EventDate END
				) DESC
	END
	
	IF @IsFullTimeView=1 OR @IsTimeRange=1
	BEGIN
		INSERT INTO #tblFinalResults (
			OWPMatchId
			,ParentMatchId
			,MatchNo
			,EventDate
			,[Event]
			,IsToday
			,IsAllowedToViewDetail
			,UserId
			,AssigneeName
			,Bettype
			,AssignmentType
			)
		SELECT a.OWPMatchId
			,a.ParentMatchId
			,a.MatchNo
			,a.EventDate
			,a.[Event]
			,a.IsToday
			,1
			,a.UserId
			,a.AssigneeName
			,a.Bettype
			,a.AssignmentType
		FROM #tblSuggestedMatches AS a WITH (NOLOCK)
		WHERE 1=CASE
			WHEN @IsFullTimeView=1 THEN 1
			WHEN @IsTimeRange=1 AND a.EventDate>DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00') THEN 1
			ELSE 0
			END
		ORDER BY a.IsToday DESC
			,(CASE 
				WHEN ISNUMERIC(@SearchKeywords) = 1
					AND a.MatchNo = @SearchKeywords THEN 1
				WHEN ISNUMERIC(@SearchKeywords) = 1
					AND a.MatchNo LIKE '%' + @SearchKeywords + '%' THEN 2
				WHEN a.EventDate >= @owpTodayFrom THEN 3
				ELSE 4 END
				) ASC
			,(CASE 
				WHEN a.EventDate >= @owpTodayFrom THEN a.EventDate END
				) ASC
			,(CASE 
				WHEN a.EventDate < @owpTodayFrom THEN a.EventDate END
				) DESC
	END

	--- Order Table Final Result for load scroll ---
	CREATE TABLE #tblOrderedResult (
		RowNumber INT
		,OWPMatchId INT
		,ParentMatchId INT
		,MatchNo NVARCHAR(50)
		,[Event] NVARCHAR(500)
		,EventDate DATETIME
		,LeagueName NVARCHAR(2000)
		,IsToday BIT
		,IsAllowedToViewDetail BIT
		,IsHasAssignee BIT
		,Bettype INT
		)

	INSERT INTO #tblOrderedResult (
		RowNumber
		,OWPMatchId
		,ParentMatchId
		,MatchNo
		,[Event]
		,EventDate
		,LeagueName
		,IsToday
		,IsAllowedToViewDetail
		,IsHasAssignee
		)
	SELECT ROW_NUMBER() OVER (
			ORDER BY er.IsToday DESC
				,(CASE 
					WHEN ISNUMERIC(@SearchKeywords) = 1
						AND er.MatchNo = @SearchKeywords THEN 1
					WHEN ISNUMERIC(@SearchKeywords) = 1
						AND er.MatchNo LIKE '%' + @SearchKeywords + '%' THEN 2
					WHEN er.EventDate >= @owpTodayFrom THEN 3
					ELSE 4 END
					) ASC
				,(CASE 
					WHEN er.EventDate >= @owpTodayFrom THEN er.EventDate END
					) ASC
				,(CASE 
					WHEN er.EventDate < @owpTodayFrom THEN er.EventDate END
					) DESC
				,(CASE 
					WHEN er.ParentMatchId IS NULL THEN 0
					ELSE 1 END
					) ASC
			) AS RowNumber
		,er.OWPMatchId
		,er.ParentMatchId
		,er.MatchNo
		,er.[Event]
		,er.EventDate
		,NULL
		,er.IsToday
		,er.IsAllowedToViewDetail
		,NULL
	FROM (
		SELECT DISTINCT fr.OWPMatchId
			,fr.ParentMatchId
			,fr.MatchNo
			,fr.[Event]
			,fr.EventDate
			,fr.IsToday
			,fr.IsAllowedToViewDetail
		FROM #tblFinalResults AS fr WITH (NOLOCK)
		) AS er

	-- Update field isHasAssignee, add league name
	UPDATE re
	SET re.IsHasAssignee = (CASE 
			WHEN EXISTS (
					SELECT 1
					FROM #tblFinalResults AS fr WITH (NOLOCK)
					WHERE fr.OWPMatchId = re.OWPMatchId
						AND fr.AssigneeName IS NOT NULL
					) THEN 1
			ELSE 0 END
			)
		,re.LeagueName = ol.OWPLeagueName
	FROM #tblOrderedResult AS re WITH (ROWLOCK)
		LEFT JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = re.OWPMatchId
		LEFT JOIN dbo.OWPLeague AS ol WITH (NOLOCK) ON om.OWPLeagueId = ol.OWPLeagueId

	SELECT @CurrentRow = RowNumber
	FROM #tblOrderedResult WITH (NOLOCK)
	WHERE OWPMatchId = @LastOWPMatchId

	SET @CurrentRow = ISNULL(@CurrentRow, 0)
	SET @SelectTop = ISNULL(@SelectTop, 0)

	SELECT DISTINCT ot.RowNumber
		,ot.OWPMatchId
		,ot.ParentMatchId
		,ot.MatchNo
		,ot.[Event]
		,ot.EventDate
		,ot.LeagueName
		,ot.IsToday
		,ot.IsAllowedToViewDetail
		,ot.IsHasAssignee
		,mm.MinorBettypeId AS Bettype
	FROM #tblOrderedResult AS ot WITH (NOLOCK)
	LEFT JOIN MinorMatch AS mm WITH (NOLOCK)
	ON ot.OWPMatchId=mm.MinorMatchId
		AND mm.MinorBettypeId IN ( -3, -4, -6, -7, -90, -91, -94, -95 )
	WHERE ot.RowNumber >= (1 + @CurrentRow)
		AND ot.RowNumber <= (@SelectTop + @CurrentRow)

	--- Select List Result search User 
	SELECT DISTINCT fr.OWPMatchId
		,fr.UserId
		,fr.AssigneeName
		,fr.AssignmentType
		,(CASE 
			WHEN fr.Bettype > 0 THEN 1
			ELSE 0 END
			) AS IsTrader
	FROM #tblFinalResults AS fr WITH (NOLOCK)
		INNER JOIN #tblOrderedResult AS ot WITH (NOLOCK) ON ot.OWPMatchId = fr.OWPMatchId
	WHERE fr.AssigneeName IS NOT NULL

	DROP TABLE #tblAssignedMatches

	DROP TABLE #tblSuggestedMatches

	DROP TABLE #tblFinalResults

	DROP TABLE #tblOrderedResult
END