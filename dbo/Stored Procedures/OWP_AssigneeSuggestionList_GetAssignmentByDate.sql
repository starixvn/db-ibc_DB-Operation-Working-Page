
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssigneeSuggestionList_GetAssignmentByDate] @EventDate DATE
AS

/*
Created: 202303238@Los
Task: Query assignment by date
DB: bodb_OWP   
 
Revisions:
	202303238@Los: Initial SP - [Redmine: #185365]
	20230419@Mira: Get remark of the parent match - [Redmine: #186740]
    20230712@Liam: Get more special products - [Redmine: #188985]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '2AM');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '4PM');
        DECLARE @MainAssignmentType INT= 1;
        DECLARE @MJ INT= 1;
        DECLARE @HDP INT= 1, @OU INT= 3, @1H_HDP INT= 7, @1H_OU INT= 8;
        DECLARE @Specific15Mins INT= -1, @NoOfCorner INT= -3, @NextCorner INT= -4, @TotalBookings INT= -6, @Nextbookings INT= -7, @15MinsBookings INT= -8, @Winner INT= -14, @HomeSingleTeam INT= -92, @AwaySingleTeam INT= -93;

		CREATE TABLE #AssignmentResult(
			UserId INT NOT NULL,
			BettypeId INT,
			OWPMatchId INT NOT NULL,
			KickOffTime TIME NOT NULL,
			EventDateTime DATETIME,
			LeagueName NVARCHAR(2000),
			Remark NVARCHAR(2000),
			IsMajorLeague BIT,
			IsMainMatch BIT,
			IsCornerMatch BIT,
			Is15Mins BIT,
			HomeName NVARCHAR(2000),
			AwayName NVARCHAR(2000),
			MaxbetHDP MONEY,
			SpreadHDP MONEY,
			MinorBettypeId INT,
			ParentMatchId INT,
			AssignmentNote NVARCHAR(2000)
		)

		CREATE TABLE #AssignmentNote(
			OWPMatchId INT,
			Note NVARCHAR(255))

		INSERT INTO #AssignmentResult
		(UserId ,
			BettypeId,
			OWPMatchId,
			KickOffTime,
			EventDateTime,
			LeagueName,
			Remark,
			IsMajorLeague,
			IsMainMatch,
			IsCornerMatch,
			Is15Mins,
			HomeName,
			AwayName,
			MaxbetHDP,
			SpreadHDP,
			MinorBettypeId,
			ParentMatchId
			)
        SELECT DISTINCT 
               a.UserId, 
               a.Bettype 'BettypeId', 
               a.OWPMatchId, 
               m.KickOffTime 'KOTime', 
               m.EventDateTime, 
               l.OWPLeagueName 'LeagueName',
               CASE
                   WHEN mm.MinorBettypeId IS NOT NULL
                   THEN mip.Remark
                   ELSE mi.Remark
               END 'Remark',
               CASE
                   WHEN l.CategoryId = 1 OR l.OWPLeagueName='*UEFA CHAMPIONS LEAGUE'
                   THEN 1
                   ELSE 0
               END 'IsMajorLeague',
               CASE
                   WHEN mm.MinorMatchId IS NULL
                   THEN 1
                   ELSE 0
               END 'IsMainMatch',
               CASE
                   WHEN mm.MinorBettypeId IN(@NoOfCorner, @NextCorner)
                   THEN 1
                   ELSE 0
               END 'IsCornerMatch',
               CASE
                   WHEN mm.MinorBettypeId = @Specific15Mins
                   THEN 1
                   ELSE 0
               END 'Is15Mins', 
               h.OWPTeamName 'HomeName', 
               aw.OWPTeamName 'AwayName',
               CASE
                   WHEN mm.MinorBettypeId IS NOT NULL
                   THEN msm.Maxbet
                   ELSE ms.Maxbet
               END 'MaxbetHDP',
               CASE
                   WHEN mm.MinorBettypeId IS NOT NULL
                   THEN msm.Spread
                   ELSE ms.Spread
               END 'SpreadHDP', 
               mm.MinorBettypeId, 
               mm.ParentMatchId
        FROM Assignment AS a WITH(NOLOCK)
             INNER JOIN OWPMatch AS m WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
             INNER JOIN MatchInfo AS mi WITH(NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
             INNER JOIN OWPLeague AS l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
             INNER JOIN dbo.OWPTeam aw WITH(NOLOCK) ON m.OWPAwayId = aw.OWPTeamId
             LEFT JOIN MinorMatch AS mm WITH(NOLOCK) ON mm.MinorMatchId = m.OWPMatchId
             LEFT JOIN MatchInfo AS mip WITH(NOLOCK) ON mm.ParentMatchId = mip.OWPMatchId
             LEFT JOIN MatchSetting AS ms WITH(NOLOCK) ON ms.OWPMatchId = m.OWPMatchId
                                                          AND ms.Bettype = @HDP
             LEFT JOIN MatchSetting AS msm WITH(NOLOCK) ON msm.OWPMatchId = mm.ParentMatchId
                                                           AND msm.Bettype = @HDP
        WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate
              AND a.AssignmentType = @MainAssignmentType
              AND a.Bettype IN(@HDP, @OU, @1H_HDP, @1H_OU)
             AND mi.MatchStatus NOT IN('Cancel', 'Suspended')
        AND (mm.MinorBettypeId IS NULL
             OR mm.MinorBettypeId IN(@NoOfCorner, @NextCorner, @Specific15Mins, @TotalBookings, @Nextbookings, @15MinsBookings, @Winner, @HomeSingleTeam, @AwaySingleTeam))
        ORDER BY UserId, 
                 EventDateTime, 
                 IsMainMatch, 
                 BettypeId;

	/*Main match*/
	INSERT INTO #AssignmentNote(OWPMatchId,Note)
	SELECT DISTINCT r.OWPMatchId, STRING_AGG(a.AssignmentNote, '_')
	FROM #AssignmentResult AS r
	INNER JOIN Assignment AS a WITH (NOLOCK) ON r.OWPMatchId=a.OWPMatchId
	WHERE r.IsMainMatch=1 AND a.Bettype=1
	GROUP BY r.OWPMatchId

	/*Minor match*/
	INSERT INTO #AssignmentNote(OWPMatchId,Note)
	SELECT DISTINCT r.OWPMatchId, STRING_AGG(a.AssignmentNote, '_')
	FROM #AssignmentResult AS r
	INNER JOIN MinorMatch AS mm WITH(NOLOCK) ON mm.MinorMatchId = r.OWPMatchId
	INNER JOIN Assignment AS a WITH (NOLOCK) ON mm.ParentMatchId=a.OWPMatchId
	WHERE r.IsMainMatch=0 AND a.Bettype=1
	GROUP BY r.OWPMatchId

	UPDATE a 
	SET a.AssignmentNote= note.Note
	FROM #AssignmentNote AS note INNER JOIN #AssignmentResult AS a ON a.OWPMatchId=note.OWPMatchId

	SELECT UserId ,
			BettypeId,
			OWPMatchId,
			KickOffTime,
			EventDateTime,
			LeagueName,
			Remark,
			IsMajorLeague,
			IsMainMatch,
			IsCornerMatch,
			Is15Mins,
			HomeName,
			AwayName,
			MaxbetHDP,
			SpreadHDP,
			MinorBettypeId,
			ParentMatchId,
			AssignmentNote
		FROM #AssignmentResult
	DROP TABLE #AssignmentResult;
	DROP TABLE #AssignmentNote;
    END;