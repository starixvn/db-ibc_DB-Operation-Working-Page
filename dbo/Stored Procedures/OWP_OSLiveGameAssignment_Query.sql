USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_OSLiveGameAssignment_Query]    Script Date: 01/18/2021 10:55:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/  
  
ALTER PROCEDURE [dbo].[OWP_OSLiveGameAssignment_Query] @FromDate DATE
														,@ToDate DATE
														,@Employee VARCHAR(200)
														,@Sports VARCHAR(500)
														,@MatchStatuses VARCHAR(500)
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
  
		DECLARE @tblSports TABLE (sport VARCHAR(50))
		DECLARE @tblMatchStatuses TABLE (matchStatuses VARCHAR(15))
		DECLARE @tblOsMatch TABLE (
			[OSMatchId] INT,
			[League] VARCHAR(500),   
			[Home] VARCHAR(200),   
            [Away]VARCHAR(200),   
            [MatchStatus] VARCHAR(15),   
            [DateTime] DATETIME,   
            [Sport] VARCHAR(50),   
            [Category] VARCHAR(100),   
            [NoHDP] VARCHAR(20),   
            [MatchOffer] VARCHAR(2000),   
            [AutoLink] VARCHAR(100),   
            [Provider] VARCHAR(900),   
            [OtherProvider] VARCHAR(900),   
            [Service] VARCHAR(7),   
            [IPTV] VARCHAR(100),   
            [WB] VARCHAR(100),   
            [Remark] VARCHAR(2000)
		)

		INSERT INTO @tblSports (sport)
		SELECT t.val
		FROM dbo.fnc_SplitStrings(@Sports, ',') AS t
		OPTION (MAXRECURSION 0)

		INSERT INTO @tblMatchStatuses (matchStatuses)
		SELECT t.val
		FROM dbo.fnc_SplitStrings(@MatchStatuses, ',') AS t
		OPTION (MAXRECURSION 0)
		
		CREATE TABLE tblOsMatch (
			[OSMatchId] INT
		)
		
		INSERT INTO @tblOsMatch(
			[OSMatchId],
			[League],   
			[Home],   
            [Away],   
            [MatchStatus],   
            [DateTime],   
            [Sport],   
            [Category],   
            [NoHDP],   
            [MatchOffer],   
            [AutoLink],   
            [Provider],   
            [OtherProvider],   
            [Service],   
            [IPTV],   
            [WB],   
            [Remark]
          )
        -- Select OSMatch  
        SELECT m.[OSMatchId],   
               l.[LeagueName],   
               m.[HomeName],   
               m.[AwayName],   
               m.[MatchStatus],   
               m.[EventDateTime],   
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
			 INNER JOIN @tblSports AS tbls ON tbls.sport = m.Sport
			 INNER JOIN @tblMatchStatuses AS  tblms ON tblms.matchStatuses= m.MatchStatus
             LEFT JOIN dbo.OSLeague l WITH(NOLOCK) ON l.OSLeagueId = m.LeagueId
		WHERE m.EventDate BETWEEN @FromDate AND @ToDate
  
		SELECT m.[OSMatchId],   
               m.[League],   
               m.[Home],   
               m.[Away],   
               m.[MatchStatus],   
               m.[DateTime],   
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
        FROM @tblOsMatch m
 
        -- Select OSAssignment  
        SELECT a.[OSMatchId],   
               a.[AssignmentType],   
               a.[BettypeName],   
               a.[UserId],   
			   u.[Username],
               a.[AssignmentNote]  
        FROM dbo.OSAssignment a
             INNER JOIN @tblOsMatch m ON m.OSMatchId = a.OSMatchId  
			 LEFT JOIN dbo.[User] u WITH(NOLOCK) ON a.UserId = u.UserId
		WHERE LEN(ISNULL(@Employee, '')) = 0
			OR u.Nickname LIKE '%' + @Employee + '%'
			OR u.Username LIKE '%' + @Employee + '%'	
			 
  
        --- Select OSMaxbet  
        SELECT a.[OSMatchId],
               a.[BettypeName],   
               a.[MaxBet]  
        FROM dbo.OSMaxBet a 
             INNER JOIN @tblOsMatch m ON m.OSMatchId = a.OSMatchId
    END;