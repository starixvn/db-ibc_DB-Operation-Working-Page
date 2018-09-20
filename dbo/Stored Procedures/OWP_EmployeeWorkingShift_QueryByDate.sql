/*      
 Created: 20180508@Leo.Vo     
 Task : OWP - Search Working Shift by Date
 DB: bodb_OWP      

 -- @Note:    
EXEC OWP_EmployeeWorkingShift_QueryByDate @Date = '2017/12/14', @UserId = '8';

*/

CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryByDate] 
    @Date  date,
    @UserId    varchar(max)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '10:00:01')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59')

    DECLARE @tblUser TABLE
    ( 
        UserId int
    );
    INSERT INTO @tblUser
        SELECT val
        FROM dbo.strSplit(@UserId, ',')

	CREATE TABLE #tblUserBettype(
		UserId int
		,OWPMatchId int
		,BetType int
	)

	-- Major bet types
	INSERT INTO #tblUserBettype(
		UserId
		,OWPMatchId
		,Bettype
	)
	SELECT DISTINCT u.UserId
		,a.OWPMatchId
		,a.Bettype
	FROM @tblUser u
	INNER JOIN dbo.Assignment As a WITH (NOLOCK) ON u.UserId = a.UserId
	INNER JOIN dbo.MajorBettype AS mb WITH (NOLOCK) ON a.Bettype = mb.BettypeId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
	LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mi.OWPMatchId = mm.MinorMatchId
	WHERE mi.MatchStatus<>'Cancel' 
		AND a.AssignmentType = 1 
		AND m.EventDateTime >= @FromDate
		AND m.EventDateTime <= @ToDate
		AND mm.ParentMatchId IS NULL

	-- Minor bet types
	INSERT INTO #tblUserBettype(
		UserId
		,OWPMatchId
		,Bettype
	)
	SELECT DISTINCT u.UserId
		,mm.ParentMatchId
		,mb.MinorBettypeId
	FROM @tblUser u
	INNER JOIN dbo.Assignment As a WITH (NOLOCK) ON u.UserId = a.UserId
	INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON a.Bettype = mb.InheritedBettypeId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON m.OWPMatchId = mm.MinorMatchId AND mm.MinorBettypeId = mb.ParentBettypeId
	WHERE mi.MatchStatus<>'Cancel' 
		AND a.AssignmentType = 1 
		AND m.EventDateTime >= @FromDate
		AND m.EventDateTime <= @ToDate

	SELECT UserId
		,OWPMatchId
		,Bettype
	FROM #tblUserBettype WITH (NOLOCK)

	DECLARE @tblMatch TABLE
    ( 
        OWPMatchId int
    );
	INSERT INTO @tblMatch
	SELECT DISTINCT OWPMatchId
	FROM #tblUserBettype

	SELECT
		m.OWPMatchId
        ,m.MatchNo
		,m.EventDateTime
		,l.CategoryId		
		,h.OWPTeamName AS 'HomeName'
		,a.OWPTeamName AS 'AwayName'
		,(CASE WHEN ms.Maxbet IS NOT NULL THEN ms.Maxbet ELSE dbo.OWP_MaxBetGet(m.OWPMatchId, m.OWPLeagueId, 1) END) as MaxBet
	FROM @tblMatch match
	INNER JOIN dbo.OWPMatch m WITH (NOLOCK) ON m.OWPMatchId = match.OWPMatchId
	INNER JOIN dbo.OWPLeague l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.MatchInfo mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
	LEFT JOIN dbo.MatchSetting ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId AND ms.Bettype=1

	DROP TABLE #tblUserBettype
END;