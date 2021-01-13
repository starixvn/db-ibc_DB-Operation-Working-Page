
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSLiveGameAssignment_Query] @FromDate DATE = '2020-01-01', 
                                                       @ToDate   DATE = '2020-01-05'
AS

/*  
Created: 20210113@Esther  
Task : Implement OS Live Game List  
DB: bodb_OWP  
  
Revisions:  
 20210113@Esther: Init SP [Redmine: #146963]  
*/

    BEGIN
        SET NOCOUNT ON;

        -- Select OSMatch  
        SELECT m.[OSMatchId], 
               l.[LeagueName] AS 'League', 
               m.[HomeName] AS 'Home', 
               m.[AwayName] AS 'Away', 
               m.[MatchStatus], 
               m.[EventDateTime] AS 'DateTime', 
               m.[Sport], 
               m.[Category], 
               m.[NoHDP], 
               m.[MatchOffer], 
               m.[AutoLink], 
               m.[Provider], 
               m.[OtherProvider], 
               m.[Service], 
               m.[IPTV], 
               m.[WB], 
               m.[Remark]
        FROM dbo.OSMatch m
             LEFT JOIN dbo.OSLeague l WITH(NOLOCK) ON l.OSLeagueId = m.LeagueId
             LEFT JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = m.UploadedBy
        WHERE m.EventDate BETWEEN @FromDate AND @ToDate;

        -- Select OSAssignment  
        SELECT a.[OSMatchId], 
               a.[AssignmentType], 
               a.[BettypeName], 
               a.[UserId], 
               u.[Username], 
               a.[AssignmentNote]
        FROM dbo.OSAssignment a
             INNER JOIN dbo.OSMatch m WITH(NOLOCK) ON m.OSMatchId = a.OSMatchId
             LEFT JOIN dbo.[User] u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE m.EventDate BETWEEN @FromDate AND @ToDate;

        --- Select OSMaxbet  
        SELECT a.[OSMatchId], 
               a.[BettypeName], 
               a.[MaxBet]
        FROM dbo.OSMaxBet a
             INNER JOIN dbo.OSMatch m WITH(NOLOCK) ON m.OSMatchId = a.OSMatchId
        WHERE m.EventDate BETWEEN @FromDate AND @ToDate;
    END;