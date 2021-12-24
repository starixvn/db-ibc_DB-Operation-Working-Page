
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_AutoAssignment_GetLARealAssignment @UserIds   NVARCHAR(MAX), 
                                                       @EventDate DATE
AS

/*
Created: 20201223@Tyler
Task : Auto LA - Results verification
DB: bodb_OWP

Revisions:
	20201223@Tyler: Initial - [Redmine: #150268]
	20211222@Tyler: add SABA - [Redmine: #166161]
	
*/

    BEGIN
        SET NOCOUNT ON;
        -- temp User
        DECLARE @tblUserId TABLE(UserId INT);
        INSERT INTO @tblUserId
               SELECT DISTINCT 
                      [Value]
               FROM fnc_SplitString(@UserIds, ',') u OPTION(MAXRECURSION 0);
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '04:00:00');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '11:59:59');
        DECLARE @tblFTETPK TABLE
        (OWPMatchId INT, 
         ETPK       VARCHAR(2000)
        );
        DECLARE @tblAssignment TABLE
        (UserId         INT, 
         AssignmentId   INT, 
         ProviderName   VARCHAR(900), 
         MinorBettypeId INT, 
         OWPMatchId     INT, 
         ParentMatchId  INT, 
         EventDateTime  DATETIME, 
         OWPLeagueName  VARCHAR(500), 
         ETPK           VARCHAR(2000), 
         Maxbet         MONEY, 
         IsSaba         BIT
        );
        INSERT INTO @tblAssignment
               SELECT DISTINCT 
                      a.UserId, 
                      a.AssignmentId, 
                      p.ProviderName, 
                      mn.MinorBettypeId, 
                      ma.OWPMatchId, 
                      mn.ParentMatchId, 
                      ma.EventDateTime, 
                      l.OWPLeagueName, 
                      im.ETPK, 
                      h.MaxBetFTHDP, 
                      ir.IsSaba
               FROM dbo.Assignment a WITH(NOLOCK)
                    INNER JOIN @tblUserId ids ON ids.UserId = a.UserId
                    INNER JOIN dbo.OWPMatch ma WITH(NOLOCK) ON ma.OWPMatchId = a.OWPMatchId
                    INNER JOIN dbo.MatchInfo mi WITH(NOLOCK) ON mi.OWPMatchId = ma.OWPMatchId
                    INNER JOIN dbo.OWPLeague l WITH(NOLOCK) ON ma.OWPLeagueId = l.OWPLeagueId
                    LEFT JOIN dbo.InfoSiteMatch im WITH(NOLOCK) ON im.InfoSiteMatchId = ma.InfoSiteMatchId
                    LEFT JOIN dbo.MatchProvider mp WITH(NOLOCK) ON ma.OWPMatchId = mp.OWPMatchId
                    LEFT JOIN dbo.[Provider] p WITH(NOLOCK) ON mp.ProviderId = p.ProviderId
                    LEFT JOIN dbo.MinorMatch mn WITH(NOLOCK) ON ma.OWPMatchId = mn.MinorMatchId
                    LEFT JOIN dbo.AutoAssignmentHistory h WITH(NOLOCK) ON h.InfoSiteMatchId = ma.InfoSiteMatchId
                    LEFT JOIN dbo.InfoSiteAutoAssignmentResult ir WITH(NOLOCK) ON ir.InfoSiteMatchId = ma.InfoSiteMatchId
               WHERE mi.MatchStatus = 'Live'
                     AND a.Bettype = -1002
                     AND ma.EventDateTime BETWEEN @FromDate AND @ToDate;
        INSERT INTO @tblFTETPK
               SELECT a.ParentMatchId, 
                      im.ETPK
               FROM dbo.InfoSiteMatch im WITH(NOLOCK)
                    INNER JOIN dbo.OWPMatch ma WITH(NOLOCK) ON ma.InfoSiteMatchId = im.InfoSiteMatchId
                    INNER JOIN @tblAssignment a ON ma.OWPMatchId = a.ParentMatchId;
        SELECT a.UserId 'UserId_LA', 
               a.AssignmentId, 
               a.ProviderName, 
               a.MinorBettypeId, 
               a.OWPMatchId, 
               a.ParentMatchId, 
               a.EventDateTime, 
               a.OWPLeagueName, 
               a.ETPK,
               CASE
                   WHEN a.ParentMatchId IS NOT NULL
                   THEN et.ETPK
                   ELSE ''
               END 'FullTimeETPK', 
               a.Maxbet, 
               a.IsSaba
        FROM @tblAssignment a
             LEFT JOIN @tblFTETPK et ON a.ParentMatchId = et.OWPMatchId
        ORDER BY UserId ASC, 
                 a.EventDateTime ASC;
        DELETE @tblUserId;
        DELETE @tblFTETPK;
        DELETE @tblAssignment;
    END;