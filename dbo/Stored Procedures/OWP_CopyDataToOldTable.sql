
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_CopyDataToOldTable] @Date DATETIME
AS

/*    
 Created: 20200817@Mira
 Task : LA Reports
 DB: bodb_OWP    
    
 Revisions:
	20200817@Mira: Archive plan for OWP tables - [Redmine: #137757]	
	20200825@Jacob: Use index - [Redmine: #137757]	
	20200826@Jacob: Fix bug missing Odds - [Redmine: #137757]
	20210909@Luca.Duong: Remove cn88 - [Feature: #160666]	
	20240402@Los: Copy {Agent_EST, Remart_Est, RemarkBy} - [Redmine: #202819]
*/

     SET NOCOUNT ON;
     DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
     DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date) + 1, '11:59:59');

     -- Temp table
     CREATE TABLE #MatchIds
     (Id INT
     );
     INSERT INTO #MatchIds(Id)
            SELECT OWPMatchId
            FROM dbo.OWPMatch WITH(NOLOCK)
            WHERE EventDateTime BETWEEN @FromDateTime AND @ToDateTime;
     CREATE TABLE #MatchNoteIds(Id INT);
     INSERT INTO #MatchNoteIds(Id)
            SELECT MatchNoteId
            FROM dbo.MatchNote m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;
     CREATE TABLE #MatchRecommendOddsIds(Id INT);
     INSERT INTO #MatchRecommendOddsIds(Id)
            SELECT MatchRecommendOddsId
            FROM dbo.MatchRecommendOdds m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

     -- EmployeeWorkingShift
     -- DELETE EmployeeWorkingShift_Old
     DELETE FROM dbo.EmployeeWorkingShift_Old
     WHERE ShiftDate = @Date;
     -- COPY
     INSERT INTO [dbo].[EmployeeWorkingShift_Old]
     ([EmployeeId], 
      [ShiftDate], 
      [ShiftStartTime], 
      [ShiftEndTime], 
      [ShiftId], 
      [RefShiftId]
     )
            SELECT [EmployeeId], 
                   [ShiftDate], 
                   [ShiftStartTime], 
                   [ShiftEndTime], 
                   [ShiftId], 
                   [RefShiftId]
            FROM EmployeeWorkingShift WITH(NOLOCK)
            WHERE ShiftDate = @Date;
     -- EmployeeWorkingShiftNote
     -- DELETE EmployeeWorkingShiftNote_Old
     DELETE FROM dbo.[EmployeeWorkingShiftNote_Old]
     WHERE ShiftDate BETWEEN @FromDateTime AND @ToDateTime;
     -- COPY
     INSERT INTO [dbo].[EmployeeWorkingShiftNote_Old]
     ([EmployeeWorkingShiftNoteId], 
      [UserId], 
      [CreatedDate], 
      [CreatedBy], 
      [Note], 
      [ShiftDate]
     )
            SELECT [EmployeeWorkingShiftNoteId], 
                   [UserId], 
                   [CreatedDate], 
                   [CreatedBy], 
                   [Note], 
                   [ShiftDate]
            FROM [dbo].[EmployeeWorkingShiftNote] WITH(NOLOCK)
            WHERE ShiftDate BETWEEN @FromDateTime AND @ToDateTime;

     -- OWP Match     
     -- DELETE OWPMatch_Old
     DELETE m
     FROM dbo.OWPMatch_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[OWPMatch_Old]
     ([OWPMatchId], 
      [MatchNo], 
      [EventDate], 
      [KickOffTime], 
      [OWPLeagueId], 
      [OWPHomeId], 
      [OWPAwayId], 
      [MatchId], 
      [OtherTime], 
      [EventDateTime], 
      [IsChecked], 
      [InfoSiteMatchId], 
      [IsNeutral],
	  [Agent_Est],
	  [Remark_Est],
	  [RemarkBy]
     )
            SELECT m.[OWPMatchId], 
                   m.[MatchNo], 
                   m.[EventDate], 
                   m.[KickOffTime], 
                   m.[OWPLeagueId], 
                   m.[OWPHomeId], 
                   m.[OWPAwayId], 
                   m.[MatchId], 
                   m.[OtherTime], 
                   m.[EventDateTime], 
                   m.[IsChecked], 
                   m.[InfoSiteMatchId], 
                   m.[IsNeutral],
				     m.[Agent_Est],
					   m.[Remark_Est],
					     m.[RemarkBy]
            FROM dbo.OWPMatch m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

     -- DELETE MatchAgent_Old
     DELETE m
     FROM dbo.MatchAgent_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchAgent_Old]
     ([OWPMatchId], 
      [AgentId]
     )
            SELECT [OWPMatchId], 
                   [AgentId]
            FROM dbo.MatchAgent m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;
     -- DELETE MatchInfo_Old
     DELETE m
     FROM dbo.MatchInfo_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY

     INSERT INTO [dbo].[MatchInfo_Old]
     ([OWPMatchId], 
      [Channel], 
      [WB], 
      [Phone], 
      [ExtraTimeRemark], 
      [Venue], 
      [IsSelectedUpdatedDate], 
      [IsSelected], 
      [SelectedBy], 
      [IsSoloMatch], 
      [Round], 
      [Division], 
      [Remark], 
      [Website1], 
      [Website2], 
      [Website3], 
      [Website4], 
      [MatchStatus], 
      [NoOfHDPId], 
      [Market], 
      [IPTV]
     )
            SELECT [OWPMatchId], 
                   [Channel], 
                   [WB], 
                   [Phone], 
                   [ExtraTimeRemark], 
                   [Venue], 
                   [IsSelectedUpdatedDate], 
                   [IsSelected], 
                   [SelectedBy], 
                   [IsSoloMatch], 
                   [Round], 
                   [Division], 
                   [Remark], 
                   [Website1], 
                   [Website2], 
                   [Website3], 
                   [Website4], 
                   [MatchStatus], 
                   [NoOfHDPId], 
                   [Market], 
                   [IPTV]
            FROM [dbo].[MatchInfo] m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- DELETE MatchMarket_Old
     DELETE m
     FROM dbo.MatchMarket_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchMarket_Old]
     ([OWPMatchId], 
      [MarketId]
     )
            SELECT [OWPMatchId], 
                   [MarketId]
            FROM [dbo].[MatchMarket] m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- DELETE MatchNote_Old
     DELETE m
     FROM dbo.MatchNote_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchNote_Old]
     ([MatchNoteId], 
      [OWPMatchId], 
      [CreatedDate], 
      [CreatedBy], 
      [Note]
     )
            SELECT [MatchNoteId], 
                   [OWPMatchId], 
                   [CreatedDate], 
                   [CreatedBy], 
                   [Note]
            FROM [dbo].[MatchNote] m WITH(NOLOCK)
                 INNER JOIN #MatchNoteIds i ON m.MatchNoteId = i.Id; 
     -- DELETE MatchNoteUser_Old
     DELETE m
     FROM dbo.MatchNoteUser_Old m
          INNER JOIN #MatchNoteIds i ON m.MatchNoteId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchNoteUser_Old]
     ([MatchNoteId], 
      [UserId], 
      [IsViewed]
     )
            SELECT [MatchNoteId], 
                   [UserId], 
                   [IsViewed]
            FROM [dbo].[MatchNoteUser] m
                 INNER JOIN #MatchNoteIds i ON m.MatchNoteId = i.Id;

     -- DELETE MatchOfferDetail_Old
     DELETE m
     FROM dbo.MatchOfferDetail_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchOfferDetail_Old]
     ([OWPMatchId], 
      [MatchOfferId]
     )
            SELECT [OWPMatchId], 
                   [MatchOfferId]
            FROM [dbo].[MatchOfferDetail] m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- DELETE MatchOtherProvider_Old
     DELETE m
     FROM dbo.MatchOtherProvider_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchOtherProvider_Old]
     ([OWPMatchId], 
      [OtherProviderId]
     )
            SELECT [OWPMatchId], 
                   [OtherProviderId]
            FROM [dbo].[MatchOtherProvider] m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- DELETE MatchProvider_Old
     DELETE m
     FROM dbo.MatchProvider_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchProvider_Old]
     ([OWPMatchId], 
      [ProviderId]
     )
            SELECT [OWPMatchId], 
                   [ProviderId]
            FROM [dbo].[MatchProvider] m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- DELETE MatchRecommendOdds_Old
     DELETE m
     FROM dbo.MatchRecommendOdds_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchRecommendOdds_Old]
     ([MatchRecommendOddsId], 
      [OWPMatchId], 
      [Bettype], 
      [HDP], 
      [TeamChoice], 
      [CreatedBy], 
      [CreatedDate]
     )
            SELECT [MatchRecommendOddsId], 
                   [OWPMatchId], 
                   [Bettype], 
                   [HDP], 
                   [TeamChoice], 
                   [CreatedBy], 
                   [CreatedDate]
            FROM [dbo].[MatchRecommendOdds] m WITH(NOLOCK)
                 INNER JOIN #MatchRecommendOddsIds i ON m.MatchRecommendOddsId = i.Id;
     -- DELETE MatchRecommendOddsDetail_Old
     DELETE m
     FROM dbo.MatchRecommendOddsDetail_Old m
          INNER JOIN #MatchRecommendOddsIds i ON m.MatchRecommendOddsId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchRecommendOddsDetail_Old]
     ([MatchRecommendOddsId], 
      [Choice], 
      [Odds]
     )
            SELECT [MatchRecommendOddsId], 
                   [Choice], 
                   [Odds]
            FROM [dbo].[MatchRecommendOddsDetail] m WITH(NOLOCK)
                 INNER JOIN #MatchRecommendOddsIds i ON m.MatchRecommendOddsId = i.Id; 
     -- DELETE MatchSetting_Old
     DELETE m
     FROM dbo.MatchSetting_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchSetting_Old]
     ([OWPMatchId], 
      [Bettype], 
      [Spread], 
      [Maxbet]
     )
            SELECT [OWPMatchId], 
                   [Bettype], 
                   [Spread], 
                   [Maxbet]
            FROM [dbo].[MatchSetting] m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- DELETE MatchTelevision_Old
     DELETE m
     FROM dbo.MatchTelevision_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MatchTelevision_Old]
     ([OWPMatchId], 
      [TVId]
     )
            SELECT [OWPMatchId], 
                   [TVId]
            FROM [dbo].[MatchTelevision] m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- DELETE MinorMatch_Old
     DELETE m
     FROM dbo.MinorMatch_Old m
          INNER JOIN #MatchIds i ON m.ParentMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[MinorMatch_Old]
     ([RelationshipId], 
      [MinorMatchId], 
      [ParentMatchId], 
      [MinorBettypeId], 
      [IsRepresented], 
      [GroupId]
     )
            SELECT DISTINCT 
                   [RelationshipId], 
                   [MinorMatchId], 
                   [ParentMatchId], 
                   [MinorBettypeId], 
                   [IsRepresented], 
                   [GroupId]
            FROM [dbo].[MinorMatch] m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.ParentMatchId = i.Id;

     -- DELETE Assignment_Old
     DELETE m
     FROM dbo.Assignment_Old m
          INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id; 
     -- COPY
     INSERT INTO [dbo].[Assignment_Old]
     ([AssignmentId], 
      [OWPMatchId], 
      [Bettype], 
      [AssignmentType], 
      [UserId], 
      [AssignmentNote]
     )
            SELECT [AssignmentId], 
                   [OWPMatchId], 
                   [Bettype], 
                   [AssignmentType], 
                   [UserId], 
                   [AssignmentNote]
            FROM [dbo].[Assignment] m WITH(NOLOCK)
                 INNER JOIN #MatchIds i ON m.OWPMatchId = i.Id;

     -- DROP Temp Table
     DROP TABLE #MatchIds;
     DROP TABLE #MatchNoteIds;
     DROP TABLE #MatchRecommendOddsIds;