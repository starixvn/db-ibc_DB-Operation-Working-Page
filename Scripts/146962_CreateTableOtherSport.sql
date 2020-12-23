
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20201223@Mira
Task : Other Sport
DB: bodb_OWP	

Revisions:
	20201223@Mira: Create tables for other sport - [Redmine: #146962]
*/

-- Table OSLeague
IF OBJECT_ID('dbo.OSLeague', 'U') IS NOT NULL
    DROP TABLE dbo.[OSLeague]; 
GO
CREATE TABLE [dbo].[OSLeague]
([OSLeagueId] [INT] IDENTITY(1, 1) NOT NULL, 
 [LeagueName] [NVARCHAR](500) NOT NULL, 
 CONSTRAINT [PK_OSLeague] PRIMARY KEY CLUSTERED([OSLeagueId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

-- Table OSMaxBet
IF OBJECT_ID('dbo.OSMaxBet', 'U') IS NOT NULL
    DROP TABLE dbo.[OSMaxBet]; 
GO
CREATE TABLE [dbo].[OSMaxBet]
([OSMaxBetId]  [INT] IDENTITY(1, 1) NOT NULL, 
 [BettypeName] [VARCHAR](50) NOT NULL, 
 [MaxBet]      [MONEY] NOT NULL, 
 CONSTRAINT [PK_OSMaxBet] PRIMARY KEY CLUSTERED([OSMaxBetId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

-- Table OSMatch
IF OBJECT_ID('dbo.OSMatch', 'U') IS NOT NULL
    DROP TABLE dbo.[OSMatch]; 
GO
CREATE TABLE [dbo].[OSMatch]
([OSMatchId]     [INT] IDENTITY(1, 1) NOT NULL, 
 [Sport]         [VARCHAR](50) NOT NULL, 
 [MatchStatus]   [VARCHAR](15) NOT NULL, 
 [EventDateTime] [DATETIME] NOT NULL, 
 [EventDate]     [DATE] NOT NULL, 
 [LeagueId]      [INT] NOT NULL, 
 [HomeName]      [NVARCHAR](200) NOT NULL, 
 [AwayName]      [NVARCHAR](200) NOT NULL, 
 [Category]      [VARCHAR](100) NULL, 
 [NoHDP]         [VARCHAR](20) NULL, 
 [AutoLink]      [VARCHAR](100) NULL, 
 [Service]       [VARCHAR](7) NOT NULL, 
 [IPTV]          [VARCHAR](100) NULL, 
 [WB]            [VARCHAR](100) NULL, 
 [Remark]        [VARCHAR](2000) NULL, 
 [Provider]      [VARCHAR](900) NULL, 
 [OtherProvider] [VARCHAR](900) NULL, 
 [MatchOffer]    [VARCHAR](2000) NULL, 
 [UploadedBy]    [INT] NOT NULL, 
 CONSTRAINT [PK_OSMatch] PRIMARY KEY CLUSTERED([OSMatchId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO
CREATE NONCLUSTERED INDEX [IX_OSMatch] ON [dbo].[OSMatch]([EventDate] ASC) WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data];
GO

-- Table OSAssignment
IF OBJECT_ID('dbo.OSAssignment', 'U') IS NOT NULL
    DROP TABLE dbo.[OSAssignment]; 
GO
CREATE TABLE [dbo].[OSAssignment]
([OSAssignmentId] [INT] IDENTITY(1, 1) NOT NULL, 
 [OSMatchId]      [INT] NOT NULL, 
 [BettypeName]    [VARCHAR](50) NOT NULL, 
 [AssignmentType] [TINYINT] NOT NULL, 
 [UserId]         [INT] NOT NULL, 
 [AssignmentNote] [NVARCHAR](200) NULL, 
 CONSTRAINT [PK_OSAssignment] PRIMARY KEY CLUSTERED([OSAssignmentId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO