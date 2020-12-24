
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSAssignmentUpload_GetAllMatchesByDateList] @EventDates NVARCHAR(MAX)
AS

/*
Created: 20201224@Mira
Task : Other Sport Uploading
DB: bodb_OWP

Revisions:
	20201224@Mira: Init SP [Redmine: #146962]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempMatch TABLE(EventDate DATE);
        INSERT INTO @tempMatch
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@EventDates, ',') u OPTION(MAXRECURSION 0);

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
               m.[Remark], 
               u.Username
        FROM dbo.OSMatch m
             INNER JOIN @tempMatch t ON m.EventDate = t.EventDate
             INNER JOIN dbo.OSLeague l WITH(NOLOCK) ON l.OSLeagueId = m.LeagueId
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = m.UploadedBy;

        -- Select OSAssignment
        SELECT a.[OSMatchId], 
               a.[AssignmentType], 
               a.[BettypeName], 
               a.[UserId], 
               a.[AssignmentNote]
        FROM dbo.OSAssignment a
             INNER JOIN dbo.OSMatch m WITH(NOLOCK) ON m.OSMatchId = a.OSMatchId
             INNER JOIN @tempMatch t ON t.EventDate = m.EventDate;

        --- Select OSMaxbet
        SELECT a.[OSMatchId], 
               a.[BettypeName], 
               a.[MaxBet]
        FROM dbo.OSMaxBet a
             INNER JOIN dbo.OSMatch m WITH(NOLOCK) ON m.OSMatchId = a.OSMatchId
             INNER JOIN @tempMatch t ON t.EventDate = m.EventDate;
    END;