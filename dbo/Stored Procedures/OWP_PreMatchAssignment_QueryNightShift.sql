USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_QueryNightShift]    Script Date: 8/28/2020 4:22:31 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryNightShift] @EventDate DATE, 
                                                               @StartTime TIME(7), 
                                                               @Employee  VARCHAR(MAX) = ''
AS

/*  
Created: 20200814@Esther.Nguyen  
Task : Query night shift
DB: bodb_OWP  
  
Revisions:  
 20200814@Esther.Nguyen: query night shift  - [Redmine: #138643]  
*/

     SET NOCOUNT ON;
     DECLARE @StartNightTime DATETIME= @StartTime;
     DECLARE @PreStartTime DATETIME;
     DECLARE @EventToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
     DECLARE @hpdBettype INT= 1;
     DECLARE @ouBettype INT= 3;
     IF @StartTime BETWEEN '00:00' AND '11:59'
         BEGIN
             SET @PreStartTime = DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), @StartNightTime);
     END;
         ELSE
         BEGIN
             SET @PreStartTime = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), @StartNightTime);
     END;

     ---- insert usernames for HDP bettype----
     DECLARE @tblUserNamesHDP TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX)
     );
     INSERT INTO @tblUserNamesHDP
     (PreMatchLeagueId, 
      UserName, 
      Nickname
     )
            SELECT pa.PreMatchLeagueId, 
                   Username, 
                   u.Nickname
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                 INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
                  AND IsTakeOver = 0
                  AND Bettype = @hpdBettype;

     ---- insert usernames for HDP Take Over ----
     DECLARE @tblUserNamesHDPTO TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX)
     );
     INSERT INTO @tblUserNamesHDPTO
     (PreMatchLeagueId, 
      UserName, 
      Nickname
     )
            SELECT pa.PreMatchLeagueId, 
                   Username, 
                   u.Nickname
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                 INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
                  AND IsTakeOver = 1
                  AND Bettype = @hpdBettype;
     ---- insert usernames for OU bettype----
     DECLARE @tblUserNamesOU TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX)
     );
     INSERT INTO @tblUserNamesOU
     (PreMatchLeagueId, 
      UserName, 
      Nickname
     )
            SELECT pa.PreMatchLeagueId, 
                   Username, 
                   u.Nickname
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                 INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
                  AND IsTakeOver = 0
                  AND Bettype = @ouBettype;
     ---- insert usernames for OU Take Over----
     DECLARE @tblUserNamesOUTO TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX)
     );
     INSERT INTO @tblUserNamesOUTO
     (PreMatchLeagueId, 
      UserName, 
      Nickname
     )
            SELECT pa.PreMatchLeagueId, 
                   Username, 
                   u.Nickname
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
                 INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 0
                  AND pl.IsDeleted = 0
                  AND IsTakeOver = 1
                  AND Bettype = @ouBettype;

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
     (No                   INT IDENTITY(1, 1), 
      PreMatchAssignmentId INT, 
      LeagueId             INT, 
      LeagueName           VARCHAR(MAX), 
      MatchCount           INT, 
      HDP                  VARCHAR(200), 
      OU                   VARCHAR(200), 
      HDPTakeOver          VARCHAR(200), 
      OUTakeOver           VARCHAR(200), 
      HDPNickname          VARCHAR(200), 
      OUNickname           VARCHAR(200), 
      HDPTakeOverNickname  VARCHAR(200), 
      OUTakeOverNickname   VARCHAR(200), 
      BlackList            BIT, 
      Remark               NVARCHAR(MAX)
     );
     INSERT INTO @tblNightShiftTable
     (PreMatchAssignmentId, 
      LeagueId, 
      LeagueName, 
      MatchCount, 
      HDP, 
      OU, 
      HDPTakeOver, 
      OUTakeOver, 
      HDPNickname, 
      OUNickname, 
      HDPTakeOverNickname, 
      OUTakeOverNickname, 
      BlackList, 
      Remark
     )
            SELECT pl.PreMatchLeagueId, 
                   pl.OWPLeagueId, 
                   l.OWPLeagueName, 
                   a.MatchCount, 
                   h.UserName, 
                   o.UserName, 
                   ht.UserName, 
                   ot.UserName, 
                   h.Nickname, 
                   o.Nickname, 
                   ht.Nickname, 
                   ot.Nickname, 
                   l.IsBlackList, 
                   pl.Remark
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
                     pl.Remark, 
                     h.Nickname, 
                     ht.Nickname, 
                     o.Nickname, 
                     ot.Nickname
            ORDER BY CASE
                         WHEN h.UserName IS NOT NULL
                         THEN 0
                         ELSE 1
                     END,
                     CASE
                         WHEN o.UserName IS NOT NULL
                         THEN 0
                         ELSE 1
                     END,
                     CASE
                         WHEN ht.UserName IS NOT NULL
                         THEN 0
                         ELSE 1
                     END,
                     CASE
                         WHEN ot.UserName IS NOT NULL
                         THEN 0
                         ELSE 1
                     END, 
                     h.UserName ASC, 
                     o.UserName ASC, 
                     ht.UserName ASC, 
                     ot.UserName ASC, 
                     l.OWPLeagueName ASC;
     -- Result
     IF @Employee = ''
         BEGIN
             SELECT [No], 
                    PreMatchAssignmentId, 
                    LeagueId, 
                    LeagueName, 
                    MatchCount, 
                    HDP, 
                    OU, 
                    HDPTakeOver, 
                    OUTakeOver, 
                    BlackList, 
                    Remark
             FROM @tblNightShiftTable;
     END;
         ELSE
         BEGIN
             SELECT [No], 
                    PreMatchAssignmentId, 
                    LeagueId, 
                    LeagueName, 
                    MatchCount, 
                    HDP, 
                    OU, 
                    HDPTakeOver, 
                    OUTakeOver, 
                    BlackList, 
                    Remark
             FROM @tblNightShiftTable AS a
             WHERE a.HDP = @Employee
                   OR a.OU = @Employee
                   OR a.HDPTakeOver = @Employee
                   OR a.OUTakeOver = @Employee
                   OR a.HDPNickname = @Employee
                   OR a.OUNickname = @Employee
                   OR a.HDPTakeOverNickname = @Employee
                   OR a.OUTakeOverNickname = @Employee;
     END;