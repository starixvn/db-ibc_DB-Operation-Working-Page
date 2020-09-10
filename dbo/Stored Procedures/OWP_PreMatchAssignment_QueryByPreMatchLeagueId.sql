
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_PreMatchAssignment_QueryByPreMatchLeagueId @PreMatchLeagueId INT, 
                                                               @StartTime        TIME(7) = NULL 
AS

/*
Created: 20200818@Esther
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200818@Esther: Init sync SP - [Redmine: #138643]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @userNameOfHDP VARCHAR(200);
        DECLARE @userNameOfOU VARCHAR(200);
        DECLARE @userNameOfHDPTakeOver VARCHAR(200);
        DECLARE @userNameOfOUTakeOver VARCHAR(200);
        DECLARE @StartNightTime DATETIME= @StartTime;
        DECLARE @EventFromDateTime DATETIME;
        DECLARE @hpdBettype INT= 1;
        DECLARE @ouBettype INT= 3;
        DECLARE @eventDate DATETIME;
        SELECT @eventDate = p.EventDate
        FROM PreMatchLeague AS p WITH(NOLOCK)
        WHERE p.PreMatchLeagueId = @PreMatchLeagueId;
        IF @StartTime IS NULL
            BEGIN
                SET @EventFromDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, @eventDate), '12:00:00');
        END;
            ELSE
            IF @StartTime BETWEEN '00:00' AND '11:59'
                BEGIN
                    SET @EventFromDateTime = DATEADD(DAY, DATEDIFF(DAY, -1, @eventDate), @StartNightTime);
            END;
                ELSE
                BEGIN
                    SET @EventFromDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, @eventDate), @StartNightTime);
            END;
        DECLARE @EventToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @eventDate), '11:59:59');
        SELECT @userNameOfHDP = u.Username
        FROM PreMatchAssignment AS pa WITH(NOLOCK)
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
        WHERE pa.PreMatchLeagueId = @PreMatchLeagueId
              AND pa.Bettype = @hpdBettype
              AND pa.IsTakeOver = 0;
        SELECT @userNameOfOU = u.Username
        FROM PreMatchAssignment AS pa WITH(NOLOCK)
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
        WHERE pa.PreMatchLeagueId = @PreMatchLeagueId
              AND pa.Bettype = @ouBettype
              AND pa.IsTakeOver = 0;
        SELECT @userNameOfHDPTakeOver = u.Username
        FROM PreMatchAssignment AS pa WITH(NOLOCK)
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
        WHERE pa.PreMatchLeagueId = @PreMatchLeagueId
              AND pa.Bettype = @hpdBettype
              AND pa.IsTakeOver = 1;
        SELECT @userNameOfOUTakeOver = u.Username
        FROM PreMatchAssignment AS pa WITH(NOLOCK)
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
        WHERE pa.PreMatchLeagueId = @PreMatchLeagueId
              AND pa.Bettype = @ouBettype
              AND pa.IsTakeOver = 1;
        SELECT p.PreMatchLeagueId 'PreMatchAssignmentId', 
               p.OWPLeagueId 'LeagueId', 
               l.OWPLeagueName 'LeagueName', 
               COUNT(CASE
                         WHEN m1.LeagueName = l.OWPLeagueName
                         THEN 1
                         ELSE 0
                     END) AS 'MatchCount', 
               @userNameOfHDP 'HDP', 
               @userNameOfOU 'OU', 
               @userNameOfHDPTakeOver 'HDPTakeOver', 
               @userNameOfOUTakeOver 'OUTakeOver', 
               l.IsBlackList 'BlackList', 
               p.Remark 'Remark'
        FROM PreMatchLeague AS p WITH(ROWLOCK)
             INNER JOIN OWPLeague AS l WITH(ROWLOCK) ON l.OWPLeagueId = p.OWPLeagueId
             INNER JOIN InfoSiteMatch AS m1 WITH(NOLOCK) ON m1.LeagueName = l.OWPLeagueName
        WHERE p.PreMatchLeagueId = @PreMatchLeagueId
              AND m1.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
        GROUP BY p.PreMatchLeagueId, 
                 p.OWPLeagueId, 
                 l.OWPLeagueName, 
                 l.IsBlackList, 
                 p.Remark;
    END;