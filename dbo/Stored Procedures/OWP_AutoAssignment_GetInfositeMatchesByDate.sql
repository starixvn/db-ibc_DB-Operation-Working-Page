
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetInfositeMatchesByDate] @EventDate DATE
AS
/*
Created: 20211119@carlos.Nguyen
Task : Get match list by date for auto assignment
DB: bodb_OWP

Revisions:
	20211119@carlos.Nguyen: Initial SP - [Redmine: #163362]
*/

BEGIN
	SET NOCOUNT ON
	
	/* Declare variable*/
	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')
		
	CREATE TABLE #tblInfositeMatch(
		MatchId INT,
		HasTV BIT,
		MaxBetMainMatch MONEY,
		MaxBetNoOfCorner MONEY,
		MaxBetNextCorner MONEY,
		KOTime DATETIME,
		RequireChinese BIT,
		IsSoloMatch BIT,
		IsMajorLeague BIT,
		ExtraTime NVARCHAR(500),
		Provider NVARCHAR(2000),
		Venue NVARCHAR(2000),
		IsFantasy BIT,
		HasChannel BIT
	)
	
	INSERT INTO #tblInfositeMatch(
		MatchId,
		HasTV,
		MaxBetMainMatch,
		MaxBetNoOfCorner,
		MaxBetNextCorner,
		KOTime,
		RequireChinese,
		IsSoloMatch,
		IsMajorLeague,
		ExtraTime,
		Provider,
		Venue,
		IsFantasy,
		HasChannel
	)
	SELECT im.InfoSiteMatchId,
		CASE WHEN LEN(im.TV)>0 THEN 1 ELSE 0 END,
		0,
		0,
		0,
		im.EventDateTime,
		CASE WHEN CHARINDEX('Chinese', im.Agent) > 0 OR CHARINDEX('C Only', im.Agent) > 0 THEN 1 ELSE 0 END,
		0,
		CASE WHEN l.CategoryId IS NOT NULL THEN 1 ELSE 0 END,
		im.ETPK,
		im.Provider,
		im.Venue,
		CASE WHEN im.LeagueName LIKE '%FANTASY%' THEN 1 ELSE 0 END,
		CASE WHEN LEN(im.Channel)>0 THEN 1 ELSE 0 END
		
	FROM InfoSiteMatch AS im LEFT JOIN dbo.OWPLeague AS l WITH (NOLOCK)
		ON im.OWPLeagueId = l.OWPLeagueId AND l.CategoryId=1
	WHERE im.EventDateTime BETWEEN @FromDate
			AND @ToDate
	DROP TABLE #tblInfositeMatch
END
