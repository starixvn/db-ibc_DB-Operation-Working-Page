
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryDaily] @Date DATE
	,@User VARCHAR(2000) = ''
	,@SectionId VARCHAR(2000) = ''
	,@ShiftId VARCHAR(MAX) = ''
	,@LocationCode VARCHAR(2000) = ''
	,@ExcludeClosedAccount BIT = 1
	,@SiteId INT
AS
/*      
 Created: 20180508@Leo.Vo     
 Task : OWP - Search Daily Working Shift by Date
 DB: bodb_OWP      

 Revisions:
	20181209@Kane.Le: Add LeagueName
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181209@Kane.Le: Add Runner, Provider, IsMinorMatch - [Redmine: #104291]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
	20190509@Kane.Le: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
	20190521@Lita.Tang: Add Username value - [Feature: #113765]
	20190604@Kane.Le: Add SiteId - [Feature: #113832]
	20190703@Kane.Le: Add MinorBettypeId - [Feature: #115390]
	20191011@Tyler.Dang: Add EmployeeWorkingShiftNote & UserRemark - [Feature: #121901]
	
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @EventDateFrom DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '10:00:01')
		,@EventDateTo DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @Date), '11:59:59')
		,@QueryDateFrom DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00')
		,@QueryDateTo DATETIME = DATEADD(DAY, (DATEDIFF(DAY, 0, @Date) + 1), '11:59:59')
		,@DailyRemarkCategory INT = 2
	 
	DECLARE @tblUser TABLE (
		UserId INT
		,SectionId SMALLINT
		,LocationCode VARCHAR(10)
		,IsSecondAccount BIT
		)
	DECLARE @tblSection TABLE (
		SectionId INT
		,SectionName VARCHAR(50)
		)
	DECLARE @tblLocation TABLE (LocationCode VARCHAR(10))
	DECLARE @tblMatch TABLE (OWPMatchId INT)

	CREATE TABLE #tblWorkingShift (EmployeeId INT)

	CREATE TABLE #tblUserBettype (
		UserId INT
		,OWPMatchId INT
		,BetType INT
		,EventDateTime DATETIME
		)

	 
	-- Get Section filter
	INSERT INTO @tblSection (
		SectionId
		,SectionName
		)
	SELECT SectionId
		,SectionName
	FROM dbo.fnc_GetSectionByIds(@SectionId)

	-- Get LocationCode filter
	INSERT INTO @tblLocation (LocationCode)
	SELECT val
	FROM dbo.fnc_SplitStrings(@LocationCode, ',')

	-- Get Users have WorkingShift filter
	IF LEN(ISNULL(@ShiftId, '')) = 0
	BEGIN
		INSERT INTO #tblWorkingShift (EmployeeId)
		SELECT UserId
		FROM dbo.[User] AS u WITH (NOLOCK)
	END
	ELSE
	BEGIN
		INSERT INTO #tblWorkingShift (EmployeeId)
		SELECT ws.EmployeeId
		FROM dbo.fnc_SplitStrings(@ShiftId, ',') AS sh
			INNER JOIN dbo.EmployeeWorkingShift AS ws WITH (NOLOCK) ON sh.val = ws.ShiftId
		WHERE ws.ShiftDate = @Date
		OPTION (MAXRECURSION 0)
	END

	-- Get Users have valid filter
	INSERT INTO @tblUser (
		UserId
		,SectionId
		,LocationCode
		,IsSecondAccount
		)
	SELECT u.UserId
		,ISNULL(u.SectionId, 0)
		,ISNULL(u.LocationCode, 'None')
		,u.IsSecondAccount
	FROM dbo.[User] AS u WITH (NOLOCK)
		INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON u.UserId = ci.custid
		INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH (NOLOCK) ON us.UserId = u.UserId
		AND us.SiteId = @SiteId
	WHERE (
			@ExcludeClosedAccount = 0
			OR (
				ci.closed = 0
				AND ci.reject = 0
				AND ci.[Enabled] = 1
				AND us.IsActive = 1
				)
			)
		AND (
			LEN(ISNULL(@User, '')) = 0
			OR u.Nickname LIKE '%' + @User + '%'
			OR u.Username LIKE '%' + @User + '%'
			)
		AND EXISTS (
			SELECT 1
			FROM @tblSection AS s
			WHERE u.SectionId = s.SectionId
				OR (
					u.SectionId IS NULL
					AND s.SectionId = 0
					)
			)
		AND EXISTS (
			SELECT 1
			FROM @tblLocation AS l
			WHERE u.LocationCode = l.LocationCode
				OR (
					u.LocationCode IS NULL
					AND l.LocationCode = 'None'
					)
			)
		AND EXISTS (
			SELECT 1
			FROM #tblWorkingShift AS ws
			WHERE ws.EmployeeId = u.UserId
		)

	-- Major bet types
	INSERT INTO #tblUserBettype (
		UserId
		,OWPMatchId
		,Bettype
		,EventDateTime
		)
	SELECT DISTINCT u.UserId
		,a.OWPMatchId
		,a.Bettype
		,m.EventDateTime
	FROM @tblUser u
		LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON u.UserId = a.UserId
		LEFT JOIN dbo.MajorBettype AS mb WITH (NOLOCK) ON a.Bettype = mb.BettypeId
		LEFT JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
		LEFT JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mi.OWPMatchId = mm.MinorMatchId
	WHERE mi.MatchStatus <> 'Cancel'
		AND a.UserId IS NOT NULL
		AND m.EventDateTime >= @EventDateFrom
		AND m.EventDateTime <= @EventDateTo
		AND mm.ParentMatchId IS NULL

	-- Minor bet types
	INSERT INTO #tblUserBettype (
		UserId
		,OWPMatchId
		,Bettype
		,EventDateTime
		)
	SELECT DISTINCT u.UserId
		,mm.ParentMatchId
		,mb.ParentBettypeId
		,m.EventDateTime
	FROM @tblUser u
		INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON u.UserId = a.UserId
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON a.Bettype = mb.InheritedBettypeId
		INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
		INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
		AND mm.MinorBettypeId = mb.ParentBettypeId
	WHERE mi.MatchStatus <> 'Cancel'
		AND a.UserId IS NOT NULL
		AND m.EventDateTime >= @EventDateFrom
		AND m.EventDateTime <= @EventDateTo

	INSERT INTO @tblMatch
	SELECT DISTINCT OWPMatchId
	FROM #tblUserBettype

	-- DELETE users have isSecondAccount = true but not have assignment on this date range
	DELETE u
	FROM @tblUser AS u
	WHERE u.IsSecondAccount = 1
	AND NOT EXISTS (
		SELECT 1
		FROM #tblUserBettype AS bt
		WHERE bt.UserId = u.UserId
	)
	
	------------------------
	-- return UserList
	SELECT u.UserId AS EmployeeId
		,u.SectionId
		,ts.SectionName
		,us.Username
		,us.Nickname
		,ul.LevelName
		,ug.GroupName
		,us.IsSecondAccount
		,ws.ShiftId
		,ur.Remark
	FROM @tblUser AS u
		INNER JOIN dbo.[User] AS us ON u.UserId = us.UserId
		INNER JOIN @tblSection AS ts ON ts.SectionId = u.SectionId
		LEFT JOIN (
			SELECT ResourceId AS GroupId
				,Value AS GroupName
			FROM dbo.RefResource WITH (NOLOCK)
			WHERE RefName = 'UserGroup'
		) AS ug ON us.GroupId = ug.GroupId
		LEFT JOIN (
			SELECT ResourceId AS LevelId
				,Value AS LevelName
			FROM dbo.RefResource WITH (NOLOCK)
			WHERE RefName = 'UserLevel'
		) AS ul ON us.[Level] = ul.LevelId
		LEFT JOIN dbo.EmployeeWorkingShift AS ws WITH (NOLOCK) ON u.UserId = ws.EmployeeId AND ws.ShiftDate = @Date
		LEFT JOIN dbo.UserRemark AS ur WITH (NOLOCK) ON ur.UserId = u.UserId AND ur.Category = @DailyRemarkCategory
		LEFT JOIN dbo.EmployeeWorkingShiftOrder AS od WITH (NOLOCK) ON od.EmployeeId = u.UserId
			AND od.SectionId = u.SectionId
			AND od.UserId = 0
	ORDER BY ts.SectionName
		,CASE 
			WHEN od.OrderId IS NOT NULL THEN 1
			ELSE 2
			END
		,od.OrderId
		,us.Username;

	-- return WorkingShift
	SELECT u.UserId AS EmployeeId
		,ws.ShiftDate
		,ws.ShiftId
		,ws.ShiftStartTime
		,ws.ShiftEndTime
	FROM @tblUser AS u
		INNER JOIN dbo.EmployeeWorkingShift AS ws WITH (NOLOCK) ON u.UserId = ws.EmployeeId
	WHERE @QueryDateFrom <= ws.ShiftEndTime AND @QueryDateTo >= ws.ShiftStartTime

	-- return UserBettype
	SELECT UserId
		,OWPMatchId
		,Bettype
		,EventDateTime
	FROM #tblUserBettype WITH (NOLOCK)

	-- return MatchInfo
	SELECT m.OWPMatchId
		,m.MatchNo
		,STUFF((
				SELECT ', ' + CAST(op.OtherProviderName AS NVARCHAR(30))
				FROM dbo.OtherProvider AS op WITH (NOLOCK)
				WHERE op.OtherProviderId IN (
						SELECT ot.OtherProviderId
						FROM dbo.MatchOtherProvider AS ot WITH (NOLOCK)
						WHERE ot.OWPMatchId = m.OWPMatchId
						)
				FOR XML PATH('')
				), 1, 1, '') AS 'OtherProvider'
		,STUFF((
				SELECT ', ' + CAST(p.ProviderName AS NVARCHAR(30))
				FROM dbo.[Provider] AS p WITH (NOLOCK)
				WHERE p.ProviderId IN (
						SELECT p.ProviderId
						FROM dbo.MatchProvider AS p WITH (NOLOCK)
						WHERE p.OWPMatchId = m.OWPMatchId
						)
				FOR XML PATH('')
				), 1, 1, '') AS 'Provider'
		,m.EventDateTime		
		,l.CategoryId
		,l.OWPLeagueName AS 'LeagueName'
		,h.OWPTeamName AS 'HomeName'
		,a.OWPTeamName AS 'AwayName'
		,(CASE 
			WHEN ms.Maxbet IS NOT NULL THEN ms.Maxbet
			ELSE dbo.OWP_MaxBetGet(m.OWPMatchId, m.OWPLeagueId, 1) END
			) AS MaxBet
	FROM @tblMatch match
		INNER JOIN dbo.OWPMatch m WITH (NOLOCK) ON m.OWPMatchId = match.OWPMatchId
		INNER JOIN dbo.OWPLeague l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
		INNER JOIN dbo.MatchInfo mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
		INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
		INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
		LEFT JOIN dbo.MatchSetting ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId		
		AND ms.Bettype = 1

	-- Return notes
	DECLARE @TimeZoneGMT8 INT = 8;
	SELECT ewn.UserId
		,ewn.EmployeeWorkingShiftNoteId
		,ewn.Note
		,u.Username
		,DATEADD(HH, @TimeZoneGMT8, (DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), ewn.CreatedDate))) AS LastUpdated
	FROM dbo.EmployeeWorkingShiftNote AS ewn WITH (NOLOCK)
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON ewn.CreatedBy = u.UserId
	WHERE CAST(ewn.ShiftDate AS DATE) = @Date
	ORDER BY ewn.CreatedDate DESC

	DROP TABLE #tblUserBettype

	DROP TABLE #tblWorkingShift
END