
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200810@Jacob
Task : Archive plan for OWP tables
DB: bodb_OWP	

Revisions:
	20200810@Jacob: Archive plan for OWP tables - [Redmine: #137757]
*/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


-- Old talbe
/*
DROP TABLE [dbo].[Assignment_Old]
DROP TABLE [dbo].[EmployeeWorkingShift_Old]
DROP TABLE [dbo].[MatchAgent_Old]
DROP TABLE [dbo].[MatchInfo_Old]
DROP TABLE [dbo].[MatchMarket_Old]
DROP TABLE [dbo].[MatchNote_Old]
DROP TABLE [dbo].[MatchNoteUser_Old]
DROP TABLE [dbo].[MatchOfferDetail_Old]
DROP TABLE [dbo].[MatchOtherProvider_Old]
DROP TABLE [dbo].[MatchProvider_Old]
DROP TABLE [dbo].[MatchRecommendOdds_Old]
DROP TABLE [dbo].[MatchRecommendOddsDetail_Old]
DROP TABLE [dbo].[MatchSetting_Old]
DROP TABLE [dbo].[MatchTelevision_Old]
DROP TABLE [dbo].[MinorMatch_Old]
DROP TABLE [dbo].[OWPMatch_Old]
*/


CREATE TABLE [dbo].[Assignment_Old]
([AssignmentId]   [INT] NOT NULL, 
 [OWPMatchId]     [INT] NOT NULL, 
 [Bettype]        [INT] NOT NULL, 
 [AssignmentType] [TINYINT] NOT NULL, 
 [UserId]         [INT] NULL, 
 [AssignmentNote] [NVARCHAR](200) NULL, 
 CONSTRAINT [PK_Assignment_Old] PRIMARY KEY NONCLUSTERED([AssignmentId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Index]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[EmployeeWorkingShift_Old]
([EmployeeId]     [INT] NOT NULL, 
 [ShiftDate]      [DATE] NOT NULL, 
 [ShiftStartTime] [DATETIME] NULL, 
 [ShiftEndTime]   [DATETIME] NULL, 
 [ShiftId]        [INT] NOT NULL, 
 [RefShiftId]     [INT] NULL, 
 CONSTRAINT [PK_EmployeeWorkingShift_Old] PRIMARY KEY CLUSTERED([EmployeeId] ASC, [ShiftDate] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchAgent_Old]
([OWPMatchId] [INT] NOT NULL, 
 [AgentId]    [INT] NOT NULL, 
 CONSTRAINT [PK_MatchAgent_Old] PRIMARY KEY CLUSTERED([OWPMatchId] ASC, [AgentId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchInfo_Old]
([OWPMatchId]            [INT] NOT NULL, 
 [Channel]               [NVARCHAR](100) NULL, 
 [WB]                    [NVARCHAR](100) NULL, 
 [Phone]                 [NVARCHAR](200) NULL, 
 [ExtraTimeRemark]       [NVARCHAR](100) NULL, 
 [Venue]                 [NVARCHAR](100) NULL, 
 [IsSelectedUpdatedDate] [DATETIME] NULL, 
 [IsSelected]            [BIT] NOT NULL, 
 [SelectedBy]            [INT] NULL, 
 [IsSoloMatch]           [BIT] NOT NULL, 
 [Round]                 [NVARCHAR](2000) NULL, 
 [Division]              [NVARCHAR](2000) NULL, 
 [Remark]                [NVARCHAR](2000) NULL, 
 [Website1]              [NVARCHAR](1000) NULL, 
 [Website2]              [NVARCHAR](1000) NULL, 
 [Website3]              [NVARCHAR](1000) NULL, 
 [Website4]              [NVARCHAR](1000) NULL, 
 [MatchStatus]           [VARCHAR](15) NOT NULL, 
 [NoOfHDPId]             [INT] NULL, 
 [Market]                [NVARCHAR](250) NULL, 
 [IPTV]                  [NVARCHAR](2000) NULL, 
 CONSTRAINT [PK_MatchInfo_Old] PRIMARY KEY CLUSTERED([OWPMatchId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchMarket_Old]
([OWPMatchId] [INT] NOT NULL, 
 [MarketId]   [TINYINT] NOT NULL, 
 CONSTRAINT [PK_MatchMarket_Old] PRIMARY KEY CLUSTERED([OWPMatchId] ASC, [MarketId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchNote_Old]
([MatchNoteId] [INT] NOT NULL, 
 [OWPMatchId]  [INT] NOT NULL, 
 [CreatedDate] [DATETIME] NOT NULL, 
 [CreatedBy]   [INT] NOT NULL, 
 [Note]        [NVARCHAR](4000) NOT NULL, 
 CONSTRAINT [PK_MatchNote_Old] PRIMARY KEY NONCLUSTERED([MatchNoteId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Index]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchNoteUser_Old]
([MatchNoteId] [INT] NOT NULL, 
 [UserId]      [INT] NOT NULL, 
 [IsViewed]    [BIT] NOT NULL, 
 CONSTRAINT [PK_MatchNoteUser_Old] PRIMARY KEY CLUSTERED([MatchNoteId] ASC, [UserId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchOfferDetail_Old]
([OWPMatchId]   [INT] NOT NULL, 
 [MatchOfferId] [INT] NOT NULL, 
 CONSTRAINT [PK_MatchOfferDetail_Old] PRIMARY KEY CLUSTERED([OWPMatchId] ASC, [MatchOfferId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchOtherProvider_Old]
([OWPMatchId]      [INT] NOT NULL, 
 [OtherProviderId] [INT] NOT NULL, 
 CONSTRAINT [PK_MatchOtherProvider_Old] PRIMARY KEY CLUSTERED([OWPMatchId] ASC, [OtherProviderId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchProvider_Old]
([OWPMatchId] [INT] NOT NULL, 
 [ProviderId] [INT] NOT NULL, 
 CONSTRAINT [PK_MatchProvider_Old] PRIMARY KEY CLUSTERED([OWPMatchId] ASC, [ProviderId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchRecommendOdds_Old]
([MatchRecommendOddsId] [INT] NOT NULL, 
 [OWPMatchId]           [INT] NOT NULL, 
 [Bettype]              [INT] NOT NULL, 
 [HDP]                  [SMALLMONEY] NULL, 
 [TeamChoice]           [TINYINT] NULL, 
 [CreatedBy]            [INT] NOT NULL, 
 [CreatedDate]          [DATETIME] NOT NULL, 
 CONSTRAINT [PK_MatchRecommendOdd_Old] PRIMARY KEY NONCLUSTERED([MatchRecommendOddsId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Index]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchRecommendOddsDetail_Old]
([MatchRecommendOddsId] [INT] NOT NULL, 
 [Choice]               [TINYINT] NOT NULL, 
 [Odds]                 [MONEY] NULL, 
 CONSTRAINT [PK_MatchRecommendOddDetail_Old] PRIMARY KEY CLUSTERED([MatchRecommendOddsId] ASC, [Choice] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchSetting_Old]
([OWPMatchId] [INT] NOT NULL, 
 [Bettype]    [INT] NOT NULL, 
 [Spread]     [MONEY] NULL, 
 [Maxbet]     [MONEY] NULL, 
 [MaxbetCN88] [MONEY] NULL, 
 [SpreadCN88] [MONEY] NULL, 
 CONSTRAINT [PK_MatchSetting_Old] PRIMARY KEY CLUSTERED([OWPMatchId] ASC, [Bettype] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MatchTelevision_Old]
([OWPMatchId] [INT] NOT NULL, 
 [TVId]       [INT] NOT NULL, 
 CONSTRAINT [PK_MatchTelevision_Old] PRIMARY KEY CLUSTERED([OWPMatchId] ASC, [TVId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[MinorMatch_Old]
([RelationshipId] [INT] NOT NULL, 
 [MinorMatchId]   [INT] NOT NULL, 
 [ParentMatchId]  [INT] NOT NULL, 
 [MinorBettypeId] [INT] NOT NULL, 
 [IsRepresented]  [BIT] NOT NULL, 
 [GroupId]        [INT] NULL, 
 CONSTRAINT [PK_MinorMatch_Old] PRIMARY KEY NONCLUSTERED([RelationshipId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE TABLE [dbo].[OWPMatch_Old]
([OWPMatchId]      [INT] NOT NULL, 
 [MatchNo]         [VARCHAR](50) NOT NULL, 
 [EventDate]       [DATETIME] NOT NULL, 
 [KickOffTime]     [TIME](7) NOT NULL, 
 [OWPLeagueId]     [INT] NOT NULL, 
 [OWPHomeId]       [INT] NOT NULL, 
 [OWPAwayId]       [INT] NOT NULL, 
 [MatchId]         [INT] NULL, 
 [OtherTime]       [TIME](7) NULL, 
 [EventDateTime]   [DATETIME] NULL, 
 [IsChecked]       [BIT] NULL, 
 [InfoSiteMatchId] [INT] NULL, 
 [IsNeutral]       [BIT] NOT NULL, 
 CONSTRAINT [PK_OWPMatch_Old] PRIMARY KEY CLUSTERED([OWPMatchId] ASC)
 WITH(DATA_COMPRESSION = PAGE) ON [OWP_Data]
)
ON [OWP_Data];
GO
ALTER TABLE [dbo].[MatchInfo_Old]
ADD CONSTRAINT [DF_MatchInfo_Old_IsSelected] DEFAULT((0)) FOR [IsSelected];
GO
ALTER TABLE [dbo].[MatchInfo_Old]
ADD CONSTRAINT [DF_MatchInfo_Old_IsSoloMatch] DEFAULT((0)) FOR [IsSoloMatch];
GO
ALTER TABLE [dbo].[MatchInfo_Old]
ADD CONSTRAINT [DF_MatchInfo_Old_MatchStatus] DEFAULT('Live') FOR [MatchStatus];
GO
ALTER TABLE [dbo].[MatchNote_Old]
ADD CONSTRAINT [DF_MatchNote_Old_CreatedDate] DEFAULT(GETDATE()) FOR [CreatedDate];
GO
ALTER TABLE [dbo].[MatchRecommendOdds_Old]
ADD CONSTRAINT [DF_MatchRecommendOdd_Old_CreatedDate] DEFAULT(GETDATE()) FOR [CreatedDate];
GO
ALTER TABLE [dbo].[OWPMatch_Old]
ADD CONSTRAINT [DF_OWPMatch_Old_MatchNo] DEFAULT('') FOR [MatchNo];
GO
ALTER TABLE [dbo].[OWPMatch_Old]
ADD CONSTRAINT [DF_OWPMatch_Old_IsNeutral] DEFAULT((0)) FOR [IsNeutral];
GO
