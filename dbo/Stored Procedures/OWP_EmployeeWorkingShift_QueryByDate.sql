/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryByDate] @Date DATE
	,@UserId VARCHAR(max) = ''
AS
/*      
 Created: 20180508@Leo.Vo     
 Task : OWP - Search Working Shift by Date
 DB: bodb_OWP      

 Revisions:
	20181209@Kane.Le: Add LeagueName
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181209@Kane.Le: Add Runner, Provider, IsMinorMatch - [Redmine: #104291]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]

 -- @Note:    
EXEC OWP_EmployeeWorkingShift_QueryByDate @Date = '2017/12/14', @UserId = '8';

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '10:00:01')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @Date), '11:59:59')
	DECLARE @tblUser TABLE (UserId INT);

	IF LEN(ISNULL(@UserId, '')) = 0
	BEGIN
		INSERT INTO @tblUser
		SELECT UserId
		FROM dbo.[User] AS u WITH (NOLOCK)
	END;
	ELSE
	BEGIN
		INSERT INTO @tblUser
		SELECT val
		FROM dbo.strSplit(@UserId, ',')
	END;

	CREATE TABLE #tblUserBettype (
		UserId INT
		,OWPMatchId INT
		,BetType INT
		)

	-- Major bet types
	INSERT INTO #tblUserBettype (
		UserId
		,OWPMatchId
		,Bettype
		)
	SELECT DISTINCT u.UserId
		,a.OWPMatchId
		,a.Bettype
	FROM @tblUser u
	LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON u.UserId = a.UserId
	LEFT JOIN dbo.MajorBettype AS mb WITH (NOLOCK) ON a.Bettype = mb.BettypeId
	LEFT JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
	LEFT JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
	LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON mi.OWPMatchId = mm.MinorMatchId
	WHERE mi.MatchStatus <> 'Cancel'
		AND a.AssignmentType = 1
		AND m.EventDateTime >= @FromDate
		AND m.EventDateTime <= @ToDate
		AND mm.ParentMatchId IS NULL

	-- Minor bet types
	INSERT INTO #tblUserBettype (
		UserId
		,OWPMatchId
		,Bettype
		)
	SELECT DISTINCT u.UserId
		,mm.ParentMatchId
		,mb.ParentBettypeId
	FROM @tblUser u
	INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON u.UserId = a.UserId
	INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON a.Bettype = mb.InheritedBettypeId
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON a.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON mi.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
		AND mm.MinorBettypeId = mb.ParentBettypeId
	WHERE mi.MatchStatus <> 'Cancel'
		AND a.AssignmentType = 1
		AND m.EventDateTime >= @FromDate
		AND m.EventDateTime <= @ToDate

	SELECT UserId
		,OWPMatchId
		,Bettype
	FROM #tblUserBettype WITH (NOLOCK)

	DECLARE @tblMatch TABLE (OWPMatchId INT);

	INSERT INTO @tblMatch
	SELECT DISTINCT OWPMatchId
	FROM #tblUserBettype

	SELECT m.OWPMatchId
		,m.MatchNo
		,STUFF((
				SELECT ', ' + CAST(op.OtherProviderName AS NVARCHAR(30))
				FROM dbo.OtherProvider AS op WITH (NOLOCK)
				WHERE op.OtherProviderId IN (
						SELECT val
						FROM dbo.[strSplit](mi.OtherProvider, ',')
						)
				FOR XML PATH('')
				), 1, 1, '') AS 'OtherProvider'
		,STUFF((
				SELECT ', ' + CAST(p.ProviderName AS NVARCHAR(30))
				FROM dbo.[Provider] AS p WITH (NOLOCK)
				WHERE p.ProviderId IN (
						SELECT val
						FROM dbo.[strSplit](mi.[Provider], ',')
						)
				FOR XML PATH('')
				), 1, 1, '') AS 'Provider'
		,m.EventDateTime		
		,l.CategoryId
		,l.OWPLeagueName AS 'LeagueName'
		,h.OWPTeamName AS 'HomeName'
		,a.OWPTeamName AS 'AwayName'
		,(
			CASE 
				WHEN ms.Maxbet IS NOT NULL
					THEN ms.Maxbet
				ELSE dbo.OWP_MaxBetGet(m.OWPMatchId, m.OWPLeagueId, 1)
				END
			) AS MaxBet
	FROM @tblMatch match
	INNER JOIN dbo.OWPMatch m WITH (NOLOCK) ON m.OWPMatchId = match.OWPMatchId
	INNER JOIN dbo.OWPLeague l WITH (NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
	INNER JOIN dbo.MatchInfo mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON m.OWPHomeId = h.OWPTeamId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON m.OWPAwayId = a.OWPTeamId
	LEFT JOIN dbo.MatchSetting ms WITH (NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
		AND ms.Bettype = 1

	DROP TABLE #tblUserBettype
END;