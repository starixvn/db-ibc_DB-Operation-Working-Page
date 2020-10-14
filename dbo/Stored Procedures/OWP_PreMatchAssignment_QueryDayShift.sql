/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryDayShift] @EventDate DATE, 
                                                             @ActorId   INT
AS

/*  
Created: 20200811@Esther.Nguyen  
Task : Query day shift
DB: bodb_OWP  
  
Revisions:  
 20200813@Esther.Nguyen: query day shift  - [Redmine: #138643]  
 20200903@Tyler: query matches  - [Redmine: #140620]  
 20201003@Tyler: get other assignments  - [Redmine: #142258]  
*/

     SET NOCOUNT ON;
     DECLARE @EventFromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
     DECLARE @EventToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
     DECLARE @hpdBettype INT= 1;
     DECLARE @ouBettype INT= 3;

     -- main assignments
     DECLARE @tblHDPMainAssignment TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX)
     );
     INSERT INTO @tblHDPMainAssignment
     (PreMatchLeagueId, 
      UserName, 
      Nickname
     )
     EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment] 
          @EventDate = @EventDate, 
          @IsDay = 1, 
          @Bettype = @hpdBettype, 
          @IsTakeOver = 0;
     DECLARE @tblOUMainAssignment TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX)
     );
     INSERT INTO @tblOUMainAssignment
     (PreMatchLeagueId, 
      UserName, 
      Nickname
     )
     EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment] 
          @EventDate = @EventDate, 
          @IsDay = 1, 
          @Bettype = @ouBettype, 
          @IsTakeOver = 0;
     DECLARE @tblHDPTOMainAssignment TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX)
     );
     INSERT INTO @tblHDPTOMainAssignment
     (PreMatchLeagueId, 
      UserName, 
      Nickname
     )
     EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment] 
          @EventDate = @EventDate, 
          @IsDay = 1, 
          @Bettype = @hpdBettype, 
          @IsTakeOver = 1;
     DECLARE @tblOUTOMainAssignment TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX)
     );
     INSERT INTO @tblOUTOMainAssignment
     (PreMatchLeagueId, 
      UserName, 
      Nickname
     )
     EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment] 
          @EventDate = @EventDate, 
          @IsDay = 1, 
          @Bettype = @ouBettype, 
          @IsTakeOver = 1;

     ---- insert usernames for OtherAssignments
     DECLARE @tblOtherHDPAssignment TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX), 
      AssignmentNote   VARCHAR(MAX)
     );
     INSERT INTO @tblOtherHDPAssignment
     (PreMatchLeagueId, 
      UserName, 
      Nickname, 
      AssignmentNote
     )
     EXEC dbo.[OWP_PreMatchAssignment_QueryOtherAssignment] 
          @EventDate = @EventDate, 
          @IsDay = 1, 
          @Bettype = @hpdBettype, 
          @IsTakeOver = 0;
     DECLARE @tblOtherOUAssignment TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX), 
      AssignmentNote   VARCHAR(MAX)
     );
     INSERT INTO @tblOtherOUAssignment
     (PreMatchLeagueId, 
      UserName, 
      Nickname, 
      AssignmentNote
     )
     EXEC dbo.[OWP_PreMatchAssignment_QueryOtherAssignment] 
          @EventDate = @EventDate, 
          @IsDay = 1, 
          @Bettype = @ouBettype, 
          @IsTakeOver = 0;
     DECLARE @tblOtherHDPTOAssignment TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX), 
      AssignmentNote   VARCHAR(MAX)
     );
     INSERT INTO @tblOtherHDPTOAssignment
     (PreMatchLeagueId, 
      UserName, 
      Nickname, 
      AssignmentNote
     )
     EXEC dbo.[OWP_PreMatchAssignment_QueryOtherAssignment] 
          @EventDate = @EventDate, 
          @IsDay = 1, 
          @Bettype = @hpdBettype, 
          @IsTakeOver = 1;
     DECLARE @tblOtherOUTOAssignment TABLE
     (PreMatchLeagueId INT, 
      UserName         VARCHAR(MAX), 
      Nickname         VARCHAR(MAX), 
      AssignmentNote   VARCHAR(MAX)
     );
     INSERT INTO @tblOtherOUTOAssignment
     (PreMatchLeagueId, 
      UserName, 
      Nickname, 
      AssignmentNote
     )
     EXEC dbo.[OWP_PreMatchAssignment_QueryOtherAssignment] 
          @EventDate = @EventDate, 
          @IsDay = 1, 
          @Bettype = @ouBettype, 
          @IsTakeOver = 1;

     ---- match count for league ----
     DECLARE @tblMatchCount TABLE
     (OWPLeagueId VARCHAR(MAX), 
      MatchCount  INT
     );
     INSERT INTO @tblMatchCount
     (OWPLeagueId, 
      MatchCount
     )
            SELECT m1.OWPLeagueId, 
                   COUNT(1)
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN InfoSiteMatch AS m1 WITH(NOLOCK) ON m1.OWPLeagueId = pl.OWPLeagueId
            WHERE pl.EventDate = @EventDate
                  AND m1.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
                  AND pl.IsDay = 1
                  AND pl.IsDeleted = 0
            GROUP BY m1.OWPLeagueId;

     -- insert table day shift--
     DECLARE @tblDayShiftTable TABLE
     (PreMatchLeagueId         INT, 
      LeagueId                 INT, 
      LeagueName               VARCHAR(MAX), 
      MatchCount               INT, 
      HDP                      VARCHAR(200), 
      OU                       VARCHAR(200), 
      HDPTakeOver              VARCHAR(200), 
      OUTakeOver               VARCHAR(200), 
      HDPNickname              VARCHAR(200), 
      OUNickname               VARCHAR(200), 
      HDPTakeOverNickname      VARCHAR(200), 
      OUTakeOverNickname       VARCHAR(200), 
      OtherHDP                 VARCHAR(200), 
      OtherOU                  VARCHAR(200), 
      OtherHDPTakeOver         VARCHAR(200), 
      OtherOUTakeOver          VARCHAR(200), 
      OtherHDPNickname         VARCHAR(200), 
      OtherOUNickname          VARCHAR(200), 
      OtherHDPTakeOverNickname VARCHAR(200), 
      OtherOUTakeOverNickname  VARCHAR(200), 
      OtherHDPNote             VARCHAR(200), 
      OtherOUNote              VARCHAR(200), 
      OtherHDPTakeOverNote     VARCHAR(200), 
      OtherOUTakeOverNote      VARCHAR(200), 
      BlackList                BIT, 
      Remark                   NVARCHAR(MAX)
     );
     INSERT INTO @tblDayShiftTable
     (PreMatchLeagueId, 
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
      OtherHDP, 
      OtherOU, 
      OtherHDPTakeOver, 
      OtherOUTakeOver, 
      OtherHDPNickname, 
      OtherOUNickname, 
      OtherHDPTakeOverNickname, 
      OtherOUTakeOverNickname, 
      OtherHDPNote, 
      OtherOUNote, 
      OtherHDPTakeOverNote, 
      OtherOUTakeOverNote, 
      BlackList, 
      Remark
     )
            SELECT pl.PreMatchLeagueId, 
                   pl.OWPLeagueId, 
                   l.OWPLeagueName, 
                   a.MatchCount,
                   --main
                   mh.UserName, 
                   mo.UserName, 
                   mht.UserName, 
                   mot.UserName, 
                   mh.Nickname, 
                   mo.Nickname, 
                   mht.Nickname, 
                   mot.Nickname,
                   --Other
                   oh.UserName, 
                   oo.UserName, 
                   oht.UserName, 
                   oot.UserName, 
                   oh.Nickname, 
                   oo.Nickname, 
                   oht.Nickname, 
                   oot.Nickname,
                   -- Other assignment note
                   oh.AssignmentNote, 
                   oo.AssignmentNote, 
                   oht.AssignmentNote, 
                   oot.AssignmentNote, 
                   l.IsBlackList, 
                   pl.Remark
            FROM PreMatchLeague AS pl WITH(NOLOCK)
                 INNER JOIN OWPLeague AS l WITH(NOLOCK) ON pl.OWPLeagueId = l.OWPLeagueId
                 INNER JOIN @tblMatchCount AS a ON a.OWPLeagueId = l.OWPLeagueId
                 LEFT JOIN @tblHDPMainAssignment AS mh ON mh.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblOUMainAssignment AS mo ON mo.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblHDPTOMainAssignment AS mht ON mht.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblOUTOMainAssignment AS mot ON mot.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblOtherHDPAssignment AS oh ON oh.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblOtherOUAssignment AS oo ON oo.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblOtherHDPTOAssignment AS oht ON oht.PreMatchLeagueId = pl.PreMatchLeagueId
                 LEFT JOIN @tblOtherOUTOAssignment AS oot ON oot.PreMatchLeagueId = pl.PreMatchLeagueId
            WHERE pl.EventDate = @EventDate
                  AND pl.IsDay = 1
                  AND pl.IsDeleted = 0;

     -- Table league issue
     DECLARE @tblLeagueIssues TABLE
     (PreMatchIssueId INT, 
      OWPLeagueId     INT, 
      [Message]       VARCHAR(MAX), 
      IsRead          BIT
     );
     INSERT INTO @tblLeagueIssues
            SELECT m.PreMatchIssueId, 
                   x.OWPLeagueId, 
                   im.[Message],
                   CASE
                       WHEN r.IsRead IS NULL
                       THEN 1
                       ELSE r.IsRead
                   END AS 'IsRead'
            FROM(SELECT i.OWPLeagueId, 
                        MAX(m.CreatedDate) AS 'MaxDate'
                 FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                      LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                 WHERE i.EventDate = @EventDate
                       AND i.OWPLeagueId IS NOT NULL
                 GROUP BY i.OWPLeagueId) AS x
                INNER JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.OWPLeagueId = x.OWPLeagueId
                INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = m.PreMatchIssueId
                LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                           AND r.UserId = @ActorId
            WHERE im.CreatedDate = x.MaxDate;

     -- Table infositematch issue
     DECLARE @tblInfoSiteMatchIssues TABLE
     (PreMatchIssueId INT, 
      InfoSiteMatchId INT, 
      [Message]       VARCHAR(MAX), 
      IsRead          BIT
     );
     INSERT INTO @tblInfoSiteMatchIssues
            SELECT m.PreMatchIssueId, 
                   x.InfoSiteMatchId, 
                   im.[Message],
                   CASE
                       WHEN r.IsRead IS NULL
                       THEN 1
                       ELSE r.IsRead
                   END AS 'IsRead'
            FROM(SELECT i.InfoSiteMatchId, 
                        MAX(m.CreatedDate) AS 'MaxDate'
                 FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
                      LEFT JOIN dbo.[PreMatchIssueMessage] AS m WITH(NOLOCK) ON m.PreMatchIssueId = i.PreMatchIssueId
                 WHERE i.EventDate = @EventDate
                       AND i.InfoSiteMatchId IS NOT NULL
                 GROUP BY i.InfoSiteMatchId) AS x
                INNER JOIN dbo.[PreMatchIssue] AS m WITH(NOLOCK) ON m.InfoSiteMatchId = x.InfoSiteMatchId
                INNER JOIN dbo.[PreMatchIssueMessage] AS im WITH(NOLOCK) ON im.PreMatchIssueId = m.PreMatchIssueId
                LEFT JOIN dbo.[PreMatchIssueReceiver] AS r WITH(NOLOCK) ON r.PreMatchIssueId = m.PreMatchIssueId
                                                                           AND r.UserId = @ActorId
            WHERE im.CreatedDate = x.MaxDate;

     -- Table league notes
     DECLARE @tblLeagueNotes TABLE
     (PreMatchNoteId INT, 
      OWPLeagueId    INT, 
      HasNotes       BIT
     );
     INSERT INTO @tblLeagueNotes
     EXEC dbo.[OWP_PreMatchAssignment_QueryLeagueNotes] 
          @EventDate = @EventDate;
     --table match notes
     DECLARE @tblMatchNotes TABLE
     (PreMatchNoteId  INT, 
      InfoSiteMatchId INT, 
      HasNotes        BIT
     );
     INSERT INTO @tblMatchNotes
     EXEC dbo.[OWP_PreMatchAssignment_QueryInfoSiteMatchNotes] 
          @EventDate = @EventDate;

     -- Result
     --	Query leagues --
     SELECT PreMatchLeagueId, 
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
            OtherHDP, 
            OtherOU, 
            OtherHDPTakeOver, 
            OtherOUTakeOver, 
            OtherHDPNickname, 
            OtherOUNickname, 
            OtherHDPTakeOverNickname, 
            OtherOUTakeOverNickname, 
            OtherHDPNote, 
            OtherOUNote, 
            OtherHDPTakeOverNote, 
            OtherOUTakeOverNote, 
            BlackList, 
            Remark, 
            i.PreMatchIssueId,
            CASE
                WHEN i.[Message] IS NOT NULL
                THEN 1
                ELSE 0
            END AS HasMessages, 
            i.IsRead, 
            n.PreMatchNoteId, 
            n.HasNotes
     FROM @tblDayShiftTable AS l
          LEFT JOIN @tblLeagueIssues AS i ON l.LeagueId = i.OWPLeagueId
          LEFT JOIN @tblLeagueNotes AS n ON n.OWPLeagueId = l.LeagueId;

     -- Query InfoSiteMatches --
     SELECT m.InfoSiteMatchId, 
            m.LeagueName, 
            m.HomeName, 
            m.AwayName, 
            m.EventDateTime, 
            l.PreMatchLeagueId, 
            i.PreMatchIssueId,
            CASE
                WHEN i.[Message] IS NOT NULL
                THEN 1
                ELSE 0
            END AS HasMessages, 
            i.IsRead, 
            n.PreMatchNoteId, 
            n.HasNotes
     FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
          INNER JOIN @tblDayShiftTable AS l ON l.LeagueId = m.OWPLeagueId
          LEFT JOIN @tblInfoSiteMatchIssues AS i ON i.InfoSiteMatchId = m.InfoSiteMatchId
          LEFT JOIN @tblMatchNotes AS n ON n.InfoSiteMatchId = m.InfoSiteMatchId
     WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
     ORDER BY m.EventDateTime ASC;