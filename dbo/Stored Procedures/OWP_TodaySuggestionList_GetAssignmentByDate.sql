
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TodaySuggestionList_GetAssignmentByDate] @EventDate DATE
AS

/*
Created: 202303238@Los
Task: Query assignment by date
DB: bodb_OWP   
 
Revisions:
	202303238@Los: Initial SP - [Redmine: #185365]

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 1, '2023-03-23'), 'AM');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, '2023-03-23'), '2PM');
		DECLARE @Specific15Mins INT= -1, @Specific15MinsNoOfCorners INT= -5,@Specific15MinsTotalBooking INT= -8;
       
        DECLARE @tempAssignment TABLE
        (OWPMatchId     INT NOT NULL, 
         IsMajorLeague  BIT NOT NULL, 
         KOTime         DATETIME NOT NULL, 
         EventDateTime  DATETIME NOT NULL, 
         BettypeId      INT NOT NULL, 
         Remark         VARCHAR(2000), 
         LeagueName     VARCHAR(2000), 
         UserId         INT NOT NULL, 
         IsMainMatch    BIT NOT NULL, 
         IsFantasyMatch BIT NOT NULL, 
         IsCornerMatch  BIT NOT NULL, 
         Is15Mins       BIT NOT NULL
        );
        INSERT INTO @tempAssignment
        (OWPMatchId, 
         IsMajorLeague, 
         KOTime, 
         UserId, 
         BettypeId, 
         EventDateTime, 
         Remark, 
         LeagueName, 
         IsMainMatch, 
         IsFantasyMatch, 
         IsCornerMatch, 
         Is15Mins
        )
               SELECT DISTINCT 
                      a.OWPMatchId,
                      CASE
                          WHEN l.CategoryId = 1
                          THEN 1
                          ELSE 0
                      END, 
                      m.KickOffTime, 
                      a.UserId, 
                      a.Bettype, 
                      m.EventDateTime, 
                      mi.Remark, 
                      l.OWPLeagueName AS LeagueName,
                      CASE
                          WHEN mm.MinorMatchId IS NULL
                          THEN 1
                          ELSE 0
                      END,
                      CASE
                          WHEN l.OWPLeagueName LIKE '%FANTASY MATCH%'
                          THEN 1
                          ELSE 0
                      END,
                      CASE
                          WHEN(l.OWPLeagueName LIKE '%CORNERS%'
                               AND l.OWPLeagueName NOT LIKE '%SPECIFIC 15 MINS NUMBER OF CORNERS%'
                               AND h.OWPTeamName LIKE '%No.of Corners%'
                               AND h.OWPTeamName NOT LIKE '% Over%')
                              OR (l.OWPLeagueName LIKE '%CORNERS%'
                                  AND h.OWPTeamName LIKE '%Next Corner%')
                          THEN 1
                          ELSE 0
                      END,
                      CASE
                          WHEN mm.MinorBettypeId IN(@Specific15Mins, @Specific15MinsNoOfCorners, @Specific15MinsTotalBooking)
                          THEN 1
                          ELSE 0
                      END
               FROM Assignment AS a WITH(NOLOCK)
                    INNER JOIN OWPMatch AS m WITH(NOLOCK) ON a.OWPMatchId = m.OWPMatchId
                    INNER JOIN MatchInfo AS mi WITH(NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
                    INNER JOIN OWPLeague AS l WITH(NOLOCK) ON m.OWPLeagueId = l.CategoryId
                    INNER JOIN dbo.OWPTeam h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
                    LEFT JOIN MinorMatch AS mm WITH(NOLOCK) ON mm.MinorMatchId = m.OWPMatchId
               WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate;
        SELECT DISTINCT 
               m.OWPMatchId, 
               m.Maxbet, 
               m.Bettype AS BettypeId
        FROM MatchSetting AS m WITH(NOLOCK)
             INNER JOIN @tempAssignment AS t ON t.OWPMatchId = m.OWPMatchId
        WHERE m.Bettype IN(1, 3);
        SELECT OWPMatchId, 
               UserId, 
               BettypeId, 
               EventDateTime, 
               Remark, 
               LeagueName
        FROM @tempAssignment;
    END;