
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssigneeSuggestionList_GetMatchInfo] @OwpMatchId INT
AS

/*
Created: 20230324@Mira
Task : 
DB: bodb_OWP

Revisions:
   20230324@Mira: Initial - [Redmine: #185365]	
   20230419@Mira: Get Spread, remark of the parent match - [Redmine: #186740]
   20230512@Liamn: Get solo match info - [Redmine: #186740]
   20230712@Liam: Get more special products - [Redmine: #188985]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @HDP INT= 1;

		CREATE TABLE #AssignmentResult
		(
			OwpMatchId INT NOT NULL,
			LeagueName NVARCHAR(2000),
			HomeName NVARCHAR(2000),
			AwayName NVARCHAR(2000),
			EventDate DATETIME,
			KOTime DATETIME,
			MatchNo VARCHAR(20),
			MinorBettypeId INT,
			SpreadHDP MONEY,
			MaxbetHDP MONEY,
			Remark NVARCHAR(2000),
			IsSoloMatch BIT,
			AssignmentNote NVARCHAR(2000),
			IsMainMatch BIT
		)
		CREATE TABLE #AssignmentNote(
			OWPMatchId INT,
			Note NVARCHAR(255))

		INSERT INTO #AssignmentResult
		(OwpMatchId ,
			LeagueName ,
			HomeName ,
			AwayName ,
			EventDate ,
			KOTime ,
			MatchNo ,
			MinorBettypeId ,
			SpreadHDP ,
			MaxbetHDP ,
			Remark ,
			IsSoloMatch,
			IsMainMatch
			)
        SELECT m.OWPMatchId 'OwpMatchId', 
               l.OWPLeagueName 'LeagueName', 
               (CASE
                    WHEN m.IsNeutral = 1
                    THEN h.OWPTeamName + ' (N)'
                    ELSE h.OWPTeamName
                END) AS HomeName, 
               a.OWPTeamName 'AwayName', 
               m.EventDate, 
               m.EventDateTime 'KOTime', 
               m.MatchNo, 
               mm.MinorBettypeId, 
               ms.Spread 'SpreadHDP', 
               ms.Maxbet 'MaxbetHDP',
               CASE
                   WHEN mm.MinorBettypeId IS NOT NULL
                   THEN mip.Remark
                   ELSE i.Remark
               END 'Remark',
               i.IsSoloMatch,
			   CASE
                   WHEN mm.MinorMatchId IS NULL
                   THEN 1
                   ELSE 0
               END 'IsMainMatch'
        FROM dbo.OWPMatch m WITH(NOLOCK)
             LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
             LEFT JOIN dbo.MinorBettype mb WITH(NOLOCK) ON mm.MinorBettypeId = mb.MinorBettypeId
             INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
             INNER JOIN dbo.OWPTeam a WITH(NOLOCK) ON m.OWPAwayId = a.OWPTeamId
             INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON m.OWPLeagueId = l.OWPLeagueId
             LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
             LEFT JOIN dbo.MatchInfo AS mip WITH(NOLOCK) ON mm.ParentMatchId = mip.OWPMatchId
             LEFT JOIN dbo.MatchSetting ms WITH(NOLOCK) ON m.OWPMatchId = ms.OWPMatchId
                                                           AND ms.Bettype = @HDP
        WHERE m.OWPMatchId = @OwpMatchId;

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

		SELECT OwpMatchId,
			LeagueName,
			HomeName,
			AwayName,
			EventDate ,
			KOTime ,
			MatchNo ,
			MinorBettypeId ,
			SpreadHDP ,
			MaxbetHDP ,
			Remark ,
			IsSoloMatch
		FROM #AssignmentResult

		DROP TABLE #AssignmentNote
		DROP TABLE #AssignmentResult
    END;