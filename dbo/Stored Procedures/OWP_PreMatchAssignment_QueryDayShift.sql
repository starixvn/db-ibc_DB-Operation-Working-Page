
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_PreMatchAssignment_QueryDayShift @EventDate DATE
AS

/*  
Created: 20200811@Esther.Nguyen  
Task : Query day shift
DB: bodb_OWP  
  
Revisions:  
 20200813@Esther.Nguyen: query day shift  - [Redmine: #138643]  
*/

     SET NOCOUNT ON;
     DECLARE @EventFromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
     DECLARE @EventToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
     DECLARE @UserNamesOfHDP VARCHAR(MAX);
     DECLARE @UserNamesOfOU VARCHAR(MAX);
     DECLARE @UserNamesOfHDPTO VARCHAR(MAX);
     DECLARE @UserNamesOfOUTO VARCHAR(MAX);
     SELECT @UserNamesOfHDP = Username
     FROM PreMatchLeague AS pl WITH(NOLOCK)
          INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
     WHERE pl.EventDate = @EventDate
           AND pl.IsDay = 1
           AND pl.IsDayShiftDeleted = 0
           AND IsTakeOver = 0
           AND Bettype = 1;
     SELECT @UserNamesOfOU = Username
     FROM PreMatchLeague AS pl WITH(NOLOCK)
          INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
     WHERE pl.EventDate = @EventDate
           AND pl.IsDay = 1
           AND pl.IsDayShiftDeleted = 0
           AND IsTakeOver = 0
           AND Bettype = 3;
     SELECT @UserNamesOfHDPTO = Username
     FROM PreMatchLeague AS pl WITH(NOLOCK)
          INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
     WHERE pl.EventDate = @EventDate
           AND pl.IsDay = 1
           AND pl.IsDayShiftDeleted = 0
           AND IsTakeOver = 1
           AND Bettype = 1;
     SELECT @UserNamesOfOUTO = Username
     FROM PreMatchLeague AS pl WITH(NOLOCK)
          INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
     WHERE pl.EventDate = @EventDate
           AND pl.IsDay = 1
           AND pl.IsDayShiftDeleted = 0
           AND IsTakeOver = 1
           AND Bettype = 3;
     -- Result
     SELECT pl.PreMatchLeagueId, 
            pl.OWPLeagueId 'LeagueId', 
            l.OWPLeagueName 'LeagueName', 
            COUNT(CASE
                      WHEN m1.LeagueName = l.OWPLeagueName
                      THEN 1
                      ELSE 0
                  END) AS 'MatchCount', 
            @UserNamesOfHDP 'HDP', 
            @UserNamesOfOU 'OU', 
            @UserNamesOfHDPTO 'HDPTakeOver', 
            @UserNamesOfOUTO 'OUTakeOver', 
            l.IsBlackList 'BlackList', 
            pl.Remark 'Remark'
     FROM PreMatchLeague AS pl WITH(NOLOCK)
          INNER JOIN OWPLeague AS l WITH(NOLOCK) ON pl.OWPLeagueId = l.OWPLeagueId
          INNER JOIN InfoSiteMatch AS m1 WITH(NOLOCK) ON m1.LeagueName = l.OWPLeagueName
     WHERE pl.EventDate = @EventDate
           AND m1.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
           AND pl.IsDay = 1
           AND pl.IsDayShiftDeleted = 0
     GROUP BY pl.PreMatchLeagueId, 
              pl.OWPLeagueId, 
              l.OWPLeagueName, 
              l.IsBlackList, 
              pl.Remark;