/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSAssignmentUpload_GetAllMatchesByDateList] @FromDate DATETIME, 
                                                                       @ToDate   DATETIME
AS

/*
Created: 20201224@Mira
Task : Other Sport Uploading
DB: bodb_OWP

Revisions:
	20201224@Mira: Init SP [Redmine: #146962]
	202010506@Tyler: Get more props [Redmine: #153499]
	20210713@Carlos.nguyen: Get spread - [Redmine: #158285]
	20220113@Mira: Change MatchStatus name [Redmine: #167315]
	20220516@Luca: Get IsNeutral of match  [Redmine: #172762]
	20220420@Mira: Get AdminSiteMatchId  [Redmine: #171515]
	20220701@Johnny: Update condition get OS info [Redmine: #174437]
    20220808@Luca: query repoter OS info [Redmine: #174638]
*/

    BEGIN
        SET NOCOUNT ON;
        SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
        SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');

        -- Select OSMatch
        SELECT m.[OSMatchId], 
               l.[LeagueName] AS 'League', 
               m.[HomeName] AS 'Home', 
               m.IsNeutral, 
               m.[AwayName] AS 'Away', 
               m.[OfferLiveStatus] AS 'OfferLive', 
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
               m.[Remark], 
               u.Username, 
               m.MatchNo, 
               m.AdminSiteMatchId AS 'AdminsiteMatchId',
               m.Reporter
        FROM dbo.OSMatch m WITH(NOLOCK)
             LEFT JOIN dbo.OSLeague l WITH(NOLOCK) ON l.OSLeagueId = m.LeagueId
             LEFT JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = m.UploadedBy
        WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate;

        -- Select OSAssignment
        SELECT a.[OSMatchId], 
               a.[AssignmentType], 
               a.[BettypeName], 
               a.[UserId], 
               a.[AssignmentNote], 
               u.[Username], 
               u.[Nickname]
        FROM dbo.OSAssignment a WITH(NOLOCK)
             INNER JOIN dbo.OSMatch m WITH(NOLOCK) ON m.OSMatchId = a.OSMatchId
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = a.UserId
       WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate;

        --- Select OSMaxbet
        SELECT a.[OSMatchId], 
               a.[BettypeName], 
               a.[MaxBet], 
               a.[Spread]
        FROM dbo.OSMaxBet a WITH(NOLOCK)
             INNER JOIN dbo.OSMatch m WITH(NOLOCK) ON m.OSMatchId = a.OSMatchId
        WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate;
    END;