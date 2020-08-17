
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_PreMatchAssignment_QueryNightShift @EventDate DATE, 
                                                       @StartTime DATETIME
AS

/*  
Created: 20200814@Esther.Nguyen  
Task : Query night shift
DB: bodb_OWP  
  
Revisions:  
 20200814@Esther.Nguyen: query night shift  - [Redmine: #138643]  
*/

     SET NOCOUNT ON;
     DECLARE @PreStartTime DATETIME;
     DECLARE @EventToDateTime DATETIME;
     IF @StartTime IS NOT NULL
         BEGIN
             SET @PreStartTime = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), @StartTime);
             SET @EventToDateTime = DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
     END;
         ELSE
         IF EXISTS
         (
             SELECT 1
             FROM PreMatchNightShiftStartTime
             WHERE EventDate = @EventDate
         )
             BEGIN
                 DECLARE @StartNightTime DATETIME;
                 SELECT @StartNightTime = StartTime
                 FROM PreMatchNightShiftStartTime
                 WHERE EventDate = @EventDate;
                 SET @PreStartTime = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), @StartNightTime);
                 SET @EventToDateTime = DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
         END;

     ---- insert usernames for HDP bettype----
     DECLARE @tblUserNamesHDP TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX)
     );
     INSERT INTO @tblUserNamesHDP
     (PreMatchLeagueId, 
      UserName
     )
            SELECT pa.PreMatchLeagueId, 
                   Username
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                 INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
                  AND IsTakeOver = 0
                  AND Bettype = 1
            GROUP BY pa.PreMatchLeagueId, 
                     u.Username;

     ---- insert usernames for HDP Take Over ----
     DECLARE @tblUserNamesHDPTO TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX)
     );
     INSERT INTO @tblUserNamesHDPTO
     (PreMatchLeagueId, 
      UserName
     )
            SELECT pa.PreMatchLeagueId, 
                   Username
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                 INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
                  AND IsTakeOver = 1
                  AND Bettype = 1
            GROUP BY pa.PreMatchLeagueId, 
                     u.Username;
     ---- insert usernames for OU bettype----
     DECLARE @tblUserNamesOU TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX)
     );
     INSERT INTO @tblUserNamesOU
     (PreMatchLeagueId, 
      UserName
     )
            SELECT pa.PreMatchLeagueId, 
                   Username
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                 INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
                  AND IsTakeOver = 0
                  AND Bettype = 3
            GROUP BY pa.PreMatchLeagueId, 
                     u.Username;
     ---- insert usernames for OU Take Over----
     DECLARE @tblUserNamesOUTO TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX)
     );
     INSERT INTO @tblUserNamesOUTO
     (PreMatchLeagueId, 
      UserName
     )
            SELECT pa.PreMatchLeagueId, 
                   Username
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                 INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
                  AND IsTakeOver = 1
                  AND Bettype = 3
            GROUP BY pa.PreMatchLeagueId, 
                     u.Username;

     ---- match count for league ----
     DECLARE @tblMatchCount TABLE
     (LeagueName VARCHAR(MAX), 
      MatchCount INT
     );
     INSERT INTO @tblMatchCount
     (LeagueName, 
      MatchCount
     )
            SELECT l.OWPLeagueName, 
                   COUNT(CASE
                             WHEN m1.LeagueName = l.OWPLeagueName
                             THEN 1
                             ELSE 0
                         END)
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN OWPLeague AS l WITH(NOLOCK) ON pl.OWPLeagueId = l.OWPLeagueId
                 INNER JOIN InfoSiteMatch AS m1 WITH(NOLOCK) ON m1.LeagueName = l.OWPLeagueName
            WHERE pl.EventDate = @EventDate
                  AND m1.EventDateTime BETWEEN @PreStartTime AND @EventToDateTime
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
            GROUP BY l.OWPLeagueName;		
    
	-- insert table night shift--
     DECLARE @tblNightShiftTable TABLE
     (No               INT IDENTITY(1, 1), 
      PreMatchLeagueId INT, 
      LeagueId         INT, 
      LeagueName       VARCHAR(MAX), 
      MatchCount       INT, 
      HDP              VARCHAR(200), 
      OU               VARCHAR(200), 
      HDPTakeOver      VARCHAR(200), 
      OUTakeOver       VARCHAR(200), 
      BlackList        BIT, 
      Remark           NVARCHAR(MAX)
     );
     INSERT INTO @tblNightShiftTable
     (PreMatchLeagueId, 
      LeagueId, 
      LeagueName, 
      MatchCount, 
      HDP, 
      OU, 
      HDPTakeOver, 
      OUTakeOver, 
      BlackList, 
      Remark
     )
            SELECT pl.PreMatchLeagueId 'PreMatchLeagueId', 
                   pl.OWPLeagueId 'LeagueId', 
                   l.OWPLeagueName 'LeagueName', 
                   a.MatchCount 'MatchCount', 
                   h.UserName 'HDP', 
                   o.UserName 'OU', 
                   ht.UserName 'HDPTakeOver', 
                   ot.UserName 'OUTakeOver', 
                   l.IsBlackList 'BlackList', 
                   pl.Remark 'Remark'
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN OWPLeague AS l WITH(NOLOCK) ON pl.OWPLeagueId = l.OWPLeagueId
                 INNER JOIN @tblMatchCount AS a ON a.LeagueName = l.OWPLeagueName
                 LEFT JOIN @tblUserNamesHDP AS h ON h.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblUserNamesHDPTO AS ht ON ht.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblUserNamesOU AS o ON o.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblUserNamesOUTO AS ot ON ot.PreMatchLeagueId = pl.PreMatchLeagueId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
            GROUP BY pl.PreMatchLeagueId, 
                     pl.OWPLeagueId, 
                     l.OWPLeagueName, 
                     a.MatchCount, 
                     h.UserName, 
                     ht.UserName, 
                     o.UserName, 
                     ot.UserName, 
                     l.IsBlackList, 
                     pl.Remark
            ORDER BY h.UserName DESC, 
                     o.UserName DESC, 
                     ht.UserName DESC, 
                     ot.UserName DESC, 
                     l.OWPLeagueName ASC;
     -- Result
     SELECT *
     FROM @tblNightShiftTable;