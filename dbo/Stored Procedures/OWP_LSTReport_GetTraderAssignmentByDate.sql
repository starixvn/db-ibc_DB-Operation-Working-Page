
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LSTReport_GetTraderAssignmentByDate] @FromDate DATETIME
	,@ToDate DATETIME
	,@IsIncludeMinorMatch BIT = 0
AS
/*    
 Created: 20191218@Kane.Le
 Task : GetTraderAssignmentByDate
 DB: bodb_OWP    
    
 Revisions:
	20191218@Kane.Le: Initial SP - [Redmine: #124448]	
*/
BEGIN
	SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00')
	SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, - 1, @ToDate), '11:59:59')

	-- SELECT  @FromDate, @ToDate
	-- DECLARE CONSTANTS
	DECLARE @LA_Bettype INT = - 1002

	SELECT u.UserId
		,u.Username
		,ma.OWPMatchId
		,ass.Bettype
		,ma.EventDate
		,mi.IsSoloMatch
		,ma.OWPLeagueId AS 'LeagueId'
		,la.OWPLeagueName AS 'LeagueName'
		,la.CategoryId
		,mn.MinorBettypeId
		,NULL AS 'ParentMatchId'
	FROM dbo.[User] u WITH (NOLOCK)
	LEFT JOIN dbo.Assignment ass WITH (NOLOCK) ON u.UserId = ass.UserId
	LEFT JOIN dbo.OWPMatch ma WITH (NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
	LEFT JOIN dbo.OWPLeague la WITH (NOLOCK) ON la.OWPLeagueId = ma.OWPLeagueId
	LEFT JOIN dbo.MatchInfo mi WITH (NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
	LEFT OUTER JOIN dbo.MinorMatch mn WITH (NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
	WHERE mn.MinorMatchId IS NULL
		AND ass.AssignmentType = 1
		AND ma.EventDateTime >= @FromDate
		AND ma.EventDateTime <= @ToDate
		AND ass.Bettype <> @LA_Bettype
	
	UNION
	
	SELECT u.UserId
		,u.Username
		,ma.OWPMatchId
		,ass.Bettype
		,ma.EventDate
		,mi.IsSoloMatch
		,ma.OWPLeagueId
		,la.OWPLeagueName
		,la.CategoryId
		,mn.MinorBettypeId
		,mn.ParentMatchId
	FROM dbo.[User] u WITH (NOLOCK)
	LEFT JOIN dbo.Assignment ass WITH (NOLOCK) ON u.UserId = ass.UserId
	LEFT JOIN dbo.OWPMatch ma WITH (NOLOCK) ON ma.OWPMatchId = ass.OWPMatchId
	LEFT JOIN dbo.OWPLeague la WITH (NOLOCK) ON la.OWPLeagueId = ma.OWPLeagueId
	LEFT JOIN dbo.MatchInfo mi WITH (NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
	LEFT OUTER JOIN dbo.MinorMatch mn WITH (NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
	WHERE mn.MinorMatchId IS NOT NULL
		AND ass.AssignmentType = 1
		AND ma.EventDateTime >= @FromDate
		AND ma.EventDateTime <= @ToDate
		AND ass.Bettype <> @LA_Bettype
		AND @IsIncludeMinorMatch > 0
END