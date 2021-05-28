USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_OSLiveGameAssignment_Query]    Script Date: 03/08/2021 10:53:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_OSLiveGameAssignment_Query] @FromDate DATE
														,@ToDate DATE
														,@Sports VARCHAR(500)
														,@MatchStatuses VARCHAR(500)
AS  
  
/*  
Created: 20210113@Esther  
Task : Implement OS Live Game List  
DB: bodb_OWP  
  
Revisions:  
 20210113@Esther: Init SP [Redmine: #146963] 
 20210309@Carlos.Nguyen: Enhance OS Live Assignment - Phase 1 [Redmine: #150978]
 20210328@Carlos.Nguyen: Enhance OS Live Assignment - Phase 2 [Redmine: #155608]
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
            [MatchNo] DOUBLE PRECISION,
			[Reporter] VARCHAR(2000),
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
		
		INSERT INTO @tblOsMatch(
			[OSMatchId],
			[League],   
			[Home],   
            [Away],   
            [MatchNo],
			[Reporter],
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
               m.[MatchNo],
			   m.[Reporter],	
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
             INNER JOIN dbo.OSLeague l WITH(NOLOCK) ON l.OSLeagueId = m.LeagueId
		WHERE m.EventDate BETWEEN @FromDate AND @ToDate
		
		SELECT m.[OSMatchId],
			   m.Sport,   
               m.[League],   
               m.[Home],   
               m.[Away],   
               m.[MatchNo],
			   m.[Reporter],
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
        ORDER BY m.[DateTime] ASC
 
        -- Select OSAssignment  
        SELECT osa.[OSMatchId], 
               osa.[AssignmentType],   
               osa.[BettypeName],   
               osa.[UserId],   
			   u.[Username],
			   u.Nickname,
               osa.[AssignmentNote]
        FROM @tblOsMatch AS osm
			INNER JOIN dbo.OSAssignment AS osa WITH(NOLOCK) ON osm.OSMatchId= osa.OSMatchId
			LEFT JOIN dbo.[User] u WITH(NOLOCK) ON osa.UserId = u.UserId
			 
        --- Select OSMaxbet  
        SELECT a.[OSMatchId],
               a.[BettypeName],
               a.[MaxBet]  
        FROM dbo.OSMaxBet a 
             INNER JOIN @tblOsMatch m ON m.OSMatchId = a.OSMatchId
    END;
